FactoryBot.define do
  factory :loan do
    user
    book
    counterparty_name { "Maria" }
    direction { :lent }
    loaned_on { Date.current }
  end
end
