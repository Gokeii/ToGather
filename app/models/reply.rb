class Reply < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :invitation
  has_many :choices

end
