FactoryBot.define do
  factory :reading_session do
    user
    book
    read_on { Date.today }
    duration_minutes { 30 }
    pages_read { 20 }
  end
end
