class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:index, :edit, :show, :new]
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :search, only: [:index, :home, :preview]
  before_action :authorize_user, only: [:edit, :update, :destroy]
  before_action :set_roles_locations_skills, only: [:new, :edit]
  before_action :redirect_to_donate, only: [:index, :show, :edit, :new]
  before_action :redirect_to_update_profile, only: [:index, :show, :edit]
  before_action :update_skills, only: [:update]

  def index
  end

  def home
  end 

  def preview
  end 

  def show
    # Fallback so that users can't access other users profiles if their own profile isn't complete
    if @user.profile_complete != true
      redirect_to users_path
    else
      location_id = @user.location_id 
      @location = Location.find(location_id)
    end
  end

  def new
    @user = current_user
  end

  def edit
  end

  def create
    # Omitted because Devise creates user, and User only ever updates user after Devise creation.
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_path, notice: 'Profile saved!' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end

    if @user.first_name && @user.last_name && @user.role && @user.location_id
      @user.profile_complete = true
      @user.save
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def search 
      # Eager loading the pool of users ordered alphabetically by last name, only showing those with completed profiles
      @users = User.all.order(:last_name).where(profile_complete: true).includes(:skills)

      # Filter search by first name and/or last name
      unless params[:string].blank?
      @users = @users.where("lower(first_name || ' ' || last_name) LIKE ?", "%#{params[:string].downcase}%")
      end 
      
      # Filter search by location
      @locations = Location.all.pluck(:name)
      unless params[:location].blank?
        @location_name = params[:location]
        location_id = Location.find_by(name: @location_name)
        @users = @users.where(location_id: location_id)
      end
      
      # Filter search by designer/developer
      @roles = User.roles.keys
      unless params[:role].blank?
        @role_name = params[:role]
        role_enum = User.roles[@role_name]
        @users = @users.where(role: role_enum)
      end
      
      # Filter search by single skill (for home/landing page)
      skilled_users = []
      unless params[:skill].blank?
        @skill_name = params[:skill]
        skill_id = Skill.find_by(name: @skill_name).id
        @users.each do |user|
          skilled_users << user if user.skills.ids.include?(skill_id)
        end 
        # @users = skilled_users
        @users = User.where(id: skilled_users.map(&:id))
      end 
      
    
      # Filter search by skills for index page (primary search)
      @skills = Skill.all
      unless params[:skills].blank?
        # Converting all skill ids passed through params to integers, yielding an array e.g. [1, 2, 3]
        skill_ids = params[:skills].map { |skill_id| skill_id.to_i }
        # initialising empty array of users who have matching skills
        @users.each do |user| 
          # adding the user to the skilled users array if the user knows all of the skills passed through the checkbox form
          skilled_users << user if skill_ids.all? { |skill| user.skills.ids.include?(skill) }
        end
        @users = User.where(id: skilled_users.map(&:id))

      end

    # returning the filtered list of users after performing all relevant search methods
    @users = @users.page(params[:page])
    end 

    # Defining instance variables
    def set_roles_locations_skills
      @roles = User.roles.keys
      @locations = Location.all
      @skills = Skill.all
      # Defines skills that the current user knows for pre-checking checkboxes
      @selected_skills = current_user.skills.pluck(:name)
    end

    # Method to add skills to current user's skills when checkboxes marked
    def update_skills
      current_user.skills = []
      @skill_ids = params[:skills]
      @skill_ids.each { |skill_id| current_user.skills << Skill.find(skill_id) } unless @skill_ids.blank?
    end

    def set_user
      id = params[:id]
      @user = User.find(id)
    end

    # Prevent user from performing unauthorized actions i.e. editing someone else's profile
    def authorize_user
      if @user.id != current_user.id || current_user.id == 1
        redirect_to users_path, notice: 'You are not authorised to perform this action.'
      end
    end

    # Whitelisting parameters for forms
    def user_params
      params.require(:user).permit(:picture, :first_name, :last_name, :age, :role, :skills, :bio, :portfolio_url, :occupation, :location_id)
    end

    # Redirecting users back to donate page, preventing them from entering unless payment successful
    def redirect_to_donate
       if current_user.stripe_payment != true
        redirect_to "/pages/donate", notice: 'Please donate before continuing.'
       end
    end

    # Preventing users from searching/viewing other users unless their profile is complete
    def redirect_to_update_profile
      if current_user.profile_complete != true
        redirect_to new_user_path, notice: 'You need to fill in your profile before you proceed!'
      end
    end
end
