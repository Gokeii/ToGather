class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :user_id, :name, :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body

  has_one :device
  has_many :events
  has_many :invitations
  has_many :replies

  before_save :ensure_authentication_token

  #support gravatar
  include Gravtastic
  gravtastic
end
