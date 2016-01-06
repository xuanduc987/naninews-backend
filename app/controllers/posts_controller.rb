class PostsController < ApplicationController
  before_action :set_post, only: [:show]
  before_action :authenticate, except: [:index, :show]

  # GET /posts
  # GET /posts.json
  def index(slug: nil)
    if slug.present?
      @post = Post.find_by(slug: slug)

      render_json_or_404 @post
    else
      @posts = Post.all

      render json: @posts
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    render_json_or_404 @post
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = @user.posts.build(post_params)

    if @post.save
      render json: @post, status: :created, location: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    @post = @user.posts.find_by(id: params[:id])

    if @post && @post.update_attributes(post_params.merge(slug: ""))
      head :no_content
    else
      render json: @post.try(:errors), status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post = @user.posts.find_by(id: params[:id])

    if @post
      @post.destroy

      head :no_content
    else
      head :unprocessable_entity
    end
  end

  private

  def set_post
    @post = Post.find_by(id: params[:id])
  end

  def post_params
    params[:post] ? params[:post].permit(:url, :title) : {}
  end

  def render_json_or_404(content)
    if content
      render json: content
    else
      head :not_found
    end
  end
end
