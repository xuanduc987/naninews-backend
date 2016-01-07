class VotesController < ApplicationController
  before_action :set_post
  before_action :authenticate

  # POST /posts/1/votes
  # POST /posts/1/votes.json
  def create
    return head :not_found unless @post

    if %w(true false).include? params[:vote]
      vote = params[:vote] == "true"
      vote ? @current_user.vote_for(@post) : @current_user.unvote_for(@post)
      render json: { voted: vote }
    else
      render json: { vote: ["is not valid"] }, status: :unprocessable_entity
    end
  end

  private

  def set_post
    @post = Post.find_by(id: params[:post_id])
  end
end
