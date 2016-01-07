require "rails_helper"
require "support/factory_girl"

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  it { should validate_presence_of(:name) }
  it { should have_secure_password }

  context "when email address is invalid" do
    INVALID_EMAILS = %w(email@example email.@example.com @example.com example
                        .email@example.com email..email@example.com
                        email@example..com)

    it "is invalid" do
      INVALID_EMAILS.each do |email|
        user.email = email
        expect(user).not_to be_valid
      end
    end
  end

  context "when email address is valid" do
    VALID_EMAILS = %w(email@example.com first.last@example.com
                      email@subdomain.example.com email+tag@example.com)

    it "is valid" do
      VALID_EMAILS.each do |email|
        user.email = email
        expect(user).to be_valid
      end
    end
  end

  describe ".destroy" do
    let(:user) { create :user }
    let(:subject) { user.destroy }

    context "when user has some posts" do
      before(:each) { create_list :post, 3, user: user }

      it "destroys all their posts" do
        expect { subject }.to change { user.posts.count }.to(0)
      end
    end

    context "when user has some votes" do
      before(:each) { create_list :vote, 3, user: user }

      it "destroys all their votes" do
        expect { subject }.to change { user.votes.count }.to(0)
      end
    end

    context "when user has some api_tokens" do
      before(:each) { create_list :api_token, 3, user: user }

      it "destroys all their api_tokens" do
        expect { subject }.to change { user.api_tokens.count }.to(0)
      end
    end
  end
end
