class FollowsController < ApplicationController
    def index
        # Eager loading of favourited users for display on screen
        @saved = current_user.followers.includes(:skills)
        @followed_by = current_user.followees
        @mutuals = []
        @followed_by.each do |followee|
            @mutuals << followee if @saved.include?(followee)
        end
    end

    # Method for adding a person to the list of people they follow / favourite
    def create
        id = params[:id]
        @user = User.find(id)
        # Adds to followers but prevents adding more than once
        current_user.followers << @user unless current_user.followers.include?(@user)
        redirect_back(fallback_location: user_path(id))
    end
    
    # Method for removing a person from the list of favourites / people they follow
    def destroy
        id = params[:id]
        @user = User.find(id)
        Follow.where(follower_id: @user.id, followee_id: current_user.id).first.destroy
        redirect_back(fallback_location: user_path(id))
    end
end