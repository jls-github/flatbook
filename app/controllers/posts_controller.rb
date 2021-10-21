class PostsController < ApplicationController

    def index
        posts = Post.all
        render json: posts
    end

    def create
        post = Post.new(post_params)
        render json: post, status: :created
    end

    private

    def post_params
        params.require(:post).permit(:content, :user_id)
    end

end
