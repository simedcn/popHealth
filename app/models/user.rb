require 'uniq_validator'

class User

  include Mongoid::Document
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :authentication_keys => [:username]

  field :first_name, type: String
  field :last_name, type: String
  field :username, type: String
  field :email, type: String
  field :company, type: String
  field :company_url, type: String
  field :registry_id, type: String
  field :registry_name, type: String

  field :agree_license, type: Boolean
  field :effective_date, type: Integer
  field :admin, type: Boolean
  field :approved, type: Boolean
  field :disabled, type: Boolean

  validates_presence_of :first_name, :last_name

  validates_uniqueness_of :username
  validates_uniqueness_of :email

  validates_acceptance_of :agree_license, :accept => true

  validates :email, presence: true, length: {minimum: 3, maximum: 254}, format: {with: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i}
  validates :username, :presence => true, length: {minimum: 3, maximum: 254}

  def active_for_authentication? 
    super && approved? && !disabled?
  end

  def inactive_message
    if !approved?
      :not_approved
    else
      super # Use whatever other message
    end
  end

  # =============
  # = Accessors =
  # =============
  def selected_measures
    MONGO_DB['selected_measures'].find({:username => username}).to_a #need to call to_a so that it isn't a cursor
  end

  # ==========
  # = FINDERS =
  # ==========

  def self.find_by_username(username)
    User.first(:conditions => {:username => username})
  end

  # =============
  # = Modifiers =
  # =============

  def grant_admin
    update_attributes(:admin => true)
    update_attributes(:approved => true)
  end

  def approve
    update_attributes(:approved => true)
  end

  def revoke_admin
    update_attributes(:admin => false)
  end

end
