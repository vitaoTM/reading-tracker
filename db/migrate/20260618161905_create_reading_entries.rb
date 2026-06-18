class CreateReadingEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :reading_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.integer :status
      t.date :started_at
      t.date :finished_at
      t.text :notes
      t.text :discovery_source
      t.text :citation

      t.timestamps
    end
    add_index :reading_entries, [ :user_id, :book_id ], unique: true
  end
end
