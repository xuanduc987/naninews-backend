require "rails_helper"

RSpec.describe Comment, type: :model do
  it { should validate_presence_of(:post) }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:content) }
end
