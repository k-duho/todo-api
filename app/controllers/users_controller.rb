class UsersController < ApplicationController
  def sign_up
    user = User.new(users_params)
    if user.save
      render status: :created
    else
      render json: user.errors.full_messages, status: :unprocessable_entity
    end
  end

  private

  def users_params
    params.require(:users).permit(:name, :email, :password)
  end
end
