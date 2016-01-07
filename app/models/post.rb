class Post < ActiveRecord::Base
  belongs_to :user
  has_many :votes, dependent: :destroy

  validates :user, :title, :slug, :url, presence: true
  validates :slug, :url, uniqueness: true
  validate :valid_url

  before_validation :generate_slug

  private

  def generate_slug
    self.slug = title.try(:parameterize) if slug.blank?
  end

  def valid_url
    uri = URI.parse(url)
    errors[:url] << "is not an url" unless uri.is_a?(URI::HTTP)
  rescue URI::InvalidURIError
    errors[:url] << "is not an url"
  end
end
