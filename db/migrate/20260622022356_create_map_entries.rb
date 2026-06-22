class CreateMapEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :map_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.string :country_code
      t.string :color
      t.references :book, null: true, foreign_key: true

      t.timestamps
    end
    add_index :map_entries, [ :user_id, :country_code ], unique: true
  end
end
