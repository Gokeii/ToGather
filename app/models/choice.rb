class Choice < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :replies
  belongs_to :event

end
