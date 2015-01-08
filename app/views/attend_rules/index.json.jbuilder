json.array!(@attend_rules) do |attend_rule|
  json.extract! attend_rule, :id, :name, :description, :title_ids
  json.url attend_rule_url(attend_rule, format: :json)
end
