class Authorization < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id, :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider

  def self.find_from_omniauth_hash(hash)
    find_by_provider_and_uid(hash[:provider], hash[:uid])
  end

  def self.extract_user_attributes(hash)
    user_credentials = hash['credentials'] || {}
    user_info = hash['info'] || {}
    user_hash = hash['extra'] ? (hash['extra']['user_hash'] || {}) : {}
    {
        :provider => hash['provider'],
        :uid => hash['uid'],
        :token => user_credentials['token'],
        :secret => user_credentials['secret'],
        :full_name => user_info['name'],
        :email => (user_info['email'] || user_hash['email']),
        :nickname => user_info['nickname'],
        :last_name => user_info['last_name'],
        :first_name => user_info['first_name'],
        :link => (user_info['link'] || user_hash['link']),
        :photo_url => (user_info['image'] || user_hash['image']),
        :locale => (user_info['locale'] || user_hash['locale']),
        :location => (user_info['location'] || user_hash['location']),
        :about => (user_info['description'] || user_hash['description']),
        :avatar_url => user_info['image']
    }
  end

end
