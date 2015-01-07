json.array!(@checkinouts) do |checkinout|
  json.extract! checkinout, :id, :user_id, :rec_date, :checkin, :checkout, :ref_time
  json.url checkinout_url(checkinout, format: :json)
end
