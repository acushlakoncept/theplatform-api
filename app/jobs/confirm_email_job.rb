class ConfirmEmailJob < ApplicationJob
  queue_as :default

  def perform(user)
    UserMailer.registration_confirmation(user).deliver_now
  end
end
