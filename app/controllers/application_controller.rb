class ApplicationController < ActionController::Base
  before_action :conversation_count

  def after_sign_in_path_for(resource)
    users_path
  end

  private

  def conversation_count
    if user_signed_in?
      conversations = Conversation.where("sender_id = ? OR receiver_id = ?", current_user.id, current_user.id)
      @total_unread = 0
      conversations.each { |conversation| @total_unread += conversation.unread_message_count(current_user) }
      @total_unread
    end
  end

end
