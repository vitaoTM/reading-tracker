require "test_helper"

class RecommendationListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    sign_in_as(@user)
  end

  test "index renders" do
    get recommendation_lists_url
    assert_response :success
  end

  test "create makes a list" do
    assert_difference("RecommendationList.count", 1) do
      post recommendation_lists_url, params: {
        recommendation_list: { title: "My Horror Picks", public: true }
      }
    end
  end

  test "discover shows public lists only" do
    create(:recommendation_list, user: @user, title: "Public One", public: true)
    create(:recommendation_list, user: @user, title: "Secret One", public: false)
    get lists_url
    assert_response :success
    assert_match "Public One", response.body
    refute_match "Secret One", response.body
  end

  test "top_recommended ranks by count" do
    create(:book, title: "Less Loved", recommendation_count: 1)
    create(:book, title: "Most Loved", recommendation_count: 10)
    get top_recommended_url
    assert_response :success
    assert response.body.index("Most Loved") < response.body.index("Less Loved")
  end
  # test "should get show" do
  #   get recommendation_lists_show_url
  #   assert_response :success
  # end
  #
  # test "should get new" do
  #   get recommendation_lists_new_url
  #   assert_response :success
  # end
end
