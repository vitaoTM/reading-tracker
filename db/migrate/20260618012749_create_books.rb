class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.string :title
      t.string :author
      t.string :isbn
      t.text :description
      t.integer :published_year
      t.string :country_of_origin
      t.string :language
      t.integer :page_count
      t.string :age_indicator
      t.integer :recommendation_count, null: false, default: 0

      t.timestamps
    end

    add_index :books, :isbn, unique: true
  end
end
