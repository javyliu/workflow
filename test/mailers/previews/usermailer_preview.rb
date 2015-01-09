# Preview all emails at http://localhost:3000/rails/mailers/usermailer
class UsermailerPreview < ActionMailer::Preview

  def daily_kaoqing
    Usermailer.daily_kaoqing("1416")
  end

end
