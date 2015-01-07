json.array!(@journals) do |journal|
  json.extract! journal, :id, :user_id, :update_date, :check_type, :description, :dval
  json.url journal_url(journal, format: :json)
end
