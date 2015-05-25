class Recipient < Organisation
  has_many :grants
  has_many :features, dependent: :destroy
  has_many :enquiries
  has_many :eligibilities
  has_many :restrictions, :through => :eligibilities
  accepts_nested_attributes_for :eligibilities

  PROFILE_MAX_FREE_LIMIT = 4

  def recipient_profile_limit
    if (Date.today.year - self.founded_on.year) < 4
      (Date.today.year - self.founded_on.year) + 1
    else
      4
    end
  end

  def can_unlock_funder?(funder)
    profiles.count <= PROFILE_MAX_FREE_LIMIT && profiles.count > unlocked_funders.size
  end

  def can_request_funder?(funder, request)
    features.build("#{request}" => true, :funder => funder).valid?
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

  def valid_profile_years
    if profiles.last.year.present?
      a = Profile::VALID_YEARS - profiles.map(&:year)
      a.unshift(profiles.last.year)
    else
      Profile::VALID_YEARS - profiles.map(&:year)
    end
  end

  def can_create_profile?
    profiles.count <= Date.today.year - self.founded_on.year unless profiles.count == 4
  end

  def eligibility_count(funder)
    count = 0

    funder.restrictions.uniq.each do |r|
      self.eligibilities.each do |e|
        count += 1 if e.restriction_id == r.id
      end
    end

    count
  end

  def funding_stream_eligible?(funding_stream, funder)
    count = 0

    funder.funding_streams.where('label = ?', funding_stream).first.restrictions.each do |r|
      self.eligibilities.each do |e|
        count += 1 if e.restriction_id == r.id && e.eligible == true
      end
    end

    funder.funding_streams.where('label = ?', funding_stream).first.restrictions.count == count ? true : false
  end

  def eligible?(funder)
    count = 0

    funder.funding_streams.each do |f|
      count += 1 if self.funding_stream_eligible?(f.label, funder)
    end

    count > 0 ? true : false
  end

  def questions_remaining?(funder)
    self.eligibility_count(funder) < funder.restrictions.uniq.count
  end

end
