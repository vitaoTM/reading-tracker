class RecommendationList < ApplicationRecord
  MAX_ITEMS = 10

  belongs_to :user

  has_many :items, -> { order(:position) },
    class_name: "RecommendationListItem", dependent: :destroy
  has_many :books, through: :items

  validates :title, presence: true, length: { maximum: 80 }

  scope :public_lists, -> { where(public: true) }
end
