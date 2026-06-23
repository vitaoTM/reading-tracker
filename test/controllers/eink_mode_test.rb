require "test_helper"

class EinkModeTest < ActionDispatch::IntegrationTest
  test "eink=1 param adds eink class to html tag" do
    sign_in_as(create(:user))
    get root_url, params: { eink: 1 }
    assert_match /class="eink"/, response.body
  end

  test "default user has no eink class" do
    user = create(:user)
    sign_in_as(user)
    get root_url
    refute_match /class="eink"/, response.body
  end

  test "user with eink_mode enabled gets eink class " do
    user = create(:user, eink_mode: true)
    sign_in_as(user)
    get root_url
    assert_match /class="eink"/, response.body
  end
end
