class Skill < ApplicationRecord
    # Associations through join table
    has_many :users_skills
    has_many :users, through: :users_skills
end
