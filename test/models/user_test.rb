require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "valid user can be created" do
    assert build(:user).valid?
  end

  test "username is required" do
    user = build(:user, username: nil)
    refute user.valid?
    assert_includes user.errors[:username], "can't be blank"
  end

  test "username must be unique" do
    create(:user, username: "one")
    duplicate = build(:user, username: "one")
    refute duplicate.valid?
  end

  test "username only allows letters, numbers and  underscores" do
    refute build(:user, username: "bad name!").valid?
    assert build(:user, username: "good_name1").valid?
  end
end
