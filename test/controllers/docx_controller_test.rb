require "test_helper"

class DocxControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get docx_index_url
    assert_response :success
  end

  test "should get process" do
    get docx_process_url
    assert_response :success
  end

  test "should get download" do
    get docx_download_url
    assert_response :success
  end

  test "should get check_status" do
    get docx_check_status_url
    assert_response :success
  end
end
