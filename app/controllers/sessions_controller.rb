class SessionsController < ApplicationController
    skip_before_action :authorized, only: [:create]

    def create
        byebug
        @user = User.find_by(username: user_login_params[:username])
        if @user && @user.authenticate(user_login_params[:password])
          token = encode_token({ user_id: @user.id })
          render json: { user: @user, jwt: token }, status: :accepted
        else
          render json: { message: 'Invalid username or password' }, status: :unauthorized
        end
    end
    
    private

    def user_login_params
        {username: params["username"], password: params["password"]}
    end

end