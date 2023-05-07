class ApplicationController < ActionController::API
  include ExceptionHandler
  rescue_from ActiveRecord::RecordNotDestroyed, with: :not_destroyed

  def authenticate_request!
    return invalid_authentication if !payload || !AuthenticationTokenService.valid_payload(payload.first)

    current_user!
    invalid_authentication unless @current_user
  end

  def current_user!
    @current_user = User.find_by(id: payload[0]['user_id'])
  end

  def invalid_authentication
    render json: { error: 'You will need to login first' }, status: :unauthorized
  end

  private

  def payload
    auth_header = request.headers['Authorization']
    pp auth_header
    token = auth_header.split(' ').last
    AuthenticationTokenService.decode token
  rescue StandardError
    nil
  end
end
