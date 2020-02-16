class UsersController < ApplicationController
  before_action :authenticate_user!, :except => [:index, :show]
  before_action :set_user, only: [:show, :edit, :update]



  # GET /users
  # GET /users.json
  def index
      @users = User.all.order('created_at DESC')
  end




  # GET /users/1
  # GET /users/1.json
  def show

  end


  # GET /users/1/edit
  def edit
   @user = User.friendly.find(params[:id])
    
  end

  # POST /users


  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    
    @user = User.friendly.find(params[:id])
   

    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to @user, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end




  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
    @user = User.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:first_name, :last_name, :slug, :username, :country )
    end
end
