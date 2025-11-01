class PostsController < ApplicationController
  # Security gate: Blocks unauthorized users from editing/creating/deleting
  skip_before_action :authenticate_request, only: [ :index, :show ]

  before_action :authorize_admin, except: [ :index, :show ]
  # Find post for show, update, destroy actions
  before_action :set_post, only: %i[ show update destroy ]

  # GET /posts
  def index
    @posts = Post.all
    render json: @posts
  end

  # GET /posts/id
  def show
    render json: @post
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

  # PATCH/PUT /posts/1
  def update
    if @post.update(post_params)
      render json: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  def destroy
    @post.destroy!
    head :no_content
  end

  private
  # Use callbacks to share common setup or constraints between actions.

  def set_post
    @post = Post.find(params[:id])
  end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :body, :user_id)
    end
end
