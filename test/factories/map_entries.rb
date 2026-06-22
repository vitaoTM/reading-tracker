FactoryBot.define do
  factory :map_entry do
    user
    sequence(:country_code) { |n| [ "BR", "JP", "DE", "FR", "US" ][n % 5] }
    color { "#336699" }
  end
end
