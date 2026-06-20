FactoryBot.define do
  factory :recommendation_list do
    user
    title { "My Picks" }
    description { "A curated list" }
    public { true }
  end
end
