class Recipient < Organisation
  has_many :grants
  has_many :features, dependent: :destroy

  PROFILE_MAX_FREE_LIMIT = 3

  def can_unlock_funder?(funder)
    profiles.count < PROFILE_MAX_FREE_LIMIT && profiles.count > unlocked_funders.size
  end

  def can_request_funder?(funder)
    features.build(data_requested: true, funder: funder).valid?
  end

  def unlocked_funder_ids
    RecipientFunderAccess.where(:recipient_id => self.id).map(&:funder_id)
  end

  def unlocked_funders
    Funder.where(:id => unlocked_funder_ids)
  end

  def locked_funders
    unlocked_funder_ids.any? ? Funder.where('id NOT IN (?)', unlocked_funder_ids) : Funder.all
  end

  def locked_funder?(funder)
    !unlocked_funder_ids.include?(funder.id)
  end

  def unlock_funder!(funder)
    RecipientFunderAccess.find_or_create_by({
        :recipient_id => self.id,
        :funder_id => funder.id
    })
  end

end
