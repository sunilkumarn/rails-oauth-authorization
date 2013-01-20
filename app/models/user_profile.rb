class UserProfile < ActiveRecord::Base
  belongs_to :user

  def auto_fill(omniauth_params)
    self.attributes.each do | attr, attr_val |
      self.send("#{attr}=", omniauth_params[attr.to_sym]) if attr_val.blank?
      self.save
    end
  end

end
