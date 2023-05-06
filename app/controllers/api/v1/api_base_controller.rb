class Api::V1::ApiBaseController < ActionController::Base
  include ApiParametersHelper

  rescue_from StandardError, with: :error
  rescue_from ActionController::RoutingError, with: :render_not_found
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :invalid_record
  rescue_from ActionController::ParameterMissing, with: :invalid_record

  before_action :set_default_response_format
  after_action :set_json_response

  serialization_scope :serialization_context

  protected

  def json_request?
    request.format.json?
  end

  def serialization_context
    { root: false, snakecase: is_snakecase_params, current_user: @current_user }
  end

  def log_request
    Rails.logger.info request.inspect
  end

  def api_context_log(string)
    api_log = request.env['api_log']
    if api_log.present?
      context_hash = api_log.context_hash || {}
      context_hash[:log] ||= []
      context_hash[:log] << string
      api_log.context_hash = context_hash
    else
      Rails.logger.info(string)
    end
  end

  def api_context_object(hash)
    api_log = request.env['api_log']
    if api_log.present?
      context_hash = api_log.context_hash || {}
      context_hash.merge!(hash)
      api_log.context_hash = context_hash
    else
      Rails.logger.info(hash.to_s)
    end
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def format_500_error(error)
    {error:'An error occurred.'}
  end

  

  private


  #http://www.javiersaldana.com/2013/04/29/pagination-with-activeresource.html
  def self.set_headers(options = {})
    after_action(options) do |controller|
      results = instance_variable_get("@#{controller_name}")
      results = instance_variable_get("@#{controller_name.to_s.pluralize}") if results.blank?
      results = instance_variable_get("@collection") if results.blank?
      if results
        headers["pagination-limit"] = results.limit_value.to_s
        headers["pagination-offset"] = results.offset_value.to_s
        headers["pagination-total"] = results.total_count.to_s
      end

      Rails.cache.write("header-ip-#{controller.params.values.flatten.join('-')}",@ip) unless @ip.blank?

      headers["ip"] =  Rails.cache.read("header-ip-#{controller.params.values.flatten.join('-')}")
    end
  end

  def set_json_response
    response['Content-Type'] = 'application/json;charset=utf-8' if request.format == :json
  end

  def set_default_response_format
    request.format = :json unless params[:format]
  end

  def render_not_found
    head :not_found
  end

  def render_unauthenticated
    render json: { authorized: false }, status: :unauthorized
  end

  def render_unauthorized
    render json: { authorized: false }, status: :forbidden
  end

  def current_user_has_permission(permission)
    return render_unauthenticated if !user_signed_in?
    permission = [permission] unless permission.kind_of?(Array)
    return render_unauthorized if !permission.select{|p| current_user_has_permission?(p)}.any?
  end

  def error(error)
    logger.error "Error during processing: #{error.message}"
    puts "\e[31mError during processing: #{error.message}\e[0m" if Rails.env.test?
    logger.error "Backtrace:\n\t#{error.backtrace.join("\n\t")}"
    # Setup Airbrake later
    # notify_airbrake(error) 
    render json: format_500_error(error), status: :internal_server_error
  end
  # synonym for invalid record
  def bad_request(invalid)
    invalid_record(invalid)
  end

  def invalid_record(invalid)
    errors = {}
    if invalid.kind_of?(ActionController::ParameterMissing)
      errors = invalid.message
    elsif invalid.kind_of?(Hash) || invalid.kind_of?(Array)
      errors = invalid
    elsif invalid.kind_of?(ActiveRecord::RecordNotFound)
      errors = invalid.message
    elsif invalid.kind_of?(ActiveRecord::RecordInvalid)
      errors = invalid.record.errors.full_messages.join(", ")
    else
      errors = invalid.to_s
    end
    render json: { errors: errors }, status: :bad_request
  end

  def method_not_allowed(errors)
    render json: { errors: errors }, status: :method_not_allowed
  end

  def current_user_email
    current_user.try(:[], :email)
  end

end
