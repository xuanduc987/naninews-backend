require "rails_helper"
require "support/factory_girl"

RSpec.describe "Votes", type: :request do
  let(:body) { JSON.parse(response.body) }

  describe "POST /posts/{post_id}/votes" do
    let(:post_id) { 1 }
    let(:post_data) { nil }

    before(:each) do
      post "/posts/#{post_id}/votes", post_data,
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
      let(:current_user) { create :user }
      let(:token) { create(:api_token, user: current_user).token }

      context "when post does not exist" do
        let(:post_id) { -1 }

        it "responses with HTTP 404 status code" do
          expect(response).not_to be_success
          expect(response).to have_http_status(404)
        end
      end

      context "when post exists" do
        let(:existing_post) { create :post }
        let(:post_id) { existing_post.id }

        context "when post data is empty" do
          let(:post_data) { nil }

          it "responses with HTTP 422 status code" do
            expect(response).not_to be_success
            expect(response).to have_http_status(422)
          end
        end

        context "when vote value is empty" do
          let(:post_data) { { vote: nil } }

          it "responses with HTTP 422 status code" do
            expect(response).not_to be_success
            expect(response).to have_http_status(422)
          end
        end

        context "when vote value is true" do
          let(:post_data) { { vote: true } }

          it "responses with HTTP 200 status code" do
            expect(response).to be_success
            expect(response).to have_http_status(200)
          end

          it "returns voted with value true" do
            expect(body["voted"]).to eql(true)
          end

          it "makes user to vote for post" do
            expect(current_user.voted_for?(existing_post)).to be true
          end
        end

        context "when vote value is false" do
          let(:current_user) do
            create(:user).tap { |user| user.vote_for existing_post }
          end

          let(:post_data) { { vote: false } }

          it "responses with HTTP 200 status code" do
            expect(response).to be_success
            expect(response).to have_http_status(200)
          end

          it "returns voted with value false" do
            expect(body["voted"]).to eql(false)
          end

          it "makes user to unvote for post" do
            expect(current_user.voted_for?(existing_post)).to be false
          end
        end
      end
    end
  end
end
