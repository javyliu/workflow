json.array!(@em_services) do |em_service|
  json.extract! em_service, :id, :title, :content
  json.url em_service_url(em_service, format: :json)
end
