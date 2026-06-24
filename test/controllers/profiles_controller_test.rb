require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "profile page renders for existing user" do
    user = create(:user, username: "vitor")
    create(:favorite_book, user: user, book: create(:book, title: "Fav Book"), position: 1)
    create(:recommendation_list, user: user, title: "My Picks", public: true)
    create(:map_entry, user: user, country_code: "BR", color: "#00AA88")

    get profile_url(username: "vitor")
    assert_response :success
    assert_match "vitor", response.body
    assert_match "Fav Book", response.body
    assert_match "My Picks", response.body
    assert_match "BR", response.body
  end

  test "private lists do not appear on profile" do
    user = create(:user, username: "vitor2")
    create(:recommendation_list, user: user, title: "Secret List", public: false)
    create(:recommendation_list, user: user, title: "Public List", public: true)

    get profile_url(username: "vitor2")
    assert_response :success
    refute_match "Secret List", response.body
    assert_match "Public List", response.body
  end

  test "unknown username returns 404" do
    get profile_url(username: "nobody")
    assert_response :not_found
  end
end
