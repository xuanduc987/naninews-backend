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
end
