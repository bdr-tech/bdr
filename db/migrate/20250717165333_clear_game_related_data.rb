class ClearGameRelatedData < ActiveRecord::Migration[8.0]
  def up
    # 의존성 순서대로 삭제 (외래키 관계 고려)

    # 1. Payments 테이블 삭제
    execute "DELETE FROM payments"

    # 2. GameApplications 테이블 삭제
    execute "DELETE FROM game_applications"

    # 3. GameParticipations 테이블 삭제 (있다면)
    execute "DELETE FROM game_participations" if table_exists?(:game_participations)

    # 4. GameResults 테이블 삭제 (있다면)
    execute "DELETE FROM game_results" if table_exists?(:game_results)

    # 5. GameInvitations 테이블 삭제 (있다면)
    execute "DELETE FROM game_invitations" if table_exists?(:game_invitations)

    # 6. Games 테이블 삭제
    execute "DELETE FROM games"

    # 7. UserCancellations 테이블 초기화
    execute "DELETE FROM user_cancellations"

    # 8. Auto-increment 값 리셋
    execute "DELETE FROM sqlite_sequence WHERE name IN ('games', 'game_applications', 'payments', 'user_cancellations')"

    puts "✅ 모든 경기 관련 데이터가 삭제되었습니다."
  end

  def down
    # 롤백은 불가능 (데이터 복구 불가)
    raise ActiveRecord::IrreversibleMigration
  end
end
