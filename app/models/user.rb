class User < ActiveRecord::Base
  EMAIL_REGEX = /\A\s*([^@\\s]{1,64})@((?:[-\p{L}\d]+\.)+\p{L}{2,})\s*\z/i

  has_secure_password

  validates :email, format: { with: EMAIL_REGEX }, uniqueness: true
  validates :name, presence: true
end
