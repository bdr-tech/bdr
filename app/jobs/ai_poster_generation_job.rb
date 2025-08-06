class AIPosterGenerationJob < ApplicationJob
  queue_as :default

  def perform(tournament_id)
    tournament = Tournament.find(tournament_id)
    return if tournament.ai_poster_generated?

    # AI 포스터 생성 기록 시작
    generation = AIPosterGeneration.create!(
      tournament: tournament,
      status: "processing",
      prompt: generate_prompt(tournament)
    )

    begin
      # DALL-E API 호출 (실제 구현 시 OpenAI 클라이언트 사용)
      poster_url = generate_poster_with_ai(tournament, generation.prompt)

      # 포스터 URL 저장
      tournament.update!(
        poster_url: poster_url,
        ai_poster_generated: true
      )

      generation.update!(
        status: "completed",
        result_url: poster_url,
        completed_at: Time.current
      )

      # 주최자에게 알림
      Notification.create!(
        user: tournament.organizer,
        notification_type: "ai_poster_ready",
        related: tournament,
        content: "#{tournament.name} 대회의 AI 포스터가 생성되었습니다."
      )

    rescue => e
      generation.update!(
        status: "failed",
        error_message: e.message,
        completed_at: Time.current
      )

      Rails.logger.error "AI Poster Generation Failed: #{e.message}"
      raise e
    end
  end

  private

  def generate_prompt(tournament)
    base_prompt = "농구 대회 포스터를 생성해주세요. "

    if tournament.template_used.present?
      template = TournamentTemplate.find_by(name: tournament.template_used)
      if template&.poster_prompt_template.present?
        return template.poster_prompt_template
          .gsub("{name}", tournament.name)
          .gsub("{venue}", tournament.venue)
          .gsub("{date}", tournament.tournament_start_at.strftime("%Y년 %m월 %d일"))
          .gsub("{teams}", tournament.max_teams.to_s)
      end
    end

    # 기본 프롬프트
    base_prompt + <<~PROMPT
      대회명: #{tournament.name}
      장소: #{tournament.venue}
      날짜: #{tournament.tournament_start_at.strftime('%Y년 %m월 %d일')}
      참가팀: 최대 #{tournament.max_teams}팀

      스타일: 모던하고 다이나믹한 농구 테마
      색상: 빨강, 파랑, 검정을 주요 색상으로 사용
      포함 요소: 농구공, 코트, 선수 실루엣
      텍스트: 대회명과 날짜를 명확하게 표시
    PROMPT
  end

  def generate_poster_with_ai(tournament, prompt)
    # 실제 구현 시 OpenAI DALL-E API 호출
    # 임시로 placeholder URL 반환
    "https://placeholder.com/poster/#{tournament.id}.jpg"

    # 실제 구현 예시:
    # client = OpenAI::Client.new
    # response = client.images.generate(
    #   model: "dall-e-3",
    #   prompt: prompt,
    #   size: "1024x1024",
    #   quality: "standard"
    # )
    # response.dig("data", 0, "url")
  end
end
