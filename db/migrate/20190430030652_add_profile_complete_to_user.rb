class AddProfileCompleteToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :profile_complete, :boolean, null: false, default: false
  end
end
