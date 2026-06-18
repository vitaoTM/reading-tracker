FactoryBot.define do
  factory :book do
    sequence(:title) { |n| "Book #{n}" }
    author { "R.R Tolken" }
    sequence(:isbn) { |n| "9780000000#{n.to_s.rjust(4, '0')}" }
    country_of_origin { "UK" }
    language { "en" }
    age_indicator { "adult" }
  end
end
