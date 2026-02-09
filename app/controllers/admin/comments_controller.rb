module Admin
  class Admin::CommentsController < ApplicationController
    before_action :authenticate_request
    before_action :authorize_admin
    before_action :set_comment, only: [ :approve, :reject ]

    # GET /admin/comments
    def index
      comments = Comment.includes(:user).where(status: 0).order(created_at: :asc)
      render json: comments.as_json(include: { user: { only: :username } })
    end

    # PATCH /admin/comments/:id/approve
    def approve
      @comment.update!(status: 1)
      render json: {
        message: "Comment approved",
        comment: @comment
      }
    end

    # DELETE /admin/comments/:id/reject
    def reject
      @comment.destroy
      render json: { message: "Comment rejected and deleted" }
    end

    private

    def set_comment
      @comment = Comment.find(params[:id])
    end
  end
end
