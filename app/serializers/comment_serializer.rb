class CommentSerializer < ActiveModel::Serializer
  attributes :id, :content, :post_id, :user_id, :mine

  def mine
    object.user == scope
  end
end
