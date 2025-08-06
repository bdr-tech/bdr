User.create!(
  name: 'Admin',
  email: 'admin@bdr.com',
  nickname: 'admin',
  real_name: 'Admin',
  phone: '010-0000-0000',
  height: 180,
  weight: 70,
  positions: [ 'PG' ],
  city: '서울특별시',
  district: '강남구',
  admin: true,
  status: 'active',
  profile_completed: true
)

puts "관리자 계정이 생성되었습니다."
puts "이메일: admin@bdr.com"
puts "접속 후 관리자 대시보드: /admin"
