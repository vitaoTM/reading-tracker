class Tag < ApplicationRecord
  has_many :book_tags, dependent: :destroy
  has_many :books, through: :book_tags

  before_validation { self.name = name&.downcase&.strip }
  validates :name, presence: true, uniqueness: true
end
