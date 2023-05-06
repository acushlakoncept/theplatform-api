
class Api::V1::UsersController < Api::V1::ApiBaseController
  before_action :authenticate_request!, except: %i[create confirm_email]
  skip_before_action :verify_authenticity_token  #revisit

  def create
    user = User.create(user_create_params)
    user.confirm_token = SecureRandom.urlsafe_base64.to_s
    
    if user.save
      render json: { message: 'Account created successfully! Check your email to activate your account' },
              status: :created
    else
      render json: { error: user.errors.full_messages.first }, status: :unprocessable_entity
    end
  end

  def current_user
    render json: UserRepresenter.new(@current_user).as_json
  end

  def show
    user = User.find_by(slug: params.require(:slug))
    if user
      increment_views(user)
      render json: UserRepresenter.new(user).as_json
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  end

  def update
    if @current_user.update(user_params)
      render json: UserRepresenter.new(@current_user).as_json
    else
      render json: { error: @current_user.errors.full_messages.first }, status: :not_found
    end
  end

  def confirm_email
    user = User.find(params.require(:id))
    # we have to also make sure user.confirm_token equals params.require(:confirm_token)
    # We want to send only code to user instead of a confirmation URL
    # So on the frontend user enters the code and we send it to the API to confirm the email
  
    byebug 
    if user
      user.email_confirmed = true
      user.confirm_token = nil
      user.save!(validate: false)
      redirect_to "#{ENV['FRONTEND_URL_PUBLIC']}/thank-you", allow_other_host: true
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  end

  private

  def increment_views(user)
    return unless user != @current_user

    user.increment!(:views)
  end

  def user_create_params
    user_params = snakecase_params.require(:user)
    # This should be formated in the format /username
    user_params[:referral_url] = user_params[:username].strip.downcase
    user_params.permit!
    user_params.extract!(:action, :controller)
    user_params.except(:id, :created_at, :updated_at).to_h.with_indifferent_access

  end
end
