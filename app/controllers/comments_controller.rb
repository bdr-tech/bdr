class CommentsController < ApplicationController
  before_action :require_login
  before_action :set_post
  before_action :set_comment, only: [ :edit, :update, :destroy ]

  def new
    @comment = @post.comments.build
    @parent_comment = Comment.find(params[:parent_id]) if params[:parent_id]
  end

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    if params[:parent_id].present?
      @parent_comment = Comment.find(params[:parent_id])
      @comment.parent = @parent_comment
    end

    if @comment.save
      redirect_to @post, notice: "댓글이 작성되었습니다."
    else
      redirect_to @post, alert: "댓글 작성에 실패했습니다."
    end
  end

  def edit
    redirect_to @post, alert: "수정 권한이 없습니다." unless can_edit?
  end

  def update
    redirect_to @post, alert: "수정 권한이 없습니다." and return unless can_edit?

    if @comment.update(comment_params)
      redirect_to @post, notice: "댓글이 수정되었습니다."
    else
      redirect_to @post, alert: "댓글 수정에 실패했습니다."
    end
  end

  def destroy
    redirect_to @post, alert: "삭제 권한이 없습니다." and return unless can_edit?

    @comment.destroy
    redirect_to @post, notice: "댓글이 삭제되었습니다."
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end

  def can_edit?
    current_user && (@comment.user == current_user)
  end
end
