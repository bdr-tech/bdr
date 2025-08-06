class CommunityController < ApplicationController
  def index
    @recent_posts = Post.recent.includes(:user).limit(10)
    @categories_stats = Post.group(:category).count
  end

  def free_board
    @posts = filter_posts("자유게시판")
    @category = "자유게시판"
    render "board"
  end

  def marketplace
    @posts = filter_posts("중고거래")
    @category = "중고거래"
    render "board"
  end

  def teams
    @posts = filter_posts("팀소개")
    @category = "팀소개"
    render "board"
  end

  def courts_info
    @posts = filter_posts("농구코트정보")
    @category = "농구코트정보"
    render "board"
  end

  def new_post
    redirect_to new_post_path
  end

  private

  def filter_posts(category)
    posts = Post.by_category(category).recent.includes(:user)

    if params[:search].present?
      case params[:search_type]
      when "author"
        posts = posts.joins(:user).where("users.nickname LIKE ? OR users.name LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
      when "title"
        posts = posts.where("title LIKE ?", "%#{params[:search]}%")
      when "title_content"
        posts = posts.where("title LIKE ? OR content LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
      end
    end

    posts.limit(20)
  end
end
