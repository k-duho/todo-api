class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def authenticate_user
    unless current_user && current_user.token_expired_at > Time.current
      render json: { error: 'Unauthorized' }, status: :unauthorized and return
    end

    if current_user.token_expired_at - Time.current > 2.minutes
      refresh_token
    end
  end

  def current_user
    @current_user ||= User.find_by(token: request.headers['Authorization'])
  end

  private

  def refresh_token
    current_user.update(token: SecureRandom.hex,
                        token_expired_at: Time.current + 30.minutes)
  end

  def record_not_found
    render status: 404
  end
end
