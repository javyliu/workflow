require 'test_helper'

class ReportTitlesControllerTest < ActionController::TestCase
  setup do
    @report_title = report_titles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:report_titles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create report_title" do
    assert_difference('ReportTitle.count') do
      post :create, report_title: { des: @report_title.des, name: @report_title.name, ord: @report_title.ord }
    end

    assert_redirected_to report_title_path(assigns(:report_title))
  end

  test "should show report_title" do
    get :show, id: @report_title
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @report_title
    assert_response :success
  end

  test "should update report_title" do
    patch :update, id: @report_title, report_title: { des: @report_title.des, name: @report_title.name, ord: @report_title.ord }
    assert_redirected_to report_title_path(assigns(:report_title))
  end

  test "should destroy report_title" do
    assert_difference('ReportTitle.count', -1) do
      delete :destroy, id: @report_title
    end

    assert_redirected_to report_titles_path
  end
end
