class CreateFavoriteBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :favorite_books do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end
    add_index :favorite_books, [ :book_id, :user_id ], unique: true
  end
end
