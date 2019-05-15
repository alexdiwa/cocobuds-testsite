class Message < ApplicationRecord
  # Associations
  belongs_to :conversation
  belongs_to :user

  # Validation
  validates_presence_of :body, :conversation_id, :user_id

  # Sanitising time for display on inbox and on message threads
  def inbox_time
    created_at.strftime("%l:%M %p on %A %d %b '%y")
  end

  def msg_time
    created_at.strftime("%l:%M %p on %a %d %b '%y")
  end
end
