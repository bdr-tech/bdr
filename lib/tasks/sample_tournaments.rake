namespace :tournaments do
  desc "Create sample tournaments"
  task create_samples: :environment do
    # 첫 번째 사용자를 주최자로 사용
    organizer = User.first
    unless organizer
      puts "No users found. Please create at least one user first."
      exit
    end

    # 샘플 대회 데이터
    tournaments = [
      {
        name: "2024 서울 봄맞이 챔피언십",
        description: "서울 지역 최고의 농구팀을 가리는 봄 시즌 대회입니다.",
        tournament_type: "single_elimination",
        status: "registration_open",
        registration_start_at: 1.week.ago,
        registration_end_at: 1.week.from_now,
        tournament_start_at: 2.weeks.from_now,
        tournament_end_at: 3.weeks.from_now,
        min_teams: 8,
        max_teams: 16,
        players_per_team: 5,
        entry_fee: 50000,
        prize_pool: 3000000,
        location_name: "잠실 종합운동장",
        location_address: "서울특별시 송파구 올림픽로 25",
        contact_phone: "02-1234-5678",
        contact_email: "tournament@bdr.com",
        rules: "1. FIBA 공식 규정을 따릅니다.\n2. 경기 시간은 10분 4쿼터입니다.\n3. 각 팀은 최소 5명, 최대 10명으로 구성됩니다.\n4. 경기 시작 15분 전까지 도착해야 합니다.",
        prizes: '[{"place": 1, "amount": 1500000}, {"place": 2, "amount": 1000000}, {"place": 3, "amount": 500000}]',
        sponsor_names: "나이키, 게토레이, BDR",
        featured: true
      },
      {
        name: "강남 3on3 스트리트볼 대회",
        description: "3대3 스트리트 농구의 열정을 느껴보세요!",
        tournament_type: "double_elimination",
        status: "registration_open",
        registration_start_at: Time.current,
        registration_end_at: 10.days.from_now,
        tournament_start_at: 2.weeks.from_now,
        tournament_end_at: 2.weeks.from_now + 2.days,
        min_teams: 12,
        max_teams: 24,
        players_per_team: 3,
        entry_fee: 30000,
        prize_pool: 1000000,
        location_name: "강남 스포츠센터",
        location_address: "서울특별시 강남구 강남대로 123",
        contact_phone: "02-2345-6789",
        contact_email: "3on3@bdr.com",
        rules: "1. 3대3 FIBA 규정을 따릅니다.\n2. 경기 시간은 10분 단판 또는 21점 선취승입니다.\n3. 각 팀은 3명 + 후보 1명으로 구성됩니다.",
        prizes: '[{"place": 1, "amount": 600000}, {"place": 2, "amount": 300000}, {"place": 3, "amount": 100000}]',
        sponsor_names: "아디다스, 포카리스웨트",
        featured: true
      },
      {
        name: "홍대 나이트 리그",
        description: "평일 저녁, 농구로 스트레스를 날려보세요!",
        tournament_type: "round_robin",
        status: "ongoing",
        registration_start_at: 1.month.ago,
        registration_end_at: 2.weeks.ago,
        tournament_start_at: 1.week.ago,
        tournament_end_at: 3.weeks.from_now,
        min_teams: 6,
        max_teams: 8,
        players_per_team: 5,
        entry_fee: 40000,
        prize_pool: 500000,
        location_name: "홍대 실내 농구장",
        location_address: "서울특별시 마포구 홍대로 456",
        contact_phone: "02-3456-7890",
        contact_email: "night@bdr.com",
        rules: "1. 매주 화요일, 목요일 저녁 7시 경기\n2. 풀리그 방식으로 진행\n3. 승점제로 순위 결정",
        prizes: '[{"place": 1, "amount": 300000}, {"place": 2, "amount": 150000}, {"place": 3, "amount": 50000}]',
        sponsor_names: "BDR 스포츠"
      },
      {
        name: "제주도 전국 대학생 농구대회",
        description: "대학생들의 열정이 불타오르는 전국 규모 대회",
        tournament_type: "group_stage",
        status: "published",
        registration_start_at: 1.month.from_now,
        registration_end_at: 2.months.from_now,
        tournament_start_at: 3.months.from_now,
        tournament_end_at: 3.months.from_now + 5.days,
        min_teams: 16,
        max_teams: 32,
        players_per_team: 7,
        entry_fee: 100000,
        prize_pool: 5000000,
        location_name: "제주 한라체육관",
        location_address: "제주특별자치도 제주시 한라대로 123",
        contact_phone: "064-1234-5678",
        contact_email: "jeju@bdr.com",
        rules: "1. 대학생 신분 확인 필수\n2. 조별 리그 후 토너먼트\n3. 프로 경력자 참가 불가",
        prizes: '[{"place": 1, "amount": 3000000}, {"place": 2, "amount": 1500000}, {"place": 3, "amount": 500000}]',
        sponsor_names: "제주특별자치도, 한국대학농구연맹, BDR"
      },
      {
        name: "2023 가을 왕중왕전",
        description: "올해의 최강팀을 가립니다!",
        tournament_type: "single_elimination",
        status: "completed",
        registration_start_at: 4.months.ago,
        registration_end_at: 3.months.ago,
        tournament_start_at: 2.months.ago,
        tournament_end_at: 1.month.ago,
        min_teams: 8,
        max_teams: 8,
        players_per_team: 5,
        entry_fee: 0,
        prize_pool: 2000000,
        location_name: "올림픽공원 SK핸드볼경기장",
        location_address: "서울특별시 송파구 올림픽로 424",
        contact_phone: "02-9876-5432",
        contact_email: "championship@bdr.com",
        rules: "1. 초청 대회\n2. 각 지역 우승팀만 참가 가능",
        prizes: '[{"place": 1, "amount": 2000000}]',
        sponsor_names: "SK스포츠, BDR"
      }
    ]

    tournaments.each do |tournament_data|
      tournament = Tournament.create!(
        tournament_data.merge(organizer: organizer)
      )
      puts "Created tournament: #{tournament.name}"

      # 진행중이거나 완료된 대회에 샘플 팀 추가
      if tournament.status.in?([ "ongoing", "completed", "registration_open" ])
        team_names = [ "Thunder Hawks", "Lightning Bolts", "Fire Breakers", "Ice Storm",
                     "Wind Runners", "Mountain Lions", "Ocean Waves", "Desert Eagles" ]

        num_teams = tournament.status == "registration_open" ? rand(4..8) : tournament.max_teams

        num_teams.times do |i|
          team = TournamentTeam.create!(
            tournament: tournament,
            team_name: team_names[i % team_names.length] + " #{i + 1}",
            captain: User.offset(rand(User.count)).first,
            status: tournament.status == "registration_open" && i > 5 ? "pending" : "approved",
            contact_phone: "010-#{rand(1000..9999)}-#{rand(1000..9999)}",
            contact_email: "team#{i+1}@example.com",
            roster: (1..tournament.players_per_team).map { |j|
              {
                name: "선수 #{j}",
                position: [ "가드", "포워드", "센터" ].sample,
                number: rand(0..99)
              }
            }.to_json,
            payment_completed: tournament.entry_fee == 0 || tournament.status != "registration_open",
            seed_number: tournament.status.in?([ "ongoing", "completed" ]) ? i + 1 : nil
          )
          puts "  - Added team: #{team.team_name}"
        end

        # 진행중이거나 완료된 대회에 경기 결과 추가
        if tournament.status.in?([ "ongoing", "completed" ])
          teams = tournament.approved_teams.to_a

          # 1라운드 경기 생성
          (teams.length / 2).times do |i|
            match = TournamentMatch.create!(
              tournament: tournament,
              home_team: teams[i * 2],
              away_team: teams[i * 2 + 1],
              round: "round_of_#{teams.length}",
              match_number: i + 1,
              scheduled_at: tournament.tournament_start_at + i.hours,
              court_name: "Court #{i % 2 + 1}",
              status: tournament.status == "completed" ? "completed" : [ "scheduled", "completed" ].sample
            )

            if match.status == "completed"
              home_score = rand(60..100)
              away_score = rand(60..100)
              match.complete_match!(home_score, away_score)
              puts "    - Match result: #{match.home_team.team_name} #{home_score} - #{away_score} #{match.away_team.team_name}"
            end
          end
        end
      end
    end

    puts "\nSuccessfully created #{tournaments.length} sample tournaments!"
  end

  desc "Clear all tournaments"
  task clear: :environment do
    TournamentMatch.destroy_all
    TournamentTeam.destroy_all
    Tournament.destroy_all
    puts "All tournaments have been cleared."
  end
end
