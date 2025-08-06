# 업적 데이터 시드

# 참가 업적
Achievement.find_or_create_by(name: "첫 경기 참가") do |a|
  a.description = "첫 번째 경기에 참가했습니다"
  a.icon = "🏀"
  a.category = "participation"
end

Achievement.find_or_create_by(name: "주말 전사") do |a|
  a.description = "주말 경기 10회 참가"
  a.icon = "🌟"
  a.category = "participation"
end

Achievement.find_or_create_by(name: "농구 중독자") do |a|
  a.description = "한 달에 20회 이상 경기 참가"
  a.icon = "🔥"
  a.category = "participation"
end

Achievement.find_or_create_by(name: "백전노장") do |a|
  a.description = "총 100회 경기 참가"
  a.icon = "💯"
  a.category = "participation"
end

# 호스트 업적
Achievement.find_or_create_by(name: "첫 경기 주최") do |a|
  a.description = "첫 번째 경기를 주최했습니다"
  a.icon = "🎯"
  a.category = "host"
end

Achievement.find_or_create_by(name: "인기 호스트") do |a|
  a.description = "주최한 경기가 10분 내 마감"
  a.icon = "⚡"
  a.category = "host"
end

Achievement.find_or_create_by(name: "베스트 호스트") do |a|
  a.description = "호스트 평점 4.8 이상 달성"
  a.icon = "👑"
  a.category = "host"
end

Achievement.find_or_create_by(name: "대회 주최자") do |a|
  a.description = "첫 대회 개최"
  a.icon = "🏆"
  a.category = "host"
end

# 소셜 업적
Achievement.find_or_create_by(name: "첫 친구") do |a|
  a.description = "첫 번째 팔로우 달성"
  a.icon = "👥"
  a.category = "social"
end

Achievement.find_or_create_by(name: "인플루언서") do |a|
  a.description = "팔로워 100명 달성"
  a.icon = "📢"
  a.category = "social"
end

Achievement.find_or_create_by(name: "평가왕") do |a|
  a.description = "50회 이상 경기 평가 작성"
  a.icon = "⭐"
  a.category = "social"
end

Achievement.find_or_create_by(name: "도움왕") do |a|
  a.description = "커뮤니티 게시글 100개 작성"
  a.icon = "💬"
  a.category = "social"
end

# 실력 업적
Achievement.find_or_create_by(name: "라이징 스타") do |a|
  a.description = "평점 4.0 이상 달성"
  a.icon = "🌠"
  a.category = "skill"
end

Achievement.find_or_create_by(name: "MVP") do |a|
  a.description = "한 달 MVP 선정"
  a.icon = "🏅"
  a.category = "skill"
end

Achievement.find_or_create_by(name: "3점 저격수") do |a|
  a.description = "3점슛 성공률 40% 이상 (최소 50개)"
  a.icon = "🎯"
  a.category = "skill"
end

Achievement.find_or_create_by(name: "철벽 수비") do |a|
  a.description = "경기 평균 스틸 3개 이상"
  a.icon = "🛡️"
  a.category = "skill"
end

# 특별 업적
Achievement.find_or_create_by(name: "얼리버드") do |a|
  a.description = "베타 테스트 참가자"
  a.icon = "🐦"
  a.category = "special"
end

Achievement.find_or_create_by(name: "프리미엄 멤버") do |a|
  a.description = "프리미엄 멤버십 가입"
  a.icon = "💎"
  a.category = "special"
end

Achievement.find_or_create_by(name: "1주년 멤버") do |a|
  a.description = "BDR 가입 1주년"
  a.icon = "🎂"
  a.category = "special"
end

Achievement.find_or_create_by(name: "올스타") do |a|
  a.description = "BDR 올스타전 참가"
  a.icon = "✨"
  a.category = "special"
end

puts "Created #{Achievement.count} achievements"
