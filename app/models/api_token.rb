class ApiToken < ActiveRecord::Base
  belongs_to :user

  validates :token, :user, presence: true

  after_initialize do
    generate_access_token if self.new_record?
  end

  private

  def generate_access_token
    loop do
      self.token = SecureRandom.hex
      break unless self.class.exists?(token: token)
    end
  end
end
