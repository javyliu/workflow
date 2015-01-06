json.array!(@departments) do |department|
  json.extract! department, :id, :code, :name, :atten_rule, :mgr_code, :admin
  json.url department_url(department, format: :json)
end
