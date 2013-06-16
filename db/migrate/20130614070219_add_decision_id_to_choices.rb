class AddDecisionIdToChoices < ActiveRecord::Migration
  def change
  	add_column :choices, :decision_id, :integer 
  end
end
