class LikesController < ApplicationController
  # Ensure the user is logged in before they can like/unlike
  before_action :authenticate_request
  before_action :set_post

  # POST /posts/:post_id/like
  # This acts as a "Create" or "Ensure Exists" action
  def create
    # find_or_create_by ensures we don't create duplicates even if clicked fast
    like = @post.likes.find_or_create_by(user: @current_user)

    if like.persisted?
      render json: {
        message: "Post liked",
        likes_count: @post.likes.count,
        liked: true
      }, status: :ok
    else
      render json: { error: "Unable to like post" }, status: :unprocessable_entity
    end
  end

  # DELETE /posts/:post_id/like
  def destroy
    like = @post.likes.find_by(user: @current_user)

    if like&.destroy
      render json: {
        message: "Like removed",
        likes_count: @post.likes.count,
        liked: false
      }, status: :ok
    else
      render json: { error: "Like not found" }, status: :not_found
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Post not found" }, status: :not_found
  end
end
