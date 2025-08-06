class AddImagesToCourts < ActiveRecord::Migration[8.0]
  def change
    add_column :courts, :image1, :string
    add_column :courts, :image2, :string
  end
end
