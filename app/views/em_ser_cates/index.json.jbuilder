json.array!(@em_ser_cates) do |em_ser_cate|
  json.extract! em_ser_cate, :id, :name
  json.url em_ser_cate_url(em_ser_cate, format: :json)
end
