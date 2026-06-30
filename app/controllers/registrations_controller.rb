class RegistrationsController < ApplicationController
  allow_unauthenticated_access, only: [ :new, :create ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)
    if @user.save
      start_new_session_for(@user)
      redirect_to root_path, notice: "Welcome!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user
    @user.update(registration_params)

    if @user.save
      redirect_to root_path, notice: "Updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:email_address, :username, :password, :password_confirmation)
  end
end
