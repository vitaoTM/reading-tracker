class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :reading_entries, dependent: :destroy
  has_many :books, through: :reading_entries
  has_many :reading_sessions, dependent: :destroy
  has_many :loans, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :favorite_books, dependent: :destroy
  has_many :favorited, through: :favorite_books, source: :book
  has_many :recommendation_lists, dependent: :destroy
  has_many :map_entries, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :username, presence: true,
            uniqueness: { case_sensitive: true },
            format: { with: /\A[a-z0-9_]+\z/i, message: "letters, numbers underscore only" }


  def want_to_read_books
    reading_entries.want_to_read.includes(:book).map(&:book)
  end

  def currently_reading
    reading_entries.reading.includes(:book).map(&:book)
  end

  def finished_books
    reading_entries.finished.includes(:book).map(&:book)
  end

  def reading_stats(range: 30.days.ago..Date.current)
    sessions = reading_sessions.in_range(range.begin.to_date, range.end.to_date)
    {
      total_minutes: sessions.sum(:duration_minutes),
      total_pages:   sessions.sum(:pages_read),
      days_active:   sessions.distinct.count(:read_on),
      current_streak: current_streak
    }
  end

  def current_streak
    dates = reading_sessions.distinct.pluck(:read_on).sort.reverse
    return 0 if dates.empty?

    streak = 0
    expected = Date.current
    dates.each do |d|
      if d == expected
        streak += 1
        expected -= 1.day
      else
        break
      end
    end
    streak
  end

  def map_data
    map_entries.pluck(:country_code, :color).to_h
  end
end
