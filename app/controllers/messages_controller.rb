class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [:index, :create]
  before_action :authorise_user, only: [:index]
  before_action :same_user_check, only: [:index]

  def index
    # Sort messages by order of creation
    @messages = @conversation.messages.order(:created_at)
    if @conversation.sender_id == current_user.id
      @user = User.find(@conversation.receiver_id)
    else
      @user = User.find(@conversation.sender_id)
    end
    # Updating all messages to 'read' once the individual message thread is opened
    @messages.where("user_id != ? AND read = ?", current_user.id, false).update_all(read: true)
    @message = @conversation.messages.new
  end

  def create
    @message = @conversation.messages.new(message_params)
    @message.user = current_user

    if @message.save
      redirect_to conversation_messages_path(@conversation)
    end
  end

  private
    def set_conversation
      @conversation = Conversation.find(params[:conversation_id])
    end

    def message_params
      params.require(:message).permit(:body, :user_id)
    end

    # Preventing users from trying to send messages to themselves
    def same_user_check
      if @conversation.receiver_id == @conversation.sender_id
        redirect_to user_path(current_user.id), notice: 'You can\'t send a message to yourself!'
      end
    end

    # Preventing users from accessing other people's conversations
    def authorise_user
      if @conversation.receiver_id != current_user.id and @conversation.sender_id != current_user.id
        redirect_to conversations_path, alert: 'Not authorised to perform this action'        
      end
    end
end