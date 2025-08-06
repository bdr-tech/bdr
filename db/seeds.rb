# Sample data for BDR Basketball Daily Routine platform

# Load achievements
load Rails.root.join('db/seeds/achievements.rb')

# Create test users with complete profiles
User.find_or_create_by(email: "test1@basketball.com") do |user|
  user.assign_attributes(
    name: "김농구",
    nickname: "슛마스터",
    real_name: "김민수",
    phone: "010-1111-1111",
    height: 180,
    weight: 75,
    positions: [ "포인트가드", "슈팅가드" ],
    city: "서울특별시",
    district: "강남구",
    team_name: "강남 슛터즈",
    bio: "10년 경력의 포인트가드입니다. 정확한 패스와 3점슛이 장점입니다."
  )
end

User.find_or_create_by(email: "test2@basketball.com") do |user|
  user.assign_attributes(
    name: "이농구",
    nickname: "리바운드킹",
    real_name: "이대한",
    phone: "010-2222-2222",
    height: 190,
    weight: 85,
    positions: [ "파워포워드", "센터" ],
    city: "서울특별시",
    district: "서초구",
    team_name: "서초 리바운더즈",
    bio: "리바운드와 골밑 플레이 전문. 팀플레이를 중시하는 스타일입니다."
  )
end

# Create sample users (legacy)
users = [
  {
    name: "김농구",
    email: "kim.basketball@example.com",
    phone: "010-1234-5678",
    old_position: "PG",
    old_skill_level: 7,
    old_location: "서울"
  },
  {
    name: "이슛터",
    email: "lee.shooter@example.com",
    phone: "010-2345-6789",
    old_position: "SG",
    old_skill_level: 8,
    old_location: "서울"
  },
  {
    name: "박센터",
    email: "park.center@example.com",
    phone: "010-3456-7890",
    old_position: "C",
    old_skill_level: 6,
    old_location: "서울"
  }
]

users.each do |user_data|
  User.find_or_create_by(email: user_data[:email]) do |user|
    user.assign_attributes(user_data)
  end
end

# Create sample courts
courts = [
  {
    name: "강남 스포츠센터",
    address: "서울시 강남구 테헤란로 123",
    latitude: 37.4979,
    longitude: 127.0276,
    court_type: "indoor",
    capacity: 20,
    water_fountain: true,
    shower_available: true,
    parking_available: true,
    smoking_allowed: false,
    air_conditioning: true,
    locker_room: true,
    equipment_rental: true
  },
  {
    name: "한강공원 농구장",
    address: "서울시 영등포구 여의도동 한강공원",
    latitude: 37.5284,
    longitude: 126.9358,
    court_type: "outdoor",
    capacity: 16,
    water_fountain: true,
    shower_available: false,
    parking_available: true,
    smoking_allowed: true,
    air_conditioning: false,
    locker_room: false,
    equipment_rental: false
  },
  {
    name: "홍대 실내 농구장",
    address: "서울시 마포구 홍익로 94",
    latitude: 37.5563,
    longitude: 126.9236,
    court_type: "indoor",
    capacity: 12,
    water_fountain: true,
    shower_available: false,
    parking_available: false,
    smoking_allowed: false,
    air_conditioning: true,
    locker_room: false,
    equipment_rental: true
  },
  {
    name: "잠실 종합운동장",
    address: "서울시 송파구 올림픽로 25",
    latitude: 37.5145,
    longitude: 127.0724,
    court_type: "indoor",
    capacity: 30,
    water_fountain: true,
    shower_available: true,
    parking_available: true,
    smoking_allowed: false,
    air_conditioning: true,
    locker_room: true,
    equipment_rental: true
  }
]

courts.each do |court_data|
  Court.find_or_create_by(name: court_data[:name]) do |court|
    court.assign_attributes(court_data)
  end
end

# Create sample games
organizers = User.all.to_a
available_courts = Court.all.to_a

games_data = [
  {
    scheduled_at: 2.hours.from_now,
    status: "scheduled",
    max_players: 10,
    home_team_color: "흰색",
    away_team_color: "검은색"
  },
  {
    scheduled_at: 4.hours.from_now,
    status: "scheduled",
    max_players: 8,
    home_team_color: "빨간색",
    away_team_color: "파란색"
  },
  {
    scheduled_at: 1.day.from_now + 2.hours,
    status: "scheduled",
    max_players: 12,
    home_team_color: "노란색",
    away_team_color: "초록색"
  },
  {
    scheduled_at: 1.day.from_now + 6.hours,
    status: "scheduled",
    max_players: 6,
    home_team_color: "회색",
    away_team_color: "주황색"
  },
  {
    scheduled_at: 2.days.from_now + 3.hours,
    status: "scheduled",
    max_players: 14,
    home_team_color: "흰색",
    away_team_color: "보라색"
  }
]

games_data.each_with_index do |game_data, index|
  organizer = organizers[index % organizers.length]
  court = available_courts[index % available_courts.length]

  Game.find_or_create_by(
    court: court,
    organizer: organizer,
    scheduled_at: game_data[:scheduled_at]
  ) do |game|
    game.assign_attributes(game_data.except(:scheduled_at))
  end
end

puts "Sample data created successfully!"
puts "Users: #{User.count}"
puts "Courts: #{Court.count}"
puts "Games: #{Game.count}"
# Create sample posts
users = User.all
categories = Post::CATEGORIES.keys

sample_posts_data = [
  {
    title: "강남에서 같이 농구하실 분 모집합니다!",
    content: "주말마다 강남 스포츠센터에서 농구하는 모임입니다.\n\n초보자도 환영하고, 실력보다는 재미와 운동이 목적입니다.\n매주 토요일 오후 2시에 모이고 있어요.\n\n관심 있으시면 댓글 남겨주세요!",
    category: "자유게시판",
    image1: "https://example.com/basketball1.jpg"
  },
  {
    title: "농구화 판매합니다 (나이키 에어조던)",
    content: "나이키 에어조던 1 레트로 하이 판매합니다.\n\n- 사이즈: 270mm\n- 색상: 화이트/블랙\n- 상태: 거의 새것 (3-4회 착용)\n- 가격: 15만원 (정가 18만원)\n\n서울 지역 직거래 선호합니다.\n연락주세요!",
    category: "중고거래",
    image1: "https://example.com/shoes1.jpg",
    image2: "https://example.com/shoes2.jpg"
  },
  {
    title: "🏀 한강 농구팀 '리버사이드' 팀원 모집",
    content: "안녕하세요! 한강공원에서 활동하는 농구팀 '리버사이드'입니다.\n\n저희 팀은:\n- 매주 일요일 오후 3시 활동\n- 20-30대 위주 (실력 무관)\n- 친목과 건강한 운동이 목적\n- 현재 8명, 4-5명 더 모집\n\n농구를 사랑하고 함께 즐기실 분들의 연락을 기다립니다!\n\n팀 소개:\n- 창단: 2023년\n- 평균 연령: 26세\n- 활동 지역: 한강공원 여의도 농구장",
    category: "팀소개"
  },
  {
    title: "잠실 종합운동장 농구코트 후기",
    content: "어제 잠실 종합운동장 실내 농구장을 이용해봤습니다.\n\n👍 좋은 점:\n- 시설이 정말 깨끗하고 최신식\n- 에어컨이 잘 되어 있음\n- 주차장 넓음\n- 샤워실과 락커룸 완비\n- 농구공과 조끼 대여 가능\n\n👎 아쉬운 점:\n- 예약이 어려움 (인기가 많아서)\n- 이용료가 다소 비쌈 (2시간에 8만원)\n- 주말에는 사람이 너무 많음\n\n전체적으로는 만족스러운 시설이었습니다.\n특히 시설이 깨끗해서 기분 좋게 운동할 수 있었어요!",
    category: "농구코트정보",
    image1: "https://example.com/court1.jpg"
  },
  {
    title: "농구 초보자 질문드립니다",
    content: "농구를 시작한 지 한 달 된 초보입니다.\n\n드리블 연습을 하고 있는데, 왼손 드리블이 너무 어려워요.\n어떻게 연습하면 좋을까요?\n\n그리고 슛 폼도 교정하고 싶은데, 좋은 방법 있으면 알려주세요!\n\n초보자도 환영하는 모임이 있다면 소개해주세요.",
    category: "자유게시판"
  },
  {
    title: "농구공 추천 부탁드립니다",
    content: "집 근처 실외 코트에서 연습용으로 쓸 농구공을 사려고 합니다.\n\n- 예산: 5-7만원\n- 용도: 실외 코트 연습\n- 브랜드: 상관없음\n\n어떤 제품이 좋을까요?\n경험담이나 추천 제품 있으면 댓글로 알려주세요!",
    category: "중고거래"
  }
]

sample_posts_data.each_with_index do |post_data, index|
  user = users[index % users.length]

  post = Post.find_or_create_by(
    title: post_data[:title],
    user: user
  ) do |p|
    p.assign_attributes(post_data.except(:title))
    p.views_count = rand(10..100)
  end

  # Create sample comments for each post
  if post.persisted?
    # Root comments
    2.times do |i|
      commenter = users[(index + i + 1) % users.length]
      comment_content = case i
      when 0
                         "좋은 글이네요! 저도 관심있습니다."
      when 1
                         "정보 감사합니다. 도움이 됐어요!"
      end

      root_comment = Comment.find_or_create_by(
        post: post,
        user: commenter,
        content: comment_content,
        parent_id: nil
      )

      # Add a reply to the first comment
      if i == 0 && root_comment.persisted?
        replier = users[(index + 2) % users.length]
        Comment.find_or_create_by(
          post: post,
          user: replier,
          content: "저도 같은 생각입니다! 함께해요~",
          parent: root_comment
        )
      end
    end
  end
end

puts ""
puts "=== 테스트 계정 정보 ==="
puts "1. 이메일: test1@basketball.com"
puts "   이름: 김농구 (슛마스터)"
puts "   프로필: 완성된 상태"
puts ""
puts "2. 이메일: test2@basketball.com"
puts "   이름: 이농구 (리바운드킹)"
puts "   프로필: 완성된 상태"
puts ""
# Create Korean location data
korean_locations = [
  # 서울특별시
  { city: '서울특별시', district: '강남구' },
  { city: '서울특별시', district: '강동구' },
  { city: '서울특별시', district: '강북구' },
  { city: '서울특별시', district: '강서구' },
  { city: '서울특별시', district: '관악구' },
  { city: '서울특별시', district: '광진구' },
  { city: '서울특별시', district: '구로구' },
  { city: '서울특별시', district: '금천구' },
  { city: '서울특별시', district: '노원구' },
  { city: '서울특별시', district: '도봉구' },
  { city: '서울특별시', district: '동대문구' },
  { city: '서울특별시', district: '동작구' },
  { city: '서울특별시', district: '마포구' },
  { city: '서울특별시', district: '서대문구' },
  { city: '서울특별시', district: '서초구' },
  { city: '서울특별시', district: '성동구' },
  { city: '서울특별시', district: '성북구' },
  { city: '서울특별시', district: '송파구' },
  { city: '서울특별시', district: '양천구' },
  { city: '서울특별시', district: '영등포구' },
  { city: '서울특별시', district: '용산구' },
  { city: '서울특별시', district: '은평구' },
  { city: '서울특별시', district: '종로구' },
  { city: '서울특별시', district: '중구' },
  { city: '서울특별시', district: '중랑구' },

  # 부산광역시
  { city: '부산광역시', district: '강서구' },
  { city: '부산광역시', district: '금정구' },
  { city: '부산광역시', district: '남구' },
  { city: '부산광역시', district: '동구' },
  { city: '부산광역시', district: '동래구' },
  { city: '부산광역시', district: '부산진구' },
  { city: '부산광역시', district: '북구' },
  { city: '부산광역시', district: '사상구' },
  { city: '부산광역시', district: '사하구' },
  { city: '부산광역시', district: '서구' },
  { city: '부산광역시', district: '수영구' },
  { city: '부산광역시', district: '연제구' },
  { city: '부산광역시', district: '영도구' },
  { city: '부산광역시', district: '중구' },
  { city: '부산광역시', district: '해운대구' },
  { city: '부산광역시', district: '기장군' },

  # 대구광역시
  { city: '대구광역시', district: '남구' },
  { city: '대구광역시', district: '달서구' },
  { city: '대구광역시', district: '달성군' },
  { city: '대구광역시', district: '동구' },
  { city: '대구광역시', district: '북구' },
  { city: '대구광역시', district: '서구' },
  { city: '대구광역시', district: '수성구' },
  { city: '대구광역시', district: '중구' },

  # 인천광역시
  { city: '인천광역시', district: '계양구' },
  { city: '인천광역시', district: '남동구' },
  { city: '인천광역시', district: '동구' },
  { city: '인천광역시', district: '미추홀구' },
  { city: '인천광역시', district: '부평구' },
  { city: '인천광역시', district: '서구' },
  { city: '인천광역시', district: '연수구' },
  { city: '인천광역시', district: '중구' },
  { city: '인천광역시', district: '강화군' },
  { city: '인천광역시', district: '옹진군' },

  # 경기도 주요 지역
  { city: '경기도', district: '수원시' },
  { city: '경기도', district: '성남시' },
  { city: '경기도', district: '고양시' },
  { city: '경기도', district: '용인시' },
  { city: '경기도', district: '부천시' },
  { city: '경기도', district: '안산시' },
  { city: '경기도', district: '안양시' },
  { city: '경기도', district: '남양주시' },
  { city: '경기도', district: '화성시' },
  { city: '경기도', district: '평택시' },
  { city: '경기도', district: '의정부시' },
  { city: '경기도', district: '시흥시' },
  { city: '경기도', district: '파주시' },
  { city: '경기도', district: '김포시' },
  { city: '경기도', district: '광명시' },
  { city: '경기도', district: '광주시' },
  { city: '경기도', district: '군포시' },
  { city: '경기도', district: '오산시' },
  { city: '경기도', district: '이천시' },
  { city: '경기도', district: '양주시' },
  { city: '경기도', district: '구리시' },
  { city: '경기도', district: '포천시' },
  { city: '경기도', district: '동두천시' },
  { city: '경기도', district: '과천시' },
  { city: '경기도', district: '연천군' },
  { city: '경기도', district: '가평군' },
  { city: '경기도', district: '양평군' }
]

korean_locations.each do |location_data|
  Location.find_or_create_by(
    city: location_data[:city],
    district: location_data[:district]
  ) do |location|
    location.full_name = "#{location_data[:city]} #{location_data[:district]}"
  end
end

puts "=== 커뮤니티 데이터 ==="
puts "Posts: #{Post.count}"
puts "Comments: #{Comment.count}"
puts ""
puts "=== 지역 데이터 ==="
puts "Locations: #{Location.count}"
