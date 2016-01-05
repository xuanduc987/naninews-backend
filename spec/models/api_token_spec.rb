require "rails_helper"

RSpec.describe ApiToken, type: :model do
  it { should validate_presence_of(:user) }

  it { should validate_presence_of(:token) }
end
