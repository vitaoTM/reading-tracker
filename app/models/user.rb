class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :reading_entries, dependent: :destroy
  has_many :books, through: :reading_entries

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
end
