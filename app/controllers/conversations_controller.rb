class ConversationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.where.not(id: current_user.id)
    @conversations = Conversation.where("sender_id = ? OR receiver_id = ?", current_user.id, current_user.id).joins(:messages).order("messages.updated_at DESC").uniq
    
    # fallback for conversations that are created if user clicks to message someone but doesn't write anything
    @conversations.each { |conversation| conversation.destroy if conversation.messages.blank? }
    # deletes conversations if one of the users has deleted their profile
    @conversations.each { |conversation| conversation.destroy if !User.exists?(conversation.sender_id) or !User.exists?(conversation.receiver_id) }
   
    # for rendering something different if a user has no messages
    @show_empty = false
    @show_empty = true if @conversations.all? { |conversation| conversation.messages.blank? }
  end

  def create
    if Conversation.between(params[:sender_id], params[:receiver_id]).present?
      @conversation = Conversation.between(params[:sender_id], params[:receiver_id]).first
    else
      @conversation = Conversation.create!(conversation_params)
    end

    redirect_to conversation_messages_path(@conversation)
  end

  private
    def conversation_params
      params.permit(:sender_id, :receiver_id)
    end
end