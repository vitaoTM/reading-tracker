class MapEntry < ApplicationRecord
  COUNTRY_CODE_REGEX = /\A[A-Z]{2}\z/

  belongs_to :user
  belongs_to :book, optional: true

  before_validation { self.country_code = country_code&.upcase }

  validates :country_code, presence: true, format: { with: COUNTRY_CODE_REGEX }
  validates :color, format: { with: /\A#[0-9A-Fa-f]{6}\z/ }, allow_nil: true
  validates :country_code, uniqueness: { scope: :user_id }
end
