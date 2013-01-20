class User < ActiveRecord::Base

  has_one :user_profile
  has_many :apps
  has_many :authorizations
  has_many :notifications

  accepts_nested_attributes_for :user_profile

  acts_as_authentic do |config|
    config.login_field = 'email_id'
    config.validate_login_field  = false
    config.validate_password_field = false
  end

  disable_perishable_token_maintenance(true)

  after_create :create_user_profile
  attr_accessor :password_required
  attr_accessible :user_name, :email_id, :password, :password_confirmation, :user_profile_attributes

  email_regex = /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  user_name_regex = /^[a-zA-Z0-9_]+$/
  password_regex = /^(?=.*[!,%,&,@,#,$,^,*,?,_,~])(?=.*[a-z])(?=.*[0-9])(?=.*[A-Z])\S{8,}$/

  validates :user_name, :presence => true, :uniqueness => {:case_sensitive => false}, :format => {:with => user_name_regex, :message => 'can have only alphabets, numerals and underscores'}, :length => { :in => 6..14}, :on => :create
  validates :password, :presence => true, :confirmation => true, :length => {:minimum => 8}, :format => {:with => password_regex, :message => 'should have an upper case, lower case, numeral and a special character'}, :if => :password_required?
  validates :email_id, :presence => true, :uniqueness => true, :format => {:with => email_regex, :message => 'is not valid'}

  USER_TYPES = {0 => 'admin', 1=> 'reviewer', 2 => 'developer'}

  def to_param
    "#{user_name}"
  end

  def create_user_profile
    UserProfile.create!(:user_id => self.id)
  end

  def new_omniauth_authorizer(omniauth_params)
    self.authorizations.create(:provider => omniauth_params[:provider], :uid => omniauth_params[:uid])
    self.user_profile.auto_fill(omniauth_params)
  end

  def password_required?
    return true unless self.password.nil? and self.password_confirmation.nil?
    false
  end

  def verify!
    self.verified = true
    self.save!
  end

  def omniauth_provider_exists? provider
    user_authorizations = self.authorizations.collect { |authorization| authorization.provider }
    return true if user_authorizations.include? provider
  end

end
