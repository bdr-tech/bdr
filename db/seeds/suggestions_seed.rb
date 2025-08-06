# 건의사항 테스트 데이터 생성
puts "Creating test suggestions..."

# 사용자 확인 (첫 번째 사용자 사용 또는 새로 생성)
test_user = User.first || User.create!(
  email: 'test_user@example.com',
  name: '테스트 사용자',
  nickname: '테스터',
  phone: '010-1234-5678',
  status: 'active'
)

# 건의사항 데이터 생성
suggestions_data = [
  {
    title: "경기 취소 기능 개선 요청",
    content: "경기 취소 시 참가자들에게 자동으로 알림이 가도록 해주세요. 현재는 수동으로 연락해야 해서 불편합니다.",
    status: "pending"
  },
  {
    title: "결제 수단 추가 요청",
    content: "현재 토스페이로만 결제가 가능한데, 카카오페이나 네이버페이도 추가해주시면 좋겠습니다. 더 많은 사용자가 편리하게 이용할 수 있을 것 같아요.",
    status: "reviewing",
    admin_response: "좋은 제안 감사합니다. 현재 카카오페이 연동을 검토 중입니다."
  },
  {
    title: "코트 정보 업데이트",
    content: "강남구 OO체육관의 운영 시간이 변경되었는데 아직 반영이 안 되어 있습니다. 평일 오후 10시까지로 연장되었습니다.",
    status: "resolved",
    admin_response: "확인하여 업데이트 완료했습니다. 제보 감사합니다!"
  },
  {
    title: "모바일 앱 개발 건의",
    content: "웹사이트도 좋지만 모바일 앱이 있으면 더 편리할 것 같습니다. 푸시 알림 기능도 있으면 경기 시작 전에 알림을 받을 수 있어서 좋을 것 같아요.",
    status: "pending"
  },
  {
    title: "사용자 평가 시스템",
    content: "경기 후에 함께 플레이한 사용자들을 평가할 수 있는 시스템이 있으면 좋겠습니다. 매너가 좋은 사용자들과 계속 경기할 수 있도록요.",
    status: "closed",
    admin_response: "검토해본 결과, 현재는 도입하지 않기로 결정했습니다. 추후 재검토하겠습니다."
  }
]

suggestions_data.each do |data|
  Suggestion.create!(
    user: test_user,
    title: data[:title],
    content: data[:content],
    status: data[:status],
    admin_response: data[:admin_response]
  )
end

puts "Created #{Suggestion.count} suggestions"
