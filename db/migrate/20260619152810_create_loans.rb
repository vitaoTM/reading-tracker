class CreateLoans < ActiveRecord::Migration[8.1]
  def change
    create_table :loans do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book, null: true, foreign_key: true
      t.string :book_title
      t.string :counterparty_name
      t.integer :direction
      t.date :loaned_on
      t.date :returned_on
      t.text :notes

      t.timestamps
    end
  end
end
