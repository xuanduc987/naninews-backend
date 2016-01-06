class User < ActiveRecord::Base
  EMAIL_REGEX = /\A\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*\z/

  has_secure_password
  has_many :api_tokens
  has_many :posts

  validates :email, format: { with: EMAIL_REGEX }, uniqueness: true
  validates :name, presence: true
end
