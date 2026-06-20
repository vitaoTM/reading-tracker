FactoryBot.define do
  factory :rating do
    user
    book
    score { 4 }
    review { "Very good book" }
  end
end
