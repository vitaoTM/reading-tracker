class CreateRecommendationListItems < ActiveRecord::Migration[8.1]
  def change
    create_table :recommendation_list_items do |t|
      t.references :recommendation_list, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.integer :position
      t.text :note

      t.timestamps
    end
    add_index :recommendation_list_items, [ :recommendation_list_id, :book_id ], unique: true
  end
end
