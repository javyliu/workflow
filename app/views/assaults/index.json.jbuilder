json.array!(@assaults) do |assault|
  json.extract! assault, :id, :cate, :description, :state, :employees
  json.url assault_url(assault, format: :json)
end
