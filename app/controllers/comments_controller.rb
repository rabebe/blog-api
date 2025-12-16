class CommentsController < ApplicationController
  before_action :authenticate_request
  before_action :set_post, only: [ :create ]
  before_action :set_comment, only: [ :destroy ]

  # POST /posts/:post_id/comments
  def create
  comment = @post.comments.build(
    comment_params.merge(
      user_id: current_user.id,
      status: 0 # pending
    )
  )

    if comment.save
      render json: {
        message: "Comment submitted for approval",
        comment: comment
      }, status: :created
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /comments/:id
  def destroy
    unless owns_comment? || current_user.admin?
      return render json: { error: "Unauthorized" }, status: :unauthorized
    end

    @comment.destroy
    head :no_content
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def owns_comment?
    @comment.user_id == current_user.id
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
