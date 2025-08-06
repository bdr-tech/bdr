class UpdateGameApplicationStatusForTwoStepApproval < ActiveRecord::Migration[8.0]
  def change
    # 결제 확인 시각을 저장할 컬럼 추가
    add_column :game_applications, :payment_confirmed_at, :datetime
    add_column :game_applications, :final_approved_at, :datetime

    # 기존 approved 상태를 waiting_payment로 변경
    # 무료 경기는 final_approved로 변경
    reversible do |dir|
      dir.up do
        # 기존 approved 상태 처리
        execute <<-SQL
          UPDATE game_applications#{' '}
          SET status = 'waiting_payment',#{' '}
              payment_confirmed_at = NULL,#{' '}
              final_approved_at = NULL
          WHERE status = 'approved'#{' '}
          AND game_id IN (SELECT id FROM games WHERE fee > 0)
        SQL

        # 무료 경기는 바로 final_approved로 변경
        execute <<-SQL
          UPDATE game_applications#{' '}
          SET status = 'final_approved',#{' '}
              final_approved_at = approved_at
          WHERE status = 'approved'#{' '}
          AND game_id IN (SELECT id FROM games WHERE fee = 0)
        SQL
      end

      dir.down do
        # 롤백 시 waiting_payment와 final_approved를 모두 approved로 변경
        execute <<-SQL
          UPDATE game_applications#{' '}
          SET status = 'approved'
          WHERE status IN ('waiting_payment', 'final_approved')
        SQL
      end
    end
  end
end
