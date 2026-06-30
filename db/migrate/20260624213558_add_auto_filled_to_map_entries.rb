class AddAutoFilledToMapEntries < ActiveRecord::Migration[8.1]
  def change
    add_column :map_entries, :auto_filled, :boolean, default: false, null: false
  end
end
