require "rails_helper"

RSpec.describe VotesController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(post: "/posts/1/votes").to route_to("votes#create", post_id: "1")
    end
  end
end
