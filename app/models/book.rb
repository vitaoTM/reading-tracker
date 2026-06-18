class Book < ApplicationRecord
  AGE_INDICATOR = %w[children middle_grade young_adult adult all_ages].freeze

  has_one_attached :cover_image

  validates :title, presence: true
  validates :isbn, uniqueness: true, allow_blank: true
  validates :age_indicator, inclusion: { in: AGE_INDICATOR }, allow_nil: true
end
