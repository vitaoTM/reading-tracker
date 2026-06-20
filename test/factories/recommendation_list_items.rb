FactoryBot.define do
  factory :recommendation_list_item do
    recommendation_list { nil }
    book { nil }
    position { 1 }
    note { "MyText" }
  end
end
