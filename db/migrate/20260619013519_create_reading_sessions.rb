class CreateReadingSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :reading_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.date :read_on
      t.integer :duration_minutes
      t.integer :pages_read
      t.text :notes

      t.timestamps
    end
  end
end
