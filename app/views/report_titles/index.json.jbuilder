json.array!(@report_titles) do |report_title|
  json.extract! report_title, :id, :name, :des, :ord
  json.url report_title_url(report_title, format: :json)
end
