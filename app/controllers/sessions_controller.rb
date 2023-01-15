class SessionsController < ApplicationController
  def login
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      user.update(token: SecureRandom.hex, token_expired_at: Time.current + 30.minutes)
      render json: { token: user.token }, status: :created
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end
end
