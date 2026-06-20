FactoryBot.define do
  factory :favorite_book do
    user
    book
    sequence(:position)
  end
end
