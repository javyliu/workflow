require 'test_helper'

class YearInfosControllerTest < ActionController::TestCase
  setup do
    @year_info = year_infos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:year_infos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create year_info" do
    assert_difference('YearInfo.count') do
      post :create, year_info: { ab_point: @year_info.ab_point, affair_leave: @year_info.affair_leave, sick_leave: @year_info.sick_leave, switch_leave: @year_info.switch_leave, user_id: @year_info.user_id, year: @year_info.year, year_holiday: @year_info.year_holiday }
    end

    assert_redirected_to year_info_path(assigns(:year_info))
  end

  test "should show year_info" do
    get :show, id: @year_info
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @year_info
    assert_response :success
  end

  test "should update year_info" do
    patch :update, id: @year_info, year_info: { ab_point: @year_info.ab_point, affair_leave: @year_info.affair_leave, sick_leave: @year_info.sick_leave, switch_leave: @year_info.switch_leave, user_id: @year_info.user_id, year: @year_info.year, year_holiday: @year_info.year_holiday }
    assert_redirected_to year_info_path(assigns(:year_info))
  end

  test "should destroy year_info" do
    assert_difference('YearInfo.count', -1) do
      delete :destroy, id: @year_info
    end

    assert_redirected_to year_infos_path
  end
end
