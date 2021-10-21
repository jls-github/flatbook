class ApplicationController < ActionController::API
    before_action :authorized

    def encode_token(payload)
        JWT.encode(payload, 'my_s3cr3t') # make sure to hide your secret in an environment variable before hosting your application!
    end
  
    def current_user
        user_id = decoded_token[0]['user_id']
        @cached_current_user ||= User.find_by(id: user_id)
    end
    
    def authorized
        unauthorized_user_response unless valid_token? && logged_in? 
    end
    
    private
    
    def auth_header
        @cached_auth_header ||= request.headers['Authorization']
    end
    
    def header_token
        @cached_header_token ||= auth_header.split(' ')[1]
    end
    
    def decoded_token
        begin 
            @cached_decoded_token ||= JWT.decode(header_token, 'my_s3cr3t', true, algorithm: 'HS256')
        rescue JWT::DecodeError
            nil
        end
    end
    
    def valid_token?
        !!(auth_header && header_token && decoded_token)
    end
    
    def logged_in?
        !!current_user
    end

    def unauthorized_user_response
        render json: { message: 'Please log in' }, status: :unauthorized
    end
    
end