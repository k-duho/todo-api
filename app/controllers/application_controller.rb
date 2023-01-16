class ApplicationController < ActionController::API
  def authenticate_user
    unless current_user
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def current_user
    @current_user ||= User.find_by(token: request.headers['Authorization'])
  end
end
