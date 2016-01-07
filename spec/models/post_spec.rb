require "rails_helper"
require "support/factory_girl"

RSpec.describe Post, type: :model do
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:slug) }
  it { should validate_presence_of(:url) }

  context "when slug is not set" do
    let(:post) { build(:post, slug: nil) }

    it "generates slug from title before validation" do
      post.valid?
      expect(post.slug).to eq(post.title.parameterize)
    end
  end

  context "when url is not valid" do
    let(:subject) { build(:post, url: "tel://api.com") }

    it { should be_invalid }
  end

  describe ".destroy" do
    let(:post) { create :post }
    let(:subject) { post.destroy }

    context "when post has some votes" do
      before(:each) { create_list :vote, 3, post: post }

      it "destroys all its votes" do
        expect { subject }.to change { post.votes.count }.to(0)
      end
    end
  end
end
