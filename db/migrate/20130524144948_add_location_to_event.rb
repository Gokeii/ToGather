class AddLocationToEvent < ActiveRecord::Migration
  def change
  	add_column :events, :location, :string
  end
end
