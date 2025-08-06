class AddBirthDateAndBasketballExperienceToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :birth_date, :date
    add_column :users, :basketball_experience, :integer, default: 0, comment: '농구 경력 (년)'
  end
end
