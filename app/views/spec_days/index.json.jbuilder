json.array!(@spec_days) do |spec_day|
  json.extract! spec_day, :id, :sdate, :is_workday, :comment
  json.url spec_day_url(spec_day, format: :json)
end
