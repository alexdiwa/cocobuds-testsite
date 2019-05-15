class Follow < ApplicationRecord
    # Associations for followers/favourites
    belongs_to :follower, class_name: 'User'
    belongs_to :followee, class_name: 'User'
end
