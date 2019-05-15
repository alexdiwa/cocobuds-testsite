class UsersSkill < ApplicationRecord
  # Join table associations
  belongs_to :user
  belongs_to :skill
end
