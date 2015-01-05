require 'test_helper'

class SpecDaysControllerTest < ActionController::TestCase
  setup do
    @spec_day = spec_days(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:spec_days)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create spec_day" do
    assert_difference('SpecDay.count') do
      post :create, spec_day: { comment: @spec_day.comment, is_workday: @spec_day.is_workday, sdate: @spec_day.sdate }
    end

    assert_redirected_to spec_day_path(assigns(:spec_day))
  end

  test "should show spec_day" do
    get :show, id: @spec_day
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @spec_day
    assert_response :success
  end

  test "should update spec_day" do
    patch :update, id: @spec_day, spec_day: { comment: @spec_day.comment, is_workday: @spec_day.is_workday, sdate: @spec_day.sdate }
    assert_redirected_to spec_day_path(assigns(:spec_day))
  end

  test "should destroy spec_day" do
    assert_difference('SpecDay.count', -1) do
      delete :destroy, id: @spec_day
    end

    assert_redirected_to spec_days_path
  end
end
