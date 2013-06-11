class SetDefaultToIsclosed < ActiveRecord::Migration
	def change
		change_column :events, :is_closed, :boolean, :default => false
	end
end
