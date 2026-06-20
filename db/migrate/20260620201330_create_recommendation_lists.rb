class CreateRecommendationLists < ActiveRecord::Migration[8.1]
  def change
    create_table :recommendation_lists do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.boolean :public, default: false, null: false

      t.timestamps
    end
  end
end
