class UserMailer < ActionMailer::Base
  default from: 'info@acushlakoncept.com'

  def registration_confirmation(user)
    @user = user
    @url = confirm_email_api_v1_user_url(id: @user.id, confirm_token: CGI.escape(@user.confirm_token))
    mail(to: @user.email, subject: 'Email Verification: ThePlatform!')
  end
end