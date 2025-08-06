class TournamentPostersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tournament
  before_action :authorize_poster_creation, only: %i[new create]

  # 포스터 갤러리
  def index
    @posters = @tournament.tournament_media
                         .posters
                         .includes(:user)
                         .order(created_at: :desc)
  end

  # 새 포스터 만들기
  def new
    @templates = poster_templates
    @poster = @tournament.tournament_media.build(media_type: "poster")
  end

  # 포스터 생성
  def create
    template = poster_templates.find { |t| t[:id] == params[:template_id] }

    if template
      poster_data = generate_poster(template)

      @poster = @tournament.tournament_media.build(
        user: current_user,
        media_type: "poster",
        title: params[:title] || "#{@tournament.name} 포스터",
        description: params[:description],
        file_url: poster_data[:url],
        metadata: {
          template_id: template[:id],
          settings: params[:settings]
        }
      )

      if @poster.save
        redirect_to tournament_poster_path(@tournament, @poster),
                    notice: "포스터가 생성되었습니다!"
      else
        flash.now[:alert] = "포스터 생성 중 오류가 발생했습니다."
        render :new
      end
    else
      redirect_to new_tournament_poster_path(@tournament),
                  alert: "잘못된 템플릿입니다."
    end
  end

  # 포스터 상세
  def show
    @poster = @tournament.tournament_media.posters.find(params[:id])
    @poster.increment_view!
  end

  # 포스터 다운로드
  def download
    @poster = @tournament.tournament_media.posters.find(params[:id])

    # 다운로드 통계 기록
    @poster.increment!(:downloads_count) if @poster.respond_to?(:downloads_count)

    redirect_to @poster.file_url, allow_other_host: true
  end

  private

  def set_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end

  def authorize_poster_creation
    unless current_user == @tournament.organizer || current_user.admin?
      redirect_to tournament_posters_path(@tournament),
                  alert: "포스터를 만들 권한이 없습니다."
    end
  end

  def poster_templates
    [
      {
        id: "modern",
        name: "모던 스타일",
        preview: "/assets/poster_templates/modern.png",
        layouts: %w[portrait landscape square story],
        colors: %w[#FF6B6B #4ECDC4 #45B7D1 #F7DC6F #BB8FCE]
      },
      {
        id: "classic",
        name: "클래식 스타일",
        preview: "/assets/poster_templates/classic.png",
        layouts: %w[portrait landscape],
        colors: %w[#2C3E50 #E74C3C #3498DB #F39C12 #27AE60]
      },
      {
        id: "minimal",
        name: "미니멀 스타일",
        preview: "/assets/poster_templates/minimal.png",
        layouts: %w[portrait square],
        colors: %w[#000000 #FFFFFF #333333 #666666 #999999]
      },
      {
        id: "dynamic",
        name: "다이나믹 스타일",
        preview: "/assets/poster_templates/dynamic.png",
        layouts: %w[portrait landscape story],
        colors: %w[#FF1744 #00E676 #FFEA00 #2979FF #FF6D00]
      }
    ]
  end

  def generate_poster(template)
    # 실제로는 이미지 생성 서비스 호출
    # 여기서는 간단한 예시
    poster_service = TournamentPosterService.new(@tournament, template)
    poster_url = poster_service.generate(
      layout: params[:layout] || "portrait",
      color_scheme: params[:color] || template[:colors].first,
      include_logo: params[:include_logo] == "true",
      custom_text: params[:custom_text]
    )

    { url: poster_url }
  end
end
