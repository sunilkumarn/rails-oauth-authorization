class Authorization < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id, :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider

  def self.find_from_omniauth_hash(hash)
    find_by_provider_and_uid(hash[:provider], hash[:uid])
  end
end
