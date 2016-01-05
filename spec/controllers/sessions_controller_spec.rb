require "rails_helper"

RSpec.describe SessionsController, type: :controller do
  it { should route(:get, "/authenticate").to(action: :authenticate) }
end
