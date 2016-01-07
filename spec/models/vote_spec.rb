require "rails_helper"
require "support/factory_girl"

RSpec.describe Vote, type: :model do
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:post) }
end
