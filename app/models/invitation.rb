class Invitation < ActiveRecord::Base
  # attr_accessible :title, :body
  has_one :reply
  belongs_to :event
  belongs_to :user
end
