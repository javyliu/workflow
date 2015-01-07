json.array!(@year_infos) do |year_info|
  json.extract! year_info, :id, :year, :user_id, :year_holiday, :sick_leave, :affair_leave, :switch_leave, :ab_point
  json.url year_info_url(year_info, format: :json)
end
