class RemoveEmailFieldFromUser < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :email
  end
end
