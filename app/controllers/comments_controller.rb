class CommentsController < ApplicationController
  skip_before_action :authenticate_request, only: [ :index ]

  before_action :authenticate_request, only: [ :create, :destroy ]
  before_action :set_post, only: [ :index, :create, :destroy ]
  before_action :set_comment, only: [ :destroy ]


  # GET /posts/:post_id/comments
  def index
    @comments = @post.comments.where(status: 1).order(created_at: :desc)
    render json: @comments.as_json(include: { user: { only: :name } })
  end

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

  # DELETE /posts/:post_id/comments/:id
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
    @comment = @post.comments.find(params[:id])
  end

  def owns_comment?
    @comment.user_id == current_user.id
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
