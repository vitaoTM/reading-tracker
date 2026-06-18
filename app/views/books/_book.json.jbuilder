json.extract! book, :id, :title, :author, :isbn, :description, :published_year, :country_of_origin, :language, :page_count, :age_indicator, :created_at, :updated_at
json.url book_url(book, format: :json)
