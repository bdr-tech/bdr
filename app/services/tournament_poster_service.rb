require "rmagick"
require "rqrcode"

class TournamentPosterService
  include Rails.application.routes.url_helpers

  def initialize(tournament, template = nil)
    @tournament = tournament
    @template = template || default_template
  end

  def generate(options = {})
    layout = options[:layout] || "portrait"
    color_scheme = options[:color_scheme] || "#FF6B6B"

    case layout
    when "portrait"
      generate_portrait_poster(color_scheme, options)
    when "landscape"
      generate_landscape_poster(color_scheme, options)
    when "square"
      generate_square_poster(color_scheme, options)
    when "story"
      generate_story_poster(color_scheme, options)
    else
      generate_portrait_poster(color_scheme, options)
    end
  end

  def generate_async
    TournamentPosterJob.perform_later(@tournament.id, @template)
  end

  private

  def generate_portrait_poster(color_scheme, options)
    # 세로형 포스터 (1080x1920)
    canvas = Magick::Image.new(1080, 1920) do |img|
      img.background_color = "white"
    end

    draw = Magick::Draw.new

    # 배경 그라데이션
    gradient = Magick::Image.read("gradient:#{color_scheme}-#FFFFFF") do |img|
      img.size = "1080x1920"
    end.first
    canvas = canvas.composite(gradient, 0, 0, Magick::OverCompositeOp)

    # 헤더 영역
    draw_header(draw, color_scheme)

    # 대회 정보
    draw_tournament_info(draw)

    # QR 코드
    add_qr_code(canvas) if options[:include_qr]

    # 로고 추가
    add_logo(canvas) if options[:include_logo]

    # 이미지 저장
    filename = "tournament_#{@tournament.id}_#{Time.current.to_i}.png"
    path = Rails.root.join("public", "posters", filename)
    FileUtils.mkdir_p(File.dirname(path))

    draw.draw(canvas)
    canvas.write(path)

    "/posters/#{filename}"
  end

  def generate_landscape_poster(color_scheme, options)
    # 가로형 포스터 (1920x1080)
    canvas = Magick::Image.new(1920, 1080) do |img|
      img.background_color = "white"
    end

    draw = Magick::Draw.new

    # 배경
    draw.fill = color_scheme
    draw.rectangle(0, 0, 1920, 300)

    # 대회명
    draw.fill = "white"
    draw.font_family = "Arial"
    draw.font_weight = Magick::BoldWeight
    draw.pointsize = 80
    draw.gravity = Magick::WestGravity
    draw.text(100, -340, @tournament.name)

    # 정보 영역
    draw.fill = "#333333"
    draw.pointsize = 40
    y_position = 400

    tournament_details.each do |detail|
      draw.text(100, y_position, detail)
      y_position += 60
    end

    # 이미지 저장
    filename = "tournament_landscape_#{@tournament.id}_#{Time.current.to_i}.png"
    path = Rails.root.join("public", "posters", filename)
    FileUtils.mkdir_p(File.dirname(path))

    draw.draw(canvas)
    canvas.write(path)

    "/posters/#{filename}"
  end

  def generate_square_poster(color_scheme, options)
    # 정사각형 포스터 (1080x1080)
    canvas = Magick::Image.new(1080, 1080) do |img|
      img.background_color = color_scheme
    end

    draw = Magick::Draw.new

    # 중앙 정렬 텍스트
    draw.fill = "white"
    draw.font_family = "Arial"
    draw.font_weight = Magick::BoldWeight
    draw.pointsize = 60
    draw.gravity = Magick::CenterGravity

    # 대회명
    draw.text(0, -200, @tournament.name)

    # 날짜
    draw.pointsize = 40
    draw.text(0, -100, @tournament.tournament_start_at.strftime("%Y년 %m월 %d일"))

    # 장소
    draw.text(0, -40, @tournament.venue_name) if @tournament.venue_name

    # 참가비
    draw.pointsize = 50
    draw.text(0, 40, "참가비: #{number_to_currency(@tournament.entry_fee)}")

    # 이미지 저장
    filename = "tournament_square_#{@tournament.id}_#{Time.current.to_i}.png"
    path = Rails.root.join("public", "posters", filename)
    FileUtils.mkdir_p(File.dirname(path))

    draw.draw(canvas)
    canvas.write(path)

    "/posters/#{filename}"
  end

  def generate_story_poster(color_scheme, options)
    # 스토리형 포스터 (1080x1920)
    generate_portrait_poster(color_scheme, options.merge(story_format: true))
  end

  def draw_header(draw, color_scheme)
    draw.fill = color_scheme
    draw.rectangle(0, 0, 1080, 400)

    draw.fill = "white"
    draw.font_family = "Arial"
    draw.font_weight = Magick::BoldWeight
    draw.pointsize = 70
    draw.gravity = Magick::NorthGravity
    draw.text(0, 150, @tournament.name)
  end

  def draw_tournament_info(draw)
    draw.fill = "#333333"
    draw.font_family = "Arial"
    draw.pointsize = 40
    draw.gravity = Magick::NorthWestGravity

    y_position = 500
    tournament_details.each do |detail|
      draw.text(100, y_position, detail)
      y_position += 80
    end
  end

  def tournament_details
    details = []
    details << "📅 #{@tournament.tournament_start_at.strftime('%Y년 %m월 %d일 %H시')}"
    details << "📍 #{@tournament.venue_name}" if @tournament.venue_name
    details << "👥 #{@tournament.min_teams}~#{@tournament.max_teams}팀"
    details << "💰 참가비: #{number_to_currency(@tournament.entry_fee)}"
    details << "🏀 경기방식: #{game_type_korean}"
    details << "🏆 상금: #{prize_info}" if @tournament.prizes_info.present?
    details
  end

  def add_qr_code(canvas)
    qr_url = tournament_url(@tournament)
    qr = RQRCode::QRCode.new(qr_url)
    qr_image = qr.as_png(size: 200)

    temp_file = Tempfile.new([ "qr", ".png" ])
    temp_file.binmode
    temp_file.write(qr_image.to_s)
    temp_file.close

    qr_magick = Magick::Image.read(temp_file.path).first
    canvas.composite!(qr_magick, 840, 1680, Magick::OverCompositeOp)

    temp_file.unlink
  end

  def add_logo(canvas)
    # BDR 로고 추가
    logo_path = Rails.root.join("app", "assets", "images", "bdr_logo.png")
    if File.exist?(logo_path)
      logo = Magick::Image.read(logo_path).first
      logo = logo.resize_to_fit(200, 100)
      canvas.composite!(logo, 50, 1800, Magick::OverCompositeOp)
    end
  end

  def game_type_korean
    case @tournament.game_type
    when "3x3" then "3대3"
    when "5x5" then "5대5"
    else @tournament.game_type
    end
  end

  def prize_info
    prizes = @tournament.prizes_info
    return "상품 있음" if prizes.blank?

    if prizes["first_place"]
      "1등 #{prizes['first_place']}"
    else
      "상품 있음"
    end
  end

  def number_to_currency(amount)
    return "무료" if amount == 0
    "#{amount.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}원"
  end

  def default_template
    {
      id: "default",
      colors: [ "#FF6B6B", "#4ECDC4", "#45B7D1" ]
    }
  end
end
