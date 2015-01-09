json.array!(@oa_configs) do |oa_config|
  json.extract! oa_config, :id, :key, :des, :value
  json.url oa_config_url(oa_config, format: :json)
end
