class PostSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :title, :url, :slug, :votes_count, :voted,
    :comments_count

  def voted
    scope ? scope.voted_for?(object) : false
  end
end
