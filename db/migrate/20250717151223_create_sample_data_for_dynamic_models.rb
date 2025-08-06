class CreateSampleDataForDynamicModels < ActiveRecord::Migration[8.0]
  def up
    # Create sample achievements
    achievements = [
      { name: '월간 MVP', description: '월간 최우수 선수로 선정', icon: '🏆', category: 'performance' },
      { name: '연승왕', description: '연속 5승 달성', icon: '🔥', category: 'streak' },
      { name: '베스트 리뷰어', description: '리뷰 10개 이상 작성', icon: '⭐', category: 'community' },
      { name: '정확한 슛', description: '3점슛 성공률 80% 이상', icon: '🎯', category: 'skill' },
      { name: '팀플레이어', description: '어시스트 평균 5개 이상', icon: '🤝', category: 'teamwork' },
      { name: '신입회원', description: '회원가입 완료', icon: '🎈', category: 'milestone' }
    ]

    achievements.each do |achievement_data|
      Achievement.find_or_create_by(name: achievement_data[:name]) do |achievement|
        achievement.assign_attributes(achievement_data)
      end
    end

    # Create user stats for existing users
    User.find_each do |user|
      unless user.user_stat
        user.create_user_stat!(
          rating: rand(3.0..5.0).round(2),
          wins: rand(5..25),
          losses: rand(0..15),
          games_played: rand(10..40),
          mvp_count: rand(0..5)
        )
      end

      # Create play style
      unless user.play_style
        user.create_play_style!(
          assist_percentage: rand(40..95),
          three_point_percentage: rand(30..90),
          defense_percentage: rand(40..85),
          rebound_percentage: rand(20..80)
        )
      end
    end

    # Create sample game results
    Game.includes(:organizer).find_each do |game|
      # Create results for organizer
      unless game.game_results.exists?(user: game.organizer)
        won = [ true, false ].sample
        GameResult.create!(
          game: game,
          user: game.organizer,
          team: 'home',
          won: won,
          player_rating: rand(3.0..5.0).round(2),
          points_scored: rand(8..35),
          assists: rand(1..12),
          rebounds: rand(2..15)
        )
      end

      # Create results for some other users
      sample_users = User.where.not(id: game.organizer_id).sample(rand(2..6))
      sample_users.each_with_index do |user, index|
        unless game.game_results.exists?(user: user)
          won = [ true, false ].sample
          GameResult.create!(
            game: game,
            user: user,
            team: index.even? ? 'home' : 'away',
            won: won,
            player_rating: rand(3.0..5.0).round(2),
            points_scored: rand(5..30),
            assists: rand(0..10),
            rebounds: rand(1..12)
          )
        end
      end
    end

    # Create sample user achievements
    User.find_each do |user|
      # Give each user 2-4 random achievements
      sample_achievements = Achievement.all.sample(rand(2..4))
      sample_achievements.each do |achievement|
        unless user.user_achievements.exists?(achievement: achievement)
          user.user_achievements.create!(
            achievement: achievement,
            earned_at: rand(1.month.ago..Time.current)
          )
        end
      end
    end

    # Create sample court visits
    User.find_each do |user|
      Court.all.sample(rand(1..3)).each do |court|
        unless user.court_visits.exists?(court: court)
          user.court_visits.create!(
            court: court,
            visit_count: rand(1..20),
            is_favorite: [ true, false ].sample,
            last_visited_at: rand(1.month.ago..Time.current)
          )
        end
      end
    end

    # Create sample activities
    User.find_each do |user|
      # Game activities
      user.game_results.recent.limit(3).each do |result|
        activity_type = result.won? ? 'game_won' : 'game_lost'
        Activity.create!(
          user: user,
          activity_type: activity_type,
          trackable: result.game,
          metadata: {
            rating: result.player_rating,
            points: result.points_scored,
            result: result.won? ? 'win' : 'loss'
          }
        )
      end

      # Achievement activities
      user.user_achievements.order(earned_at: :desc).limit(2).each do |user_achievement|
        Activity.create!(
          user: user,
          activity_type: 'achievement_earned',
          trackable: user_achievement.achievement,
          metadata: {
            earned_at: user_achievement.earned_at
          }
        )
      end

      # Review activities
      user.reviews.order(created_at: :desc).limit(2).each do |review|
        Activity.create!(
          user: user,
          activity_type: 'review_posted',
          trackable: review.reviewable,
          metadata: {
            rating: review.rating,
            comment_preview: review.comment&.truncate(50)
          }
        )
      end
    end

    # Create sample reviews
    User.find_each do |user|
      # Review some games
      Game.all.sample(rand(1..3)).each do |game|
        unless user.reviews.exists?(reviewable: game)
          user.reviews.create!(
            reviewable: game,
            rating: rand(1..5),
            comment: [
              "좋은 경기였습니다! 다음에 또 참가하고 싶어요.",
              "시설이 깔끔하고 분위기가 좋았습니다.",
              "레벨이 적당해서 즐겁게 운동했습니다.",
              "조금 더 체계적이면 좋을 것 같아요.",
              "팀워크가 좋았던 경기였습니다."
            ].sample
          )
        end
      end

      # Review some courts
      Court.all.sample(rand(1..2)).each do |court|
        unless user.reviews.exists?(reviewable: court)
          user.reviews.create!(
            reviewable: court,
            rating: rand(1..5),
            comment: [
              "시설이 정말 좋아요! 강력 추천합니다.",
              "접근성이 좋고 분위기도 괜찮습니다.",
              "가성비가 좋은 코트입니다.",
              "주차가 편리해서 자주 이용하게 됩니다.",
              "샤워시설까지 완비되어 있어서 만족합니다."
            ].sample
          )
        end
      end
    end

    puts "Sample data created successfully!"
    puts "- Achievements: #{Achievement.count}"
    puts "- User Stats: #{UserStat.count}"
    puts "- Play Styles: #{PlayStyle.count}"
    puts "- Game Results: #{GameResult.count}"
    puts "- User Achievements: #{UserAchievement.count}"
    puts "- Court Visits: #{CourtVisit.count}"
    puts "- Activities: #{Activity.count}"
    puts "- Reviews: #{Review.count}"
  end

  def down
    # Clean up sample data
    Achievement.destroy_all
    UserStat.destroy_all
    PlayStyle.destroy_all
    GameResult.destroy_all
    UserAchievement.destroy_all
    CourtVisit.destroy_all
    Activity.destroy_all
    Review.destroy_all
  end
end
