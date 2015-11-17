class Funder < Organisation

  has_many :grants
  has_many :districts, :through => :grants
  has_many :countries, :through => :grants
  has_many :countries_by_year, -> (object) { where('grants.approved_on <= ? AND grants.approved_on >= ?', "#{object.current_attribute.year}-12-31", "#{object.current_attribute.year}-01-01") }, :through => :grants, :source => :countries
  has_many :districts_by_year, -> (object) { where('grants.approved_on <= ? AND grants.approved_on >= ?', "#{object.current_attribute.year}-12-31", "#{object.current_attribute.year}-01-01") }, :through => :grants, :source => :districts

  has_many :features
  has_many :enquiries

  has_many :funder_attributes, dependent: :destroy
  has_many :approval_months, :through => :funder_attributes
  has_many :beneficiaries, :through => :funder_attributes

  has_many :recipients, :through => :grants
  has_many :profiles, :through => :recipients, dependent: :destroy

  has_and_belongs_to_many :funding_streams
  has_many :restrictions, :through => :funding_streams

  alias_method :attributes, :funder_attributes

  has_many :recommendations

  scope :active, -> {where(active_on_beehive: true)}

  FUNDERS_WITH_WIDE_LAYOUT = ['Big Lottery Fund',
                              'City Bridge Trust',
                              'The Joseph Rowntree Charitable Trust',
                              'Oak Foundation',
                              'The Rayne Foundation',
                              'The Trusthouse Charitable Foundation']

  CLOSED_FUNDERS = ['Cripplegate Foundation']

  def eligible_organisations
    array = []
    Recipient.joins(:eligibilities).order(:id).uniq.each do |recipient|
      array << recipient if recipient.eligible?(self)
    end
    array
  end

  def current_attribute
    # self.attributes.where('funding_stream = ? AND grant_count > ?', 'All', 0).order(year: :desc).first
    self.attributes.where(funding_stream: 'All').order(year: :desc).first
  end

  def recent_grants
    self.grants.where('approved_on < ? AND approved_on >= ?', "#{self.current_attribute.year + 1}-01-01", "#{self.current_attribute.year}-01-01")
  end

end
