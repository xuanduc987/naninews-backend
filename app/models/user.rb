class User < ActiveRecord::Base
  EMAIL_REGEX = /\A\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*\z/

  has_secure_password
  has_many :api_tokens, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :email, format: { with: EMAIL_REGEX }, uniqueness: true
  validates :name, presence: true

  def voted_for?(post)
    votes.where(post: post).exists?
  end

  def vote_for(post)
    votes.first_or_create(post: post)
  end

  def unvote_for(post)
    votes.where(post: post).destroy_all
  end
end
