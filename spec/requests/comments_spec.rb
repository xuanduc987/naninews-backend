require "rails_helper"
require "support/factory_girl"

RSpec.describe "Comments", type: :request do
  let(:body) { JSON.parse(response.body) }

  describe "GET /posts/1/comments" do
    let(:post_object) { create :post }

    before(:each) { get "/posts/#{post_object.id}/comments" }

    it "responses with HTTP 200 status code" do
      expect(response).to have_http_status(200)
    end

    context "when post has no comments" do
      let(:post_object) do
        create(:post).tap do |post|
          post.comments.destroy_all
        end
      end

      it "returns empty comments array" do
        empty_comments = { "comments" => [] }
        expect(body).to eql(empty_comments)
      end
    end

    context "when post has 3 comments" do
      let(:post_object) do
        create_list :comment, 2
        create(:post).tap do |post_object|
          create_list :comment, 3, post: post_object
        end
      end

      it "returns 3 comments" do
        expect(body["comments"].count).to eql(3)
      end
    end
  end

  describe "GET /comments/1" do
    context "when there is no comment with provided id" do
      let(:id) { -1 }

      it "responses with HTTP 404 status code" do
        get "/comments/#{id}"

        expect(response).not_to be_success
        expect(response).to have_http_status(404)
      end
    end

    context "when there is a comment with provided id" do
      let(:comment) { create :comment }
      let(:token) { nil }

      before(:each) do
        get "/comments/#{comment.id}", nil,
          authorization: ActionController::HttpAuthentication::Token.encode_credentials(token)
      end

      it "responses with HTTP 200 status code" do
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it "return that comment" do
        expect(body["comment"]["id"]).to eql(comment.id)
      end

      context "when token is valid" do
        let(:token) { create(:api_token, user: current_user).token }

        context "when current user had made that comment" do
          let(:current_user) { create :user }
          let(:comment) { create :comment, user: current_user }

          it "returns comment with mine field is true" do
            expect(body["comment"]["mine"]).to be true
          end
        end
      end
    end
  end

  describe "POST /posts/1/comments" do
    let(:comment_data) { nil }
    let(:post_object) { create :post }

    before(:each) do
      post "/posts/#{post_object.id}/comments", comment_data,
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

      context "when post doesn't exist" do
        let(:post_object) do
          build :post, id: -1
        end

        it "responses with HTTP 404 status code" do
          expect(response).not_to be_success
          expect(response).to have_http_status(404)
        end
      end

      context "when post exists" do
        context "when comment data is valid" do
          let(:comment_data) do
            comment = build(:comment)
            { comment: { content: comment.content } }
          end

          it "responses with HTTP 201 status code" do
            expect(response).to be_success
            expect(response).to have_http_status(201)
          end

          it "saves new comment for current user to database" do
            expect(Comment.where(comment_data[:comment])
              .where(user: api_token.user)).to exist
          end

          it "returns created comment" do
            expect(body["comment"]["id"]).to eql(Comment.last.id)
          end
        end
      end

      context "when comment data is invalid" do
        let(:comment) do
          comment = build :comment, content: nil
          comment.validate
          comment
        end
        let(:comment_data) do
          { comment: { comment: comment.content } }
        end

        it "responses with HTTP 422 status code" do
          expect(response).not_to be_success
          expect(response).to have_http_status(422)
        end

        it "returns reasons" do
          expect(body).to eql(comment.errors.messages.with_indifferent_access)
        end
      end
    end
  end

  describe "PUT comments/{id}" do
    let(:old_comment) { create :comment }
    let(:update_data) { nil }

    before :each do
      put "/comments/#{old_comment.id}", update_data,
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

      context "when comment doesn't exist" do
        let(:old_comment) { instance_double("Comment", id: -1) }

        it "responses with HTTP 422 status code" do
          expect(response).not_to be_success
          expect(response).to have_http_status(422)
        end
      end

      context "when comment doesn't belong to user" do
        it "responses with HTTP 422 status code" do
          expect(response).not_to be_success
          expect(response).to have_http_status(422)
        end
      end

      context "when comment belongs to user" do
        let(:old_comment) { create :comment, user: user }

        it "responses with HTTP 204 status code" do
          expect(response).to be_success
          expect(response).to have_http_status(204)
        end

        context "when provided new content" do
          let(:new_content) { old_comment.content + "updated" }
          let(:update_data) { { comment: { content: new_content } } }

          it "updates comment with new content" do
            expect(old_comment.reload.content).to eql(new_content)
          end
        end
      end
    end
  end

  describe "DELETE comments/{id}" do
    let(:old_comment) { create :comment }

    before :each do
      delete "/comments/#{old_comment.id}", nil,
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

      context "when comment doesn't exist" do
        let(:old_comment) { instance_double("Comment", id: -1) }

        it "responses with HTTP 422 status code" do
          expect(response).not_to be_success
          expect(response).to have_http_status(422)
        end
      end

      context "when comment doesn't belong to user" do
        it "responses with HTTP 422 status code" do
          expect(response).not_to be_success
          expect(response).to have_http_status(422)
        end
      end

      context "when comment belongs to user" do
        let(:old_comment) { create :comment, user: user }

        it "responses with HTTP 204 status code" do
          expect(response).to be_success
          expect(response).to have_http_status(204)
        end

        it "destroys that comment" do
          expect(Comment.where(id: old_comment.id)).not_to exist
        end
      end
    end
  end
end
