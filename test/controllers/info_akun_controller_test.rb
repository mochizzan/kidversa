require "test_helper"

class InfoAkunControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get info_akun_index_url
    assert_response :success
  end
end
