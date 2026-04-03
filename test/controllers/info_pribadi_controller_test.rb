require "test_helper"

class InfoPribadiControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get info_pribadi_index_url
    assert_response :success
  end
end
