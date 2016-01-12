class PostDetailSerializer < PostSerializer
  has_many :comments
end
