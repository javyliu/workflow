json.array!(@episodes) do |episode|
  json.extract! episode, :id, :user_id, :holiday_id, :start_date, :end_date, :comment, :approved_by, :approved_time
  json.url episode_url(episode, format: :json)
end
