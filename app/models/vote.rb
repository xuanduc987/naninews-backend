class Vote < ActiveRecord::Base
  belongs_to :post
  counter_culture :post
  belongs_to :user

  validates :post, :user, presence: true
end
