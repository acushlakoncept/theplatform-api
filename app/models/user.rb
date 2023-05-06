class User < ApplicationRecord
  after_create :send_confirmation_mail
  has_secure_password

  USER = 'user'.freeze
  ADMIN = 'admin'.freeze

  enum role: { USER => 0, ADMIN => 1 }, _prefix: true

  validates :password, presence: true, length: { minimum: 8 }, on: :create
  validates :email, presence: true, uniqueness: { message: 'Email already taken' }
  validates_presence_of :first_name, message: 'First Name cannot be blank'
  validates_presence_of :last_name, message: 'Last Name cannot be blank'

  def email_activate
    email_confirmed = true
    confirm_token = nil
    save!(validate: false)
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def set_slug
    self.slug = "#{full_name.parameterize}-#{SecureRandom.hex(2)}"
  end

  def send_confirmation_mail
    ConfirmEmailJob.perform_later(self)
  end

end
