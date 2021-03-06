class PostsController < ApplicationController
  # skip_before_action :login_required, :only => [:index]

  def new
    check_for_user
    @post = Post.new
  end

  def create
    check_for_user
    permitted_params = post_params
    permitted_params[:user_id] = session[:user]['id']
    @post = Post.create(permitted_params)
    redirect_to :posts
  end

  def index
    check_for_user
    @posts = Post.all.order(created_at: :desc)
  end

  def posts_api
    @posts = Post.all.order(created_at: :desc).as_json()
    @posts_with_name_and_likes = @posts.each do |post|
                       post[:user_name] = User.find(post["user_id"]).name
                       post[:short_time] = post['created_at'].strftime('%H:%M - %d/%h')
                       post[:number_of_likes] = Like.where(post_id: post["id"]).length
    end

    render json: @posts_with_name_and_likes, status: :created

  end

  def destroy
    Like.where(post_id: params['post_id']).destroy_all
    Post.destroy( params['post_id'])
  end

  private

  def post_params
    params.require(:post).permit(:message, :user_id)
  end

  def check_for_user
    if session[:user] === nil
      redirect_to new_user_url
    end
  end
end
