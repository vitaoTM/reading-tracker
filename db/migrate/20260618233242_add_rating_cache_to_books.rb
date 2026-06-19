class AddRatingCacheToBooks < ActiveRecord::Migration[8.1]
  def change
    add_column :books, :cached_average_rating, :decimal, default: 0.0, null: false
    add_column :books, :ratings_count, :integer, default: 0, null: false
  end
end
