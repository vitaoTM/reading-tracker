class Book < ApplicationRecord
  AGE_INDICATOR = %w[children middle_grade young_adult adult all_ages].freeze

  has_one_attached :cover_image

  validates :title, presence: true
  validates :isbn, uniqueness: true, allow_blank: true
  validates :age_indicator, inclusion: { in: AGE_INDICATOR }, allow_nil: true

  has_many :book_tags, dependent: :destroy
  has_many :tags, through: :book_tags
  has_many :reading_entries, dependent: :destroy
  has_many :ratings, dependent: :destroy

  def tag_names=(names)
    self.tags = Array(names).reject(&:blank?).map do |name|
      Tag.find_or_create_by(name: name.downcase.strip)
    end
  end

  def tag_names
    tags.pluck(:name)
  end

  def tag_list
    tags.pluck(:name).join(", ")
  end

  def tag_list=(value)
    self.tag_names = value.to_s.split(",").map(&:strip)
  end
end
