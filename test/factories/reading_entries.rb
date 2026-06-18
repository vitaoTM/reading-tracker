FactoryBot.define do
  factory :reading_entry do
    user
    book
    status { :want_to_read }
  end
end
