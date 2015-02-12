json.array!(@approves) do |approfe|
  json.extract! approfe, :id, :user_id, :user_name, :state, :des, :episode_id
  json.url approfe_url(approfe, format: :json)
end
