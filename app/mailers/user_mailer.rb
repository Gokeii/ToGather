class UserMailer < ActionMailer::Base
  default from: "21250546@qq.com"

  def welcome_email(user)
  	@user = user
  	@url = "http://localhost:3000"
  	mail(:to => user.email, :subject => "Welcome to My Awesome Site")
  end

  def confirm(email)
  	@message = "Thank you for confirmation!"
  	mail(:to => email, :subject => "Registered")
  end

  def invite(user, emails, title, description, link)
    @user = user
    @title = title
    @description = description
    @link = link

    subject = "ToGather: " + title

  	mail(:to => emails, :subject => subject)
  end
end
