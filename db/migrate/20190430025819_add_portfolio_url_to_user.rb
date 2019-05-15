class AddPortfolioUrlToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :portfolio_url, :string
  end
end
