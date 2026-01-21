require "test_helper"

class AdminControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_index_url
    assert_response :success
  end

  test "should get data_siswa" do
    get admin_data_siswa_url
    assert_response :success
  end

  test "should get data_pertanyaan" do
    get admin_data_pertanyaan_url
    assert_response :success
  end

  test "should get data_nilai" do
    get admin_data_nilai_url
    assert_response :success
  end
end
