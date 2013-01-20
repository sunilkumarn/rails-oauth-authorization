class UserSession < Authlogic::Session::Base

  include ActiveModel::Conversion

  validate :check_if_verified

  def unverified_account?
    true unless self.errors[:unverified].empty?
  end

  private

  def check_if_verified
    if attempted_record
      errors.add(:unverified, "unverified_account") unless attempted_record.verified
    end
  end

end