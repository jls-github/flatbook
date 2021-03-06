class UsersController < ApplicationController
    skip_before_action :authorized, only: [:create]

    def index
        users = User.all
        render json: users
    end

    def create
        @user = User.create(user_params)
        if @user.valid?
            render json: { user: @user }, status: :created
        else
            render json: { error: 'failed to create user' }, status: :unprocessable_entity
        end
    end

    private

    def user_params
        {username: params["username"], password: params["password"], password_confirmation: params["password_confirmation"]}
    end
end
