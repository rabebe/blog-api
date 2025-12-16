class LikesController < ApplicationController
  before_action :authenticate_request
  before_action :set_post

  # POST /posts/:post_id/like
  def create
    like = @post.likes.find_or_initialize_by(user: @current_user)

    if like.persisted?
      render json: { message: "Already liked", likes_count: @post.likes.count }, status: :ok
    else
      if like.save
        render json: { message: "Post liked", likes_count: @post.likes.count }, status: :created
      else
        render json: { error: like.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    end
  end

  # DELETE /posts/:post_id/like
  def destroy
    like = @post.likes.find_by(user: @current_user)
    if like&.destroy
      render json: { message: "Like removed", likes_count: @post.likes.count }, status: :ok
    else
      render json: { error: "Like not found" }, status: :not_found
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end
