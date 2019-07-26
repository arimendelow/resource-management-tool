class UsersController < ApplicationController
  # Restrict the filters to act only on the :edit and :update actions
  # This one is in the users_helper
  before_action :logged_in_user,  only: [:edit, :update, :index, :destroy, :following, :followers]
  before_action :correct_user,    only: [:edit, :update]
  before_action :admin_user,      only: :destroy

  def index
    # Only show activated users in the index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    # If the user exists...
    if User.exists?(params[:id])
      @user = User.find(params[:id])
      # If the user is not yet activated, return to the root and notify the user
      if @user.activated? != true
        flash[:warning] = "This account has not been activated."
        redirect_to root_url
      end
      # Else, load up the user's microposts (with pagination):
      @microposts = @user.microposts.paginate(page: params[:page])
    # Otherwise, notify the user that this account does not exist
    else
      flash[:warning] = "This account does not exist."
      redirect_to root_url
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please follow the link in your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile Updated!"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    user_name = User.find(params[:id]).name
    User.find(params[:id]).destroy
    flash[:success] = "User #{user_name} deleted."
    redirect_to users_url
  end

  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private
    # Returns a version of the 'params' hash with ONLY the permitted attributes, and raises an error if the :user attribute is missing
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    # Before filters - for using with the 'before_action' command 
    # to arrange for a particular method to be called before the given actions

    # For making sure that a user is only trying to edit himself
    def correct_user
      @user = User.find(params[:id])
      # In addition to the syntax in the above method, if we're only running one command we can put the 'unless' statement on a single line
      redirect_to(root_url) unless current_user?(@user)
    end

    # Confirms an admin user
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
