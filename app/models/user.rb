class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :username, presence: true,
            uniqueness: { case_sensitive: true },
            format: { with: /\A[a-z0-9_]+\z/i, message: "letters, numbers underscore only" }
end
