class ChoiceReplyship < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :reply
  belongs_to :choice
end
