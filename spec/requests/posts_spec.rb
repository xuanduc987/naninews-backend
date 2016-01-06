require "rails_helper"
require "support/factory_girl"

RSpec.describe "Posts", type: :request do
  let(:body) { JSON.parse(response.body) }

  describe "GET /posts" do
    it "responses with HTTP 200 status code" do
      get "/posts"

      expect(response).to have_http_status(200)
    end

    context "when there are no posts" do
      before(:each) { Post.delete_all }

      before(:each) { get "/posts" }

      it "returns empty posts array" do
        empty_posts = { "posts" => [] }
        expect(body).to eql(empty_posts)
      end
    end

    context "when there are 3 posts" do
      let!(:posts) { create_list(:post, 3) }

      before(:each) { get "/posts" }

      it "returns 3 posts" do
        expect(body["posts"].count).to eql(3)
      end
    end
  end

  describe "GET /posts/{id}" do
    context "when there is no post with provided id" do
      let(:id) { 77 }

      before(:each) { Post.where(id: id).delete_all }

      it "responses with HTTP 404 status code" do
        get "/posts/#{id}"

        expect(response).not_to be_success
        expect(response).to have_http_status(404)
      end
    end

    context "when there is a post with provided id" do
      let(:post) { create :post }

      before(:each) { get "/posts/#{post.id}" }

      it "responses with HTTP 200 status code" do
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it "return that post" do
        expect(body["post"]["id"]).to eql(post.id)
      end
    end
  end

  describe "GET /posts?slug={slug}" do
    context "when there is no post with provided slug" do
      let(:slug) { "no-body-want-this-slug" }

      before(:each) { Post.where(slug: slug).delete_all }

      it "responses with HTTP 404 status code" do
        get "/posts?slug=#{slug}"

        expect(response).not_to be_success
        expect(response).to have_http_status(404)
      end
    end

    context "when there is a post with provided slug" do
      let(:post) { create :post }

      before(:each) { get "/posts?slug=#{post.slug}" }

      it "responses with HTTP 200 status code" do
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it "return that post" do
        expect(body["post"]["id"]).to eql(post.id)
      end
    end
  end

  describe "POST /posts" do
    let(:post_data) { nil }

    before(:each) do
      post "/posts", post_data,
        authorization: ActionController::HttpAuthentication::Token.encode_credentials(token)
    end

    context "when token is invalid" do
      let(:token) { nil }

      it "responses with HTTP 401 status code" do
        expect(response).not_to be_success
        expect(response).to have_http_status(401)
      end
    end

    context "when token is valid" do
      let(:api_token) { create :api_token }
      let(:token) { api_token.token }

      context "when post data is valid" do
        let(:post_data) do
          new_post = build(:post)
          { post: { title: new_post.title, url: new_post.url } }
        end

        it "responses with HTTP 201 status code" do
          expect(response).to be_success
          expect(response).to have_http_status(201)
        end

        it "saves new post for current user to database" do
          expect(Post.where(post_data[:post])
            .where(user: api_token.user)).to exist
        end

        it "returns created post" do
          expect(body["post"]["id"]).to eql(Post.last.id)
        end
      end

      context "when post data is invalid" do
        let(:post_data) do
          new_post = build(:post)
          { post: { title: new_post.title, url: "tel" } }
        end

        it "responses with HTTP 422 status code" do
          expect(response).not_to be_success
          expect(response).to have_http_status(422)
        end

        it "returns reasons" do
          error = { "url" => ["is not an url"] }
          expect(body).to eql(error)
        end
      end
    end
  end

  describe "PUT posts/{id}" do
    let(:old_post) { create :post }
    let(:update_data) { nil }

    before :each do
      put "/posts/#{old_post.id}", update_data,
        authorization: ActionController::HttpAuthentication::Token.encode_credentials(token)
    end

    context "when token is invalid" do
      let(:token) { nil }

      it "responses with HTTP 401 status code" do
        expect(response).not_to be_success
        expect(response).to have_http_status(401)
      end
    end

    context "when token is valid" do
      let(:user) { create :user }
      let(:token) { create(:api_token, user: user).token }

      context "when post doesn't exist" do
        let(:old_post) { instance_double("Post", id: -1) }

        it "responses with HTTP 422 status code" do
          expect(response).not_to be_success
          expect(response).to have_http_status(422)
        end
      end

      context "when post doesn't belong to user" do
        it "responses with HTTP 422 status code" do
          expect(response).not_to be_success
          expect(response).to have_http_status(422)
        end
      end

      context "when post belongs to user" do
        let(:old_post) { create :post, user: user }

        it "responses with HTTP 204 status code" do
          expect(response).to be_success
          expect(response).to have_http_status(204)
        end

        context "when provided new url" do
          let(:new_url) { old_post.url + "updated" }
          let(:update_data) { { post: { url: new_url } } }

          it "updates post with new url" do
            expect(old_post.reload.url).to eql(new_url)
          end
        end

        context "when provided new title" do
          let(:new_title) { old_post.title + " updated" }
          let(:update_data) { { post: { title: new_title } } }

          it "updates post with new title" do
            expect(old_post.reload.title).to eql(new_title)
          end

          it "updates post with new slug" do
            old_slug = old_post.slug
            expect(old_post.reload.slug).not_to eql(old_slug)
          end
        end
      end
    end
  end

  describe "DELETE posts/{id}" do
    let(:old_post) { create :post }

    before :each do
      delete "/posts/#{old_post.id}", nil,
        authorization: ActionController::HttpAuthentication::Token.encode_credentials(token)
    end

    context "when token is invalid" do
      let(:token) { nil }

      it "responses with HTTP 401 status code" do
        expect(response).not_to be_success
        expect(response).to have_http_status(401)
      end
    end

    context "when token is valid" do
      let(:user) { create :user }
      let(:token) { create(:api_token, user: user).token }

      context "when post doesn't exist" do
        let(:old_post) { instance_double("Post", id: -1) }

        it "responses with HTTP 422 status code" do
          expect(response).not_to be_success
          expect(response).to have_http_status(422)
        end
      end

      context "when post doesn't belong to user" do
        it "responses with HTTP 422 status code" do
          expect(response).not_to be_success
          expect(response).to have_http_status(422)
        end
      end

      context "when post belongs to user" do
        let(:old_post) { create :post, user: user }

        it "responses with HTTP 204 status code" do
          expect(response).to be_success
          expect(response).to have_http_status(204)
        end

        it "destroys that post" do
          expect(Post.where(id: old_post.id)).not_to exist
        end
      end
    end
  end
end
