# 누락된 지역 데이터 추가 스크립트

# 강원도 시/군
gangwon_cities = [
  '춘천시', '원주시', '강릉시', '동해시', '태백시', '속초시', '삼척시',
  '홍천군', '횡성군', '영월군', '평창군', '정선군', '철원군', '화천군',
  '양구군', '인제군', '고성군', '양양군'
]

# 경상남도 시/군
gyeongnam_cities = [
  '창원시', '진주시', '통영시', '사천시', '김해시', '밀양시', '거제시', '양산시',
  '의령군', '함안군', '창녕군', '고성군', '남해군', '하동군', '산청군',
  '함양군', '거창군', '합천군'
]

# 경상북도 시/군
gyeongbuk_cities = [
  '포항시', '경주시', '김천시', '안동시', '구미시', '영주시', '영천시',
  '상주시', '문경시', '경산시', '군위군', '의성군', '청송군', '영양군',
  '영덕군', '청도군', '고령군', '성주군', '칠곡군', '예천군', '봉화군',
  '울진군', '울릉군'
]

# 전라남도 시/군
jeonnam_cities = [
  '목포시', '여수시', '순천시', '나주시', '광양시', '담양군', '곡성군',
  '구례군', '고흥군', '보성군', '화순군', '장흥군', '강진군', '해남군',
  '영암군', '무안군', '함평군', '영광군', '장성군', '완도군', '진도군', '신안군'
]

# 전라북도 시/군
jeonbuk_cities = [
  '전주시', '군산시', '익산시', '정읍시', '남원시', '김제시', '완주군',
  '진안군', '무주군', '장수군', '임실군', '순창군', '고창군', '부안군'
]

# 충청남도 시/군
chungnam_cities = [
  '천안시', '공주시', '보령시', '아산시', '서산시', '논산시', '계룡시',
  '당진시', '금산군', '부여군', '서천군', '청양군', '홍성군', '예산군', '태안군'
]

# 충청북도 시/군
chungbuk_cities = [
  '청주시', '충주시', '제천시', '보은군', '옥천군', '영동군', '증평군',
  '진천군', '괴산군', '음성군', '단양군'
]

# 제주특별자치도 시
jeju_cities = [ '제주시', '서귀포시' ]

# 데이터 추가 함수
def add_locations(city_name, districts)
  added_count = 0
  districts.each do |district|
    unless Location.exists?(city: city_name, district: district)
      Location.create!(
        city: city_name,
        district: district,
        full_name: "#{city_name} #{district}"
      )
      added_count += 1
      puts "추가됨: #{city_name} #{district}"
    end
  end
  puts "#{city_name}: #{added_count}개 추가됨"
  puts ""
end

# 각 도별로 데이터 추가
puts "=== 누락된 지역 데이터 추가 시작 ==="
puts ""

add_locations('강원도', gangwon_cities)
add_locations('경상남도', gyeongnam_cities)
add_locations('경상북도', gyeongbuk_cities)
add_locations('전라남도', jeonnam_cities)
add_locations('전라북도', jeonbuk_cities)
add_locations('충청남도', chungnam_cities)
add_locations('충청북도', chungbuk_cities)
add_locations('제주특별자치도', jeju_cities)

puts "=== 데이터 추가 완료 ==="
puts ""

# 최종 통계 출력
puts "=== 최종 시/도별 하위 행정구역 현황 ==="
puts ""

cities = Location.select(:city).distinct.order(:city).pluck(:city)
cities.each do |city|
  districts = Location.where(city: city).pluck(:district).uniq.sort
  puts "#{city}: #{districts.count}개"
end

puts ""
puts "=== 전체 통계 ==="
puts "시/도 총 개수: #{cities.count}개"
puts "전체 지역 개수: #{Location.count}개"
