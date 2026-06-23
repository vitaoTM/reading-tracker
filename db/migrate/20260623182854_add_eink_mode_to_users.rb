class AddEinkModeToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :eink_mode, :boolean, default: false, null: false
  end
end
