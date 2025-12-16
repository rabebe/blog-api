class PostsController < ApplicationController
  skip_before_action :authenticate_request, only: [ :index, :show, :search ]
  before_action :authenticate_request, except: [ :index, :show, :search ]
  before_action :authorize_admin, except: [ :index, :show, :search ]
  before_action :set_post, only: [ :show, :update, :destroy ]

  # GET /posts?page=1&limit=5
  def index
    page = params[:page].to_i.positive? ? params[:page].to_i : 1
    limit = params[:limit].to_i.positive? ? params[:limit].to_i : 5
    offset = (page - 1) * limit

    @posts = Post.order(created_at: :desc).offset(offset).limit(limit)
    render json: @posts
  end

  # GET /posts/id
  def show
    render json: @post
  end

  # GET /posts/search?q=keyword
  def search
    if params[:q].present?
      @posts = Post.where("keywords @> ARRAY[?]::varchar[]", params[:q])
      render json: @posts
    else
      render json: { error: "Query parameter 'q' required" }, status: :bad_request
    end
  end

  # POST /posts
  def create
    @post = Post.new(post_params)
    if @post.save
      render json: @post, status: :created
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/:id
  def update
    if @post.update(post_params)
      render json: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # DELETE /posts/:id
  def destroy
    @post.destroy!
    head :no_content
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body, :user_id, keywords: [])
  end

  def authorize_admin
    unless @current_user&.admin?
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
