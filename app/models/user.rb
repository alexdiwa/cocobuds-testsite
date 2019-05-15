class User < ApplicationRecord
  before_save :sanitize_strings
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Defining Role enum
  enum role: { Developer: 0, Designer: 1 }

  # Associations
  has_one :location
  has_many :users_skills, dependent: :destroy
  has_many :skills, through: :users_skills
  has_many :messages, dependent: :destroy
  has_many :followed_users, foreign_key: :follower_id, class_name: 'Follow'
  has_many :followees, through: :followed_users
  has_many :following_users, foreign_key: :followee_id, class_name: 'Follow'
  has_many :followers, through: :following_users
  has_one_attached :picture

  # validates :first_name, :last_name, :role, :location_id, presence: true, :on => :update, :if => :run_form_validation

  private
    # Clean up strings before they are saved to database
    def sanitize_strings
      self.first_name = self.first_name.strip.titleize unless self.first_name.blank?
      self.last_name = self.last_name.strip.titleize unless self.last_name.blank?
      self.occupation = self.occupation.strip.titleize unless self.occupation.blank?
    end
    
  # Validation attempted here but required 2-step process (Devise creation for email and password, and then profile update after donation)
  # Validation with if/unless prevented intermediary stripe_payment from being saved 
  # and user kept being redirected to donation page
  # Put validation in controller and check for @user attributes i.e.:
  # if @user.first_name && @user.last_name && @user.role && @user.location_id

end