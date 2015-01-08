require 'test_helper'

class AttendRulesControllerTest < ActionController::TestCase
  setup do
    @attend_rule = attend_rules(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:attend_rules)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create attend_rule" do
    assert_difference('AttendRule.count') do
      post :create, attend_rule: { description: @attend_rule.description, name: @attend_rule.name, title_ids: @attend_rule.title_ids }
    end

    assert_redirected_to attend_rule_path(assigns(:attend_rule))
  end

  test "should show attend_rule" do
    get :show, id: @attend_rule
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @attend_rule
    assert_response :success
  end

  test "should update attend_rule" do
    patch :update, id: @attend_rule, attend_rule: { description: @attend_rule.description, name: @attend_rule.name, title_ids: @attend_rule.title_ids }
    assert_redirected_to attend_rule_path(assigns(:attend_rule))
  end

  test "should destroy attend_rule" do
    assert_difference('AttendRule.count', -1) do
      delete :destroy, id: @attend_rule
    end

    assert_redirected_to attend_rules_path
  end
end
