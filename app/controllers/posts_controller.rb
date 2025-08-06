class PostsController < ApplicationController
  before_action :require_login, except: [ :index, :show ]
  before_action :set_post, only: [ :show, :edit, :update, :destroy ]

  def index
    @posts = Post.includes(:user)
    @posts = @posts.by_category(params[:category]) if params[:category].present?
    @posts = @posts.recent.limit(20)
  end

  def show
    @post.increment_views!
    @comments = @post.comments.threaded_comments
    @comment = Comment.new
  end

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      redirect_to @post, notice: "게시글이 성공적으로 작성되었습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    redirect_to @post, alert: "수정 권한이 없습니다." unless can_edit?
  end

  def update
    redirect_to @post, alert: "수정 권한이 없습니다." and return unless can_edit?

    if @post.update(post_params)
      redirect_to @post, notice: "게시글이 수정되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    redirect_to posts_path, alert: "삭제 권한이 없습니다." and return unless can_edit?

    @post.destroy
    redirect_to posts_path, notice: "게시글이 삭제되었습니다."
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content, :category, :image1, :image2)
  end

  def can_edit?
    current_user && (@post.user == current_user)
  end
end
