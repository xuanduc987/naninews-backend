class CommentsController < ApplicationController
  before_action :set_comment, only: [:show]
  before_action :set_post, only: [:index, :create]
  before_action :authenticate, except: [:index, :show]

  # GET posts/1/comments
  def index
    @comments = @post.comments

    render json: @comments
  end

  # GET /comments/1
  def show
    render_json_or_404 @comment
  end

  # POST /comments
  def create
    return head :not_found unless @post
    @comment = @post.comments.build(comment_params)
    @comment.user = @current_user

    if @comment.save
      render json: @comment, status: :created, location: @comment
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # PUT /comments/1
  def update(id)
    @comment = @current_user.comments.find_by(id: id)

    if @comment && @comment.update_attributes(comment_params)
      head :no_content
    else
      render json: @comment.try(:errors), status: :unprocessable_entity
    end
  end

  # DELETE /comments/1
  def destroy(id)
    @comment = @current_user.comments.find_by(id: id)

    if @comment
      @comment.destroy

      head :no_content
    else
      head :unprocessable_entity
    end
  end

  private

  def set_comment
    @comment = Comment.find_by(id: params[:id])
  end

  def set_post
    @post = Post.find_by(id: params[:post_id])
  end

  def comment_params
    params[:comment] ? params[:comment].permit(:content) : {}
  end
end
