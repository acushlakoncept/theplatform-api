class UserSerializer < ActiveModel::Serializer
  attributes :id, :role, :full_name, :email, :phone, :token,
             :pronouns, :bio, :skills, :language, :photo, :email_confirmed, :photo


  def token
    AuthenticationTokenService.call(object.id)
  end
end