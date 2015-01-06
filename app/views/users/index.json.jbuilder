json.array!(@users) do |user|
  json.extract! user, :id, :uid, :user_name, :email, :department, :title, :expire_date, :dept_code, :mgr_code, :password_digest, :role_group, :remember_token, :remember_token_expires_at
  json.url user_url(user, format: :json)
end
