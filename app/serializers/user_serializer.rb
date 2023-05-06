class UserSerializer < ActiveModel::Serializer
  attributes :id, :role, :full_name, :email, :phone, :token, :referral_url, :username,
             :pronouns, :bio, :skills, :language, :photo, :email_confirmed, :photo

  def full_name
    object.full_name
  end

  def token
    AuthenticationTokenService.call(object.id)
  end
end