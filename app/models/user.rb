class User < ApplicationRecord
  after_create :send_confirmation_mail
  before_create :set_slug

  has_secure_password

  USER = 'user'.freeze
  ADMIN = 'admin'.freeze
  CLIENT = 'client'.freeze
  FREELANCER = 'freelancer'.freeze
  ENTERPRISE = 'enterprise'.freeze

  enum role: { USER => 0, ADMIN => 1 }, _prefix: true
  enum account_type: { CLIENT => 0, FREELANCER => 1, ENTERPRISE => 2 }, _prefix: true

  validates :password, presence: true, length: { minimum: 8 }, on: :create
  validates :email, presence: true, uniqueness: { message: 'Email already taken' }
  # validates_presence_of :first_name, message: 'First Name cannot be blank'
  # validates_presence_of :last_name, message: 'Last Name cannot be blank'

  def email_activate
    self.email_confirmed = true
    self.confirm_token = nil
    save!(validate: false)
  end


  def set_slug
    first_name = full_name.split.first
    self.slug = "#{first_name.parameterize}-#{SecureRandom.hex(2)}"
    self.referral_url = "#{first_name}-#{SecureRandom.hex(2)}".parameterize
  end

  def send_confirmation_mail
    ConfirmEmailJob.perform_later(self)
  end

end
