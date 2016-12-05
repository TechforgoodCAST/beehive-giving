# TODO: deprecated
class FunderAttribute < ActiveRecord::Base

  before_validation :grant_count_from_grants,
                    :success_percentage,
                    :countries_from_grants,
                    :districts_from_grants,
                    :approval_months_from_grants,
                    :funding_type_from_grants,
                    :funding_size_and_duration_from_grants,
                    :funded_organisation_age,
                    :funded_organisation_income_and_staff,
                    :set_insights
  before_save :save_all_age_groups_if_all_ages

  belongs_to :funder

  has_and_belongs_to_many :countries
  has_and_belongs_to_many :districts
  has_and_belongs_to_many :funding_types
  has_and_belongs_to_many :approval_months
  has_and_belongs_to_many :beneficiaries
  has_and_belongs_to_many :age_groups

  serialize :map_data
  serialize :shared_recipient_ids

  validates :funder, :year, :countries, :funding_stream, :description, presence: true
  validates :soft_restrictions, presence: true

  validates :year, inclusion: {in: Profile::VALID_YEARS}
  validates :year, uniqueness: {scope: [:funding_stream, :funder_id], message: 'only one year per funder'}
  validates :funding_stream, uniqueness: {scope: [:year, :funder_id], message: 'only one funding stream of each kind per funder'}
  validates :application_link, format: {
    with: %r/^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/,
    multiline: true,
    message: "enter a valid website address e.g. www.example.com"}, if: :application_link

  # refactor dry?
  def save_all_age_groups_if_all_ages
    if self.age_group_ids.include?(AgeGroup.first.id)
      self.age_group_ids = AgeGroup.pluck(:id)
    end
  end

  def grant_count_from_grants
    if self.funder && self.funder.grants.count > 0
      if self.funding_stream == 'All'
        self.grant_count = funder.grants.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").count
        self.no_of_recipients_funded = funder.recent_grants(self.year).pluck(:recipient_id).uniq.count
      else
        self.grant_count = funder.grants.where('approved_on < ? AND approved_on >= ?', "#{self.year  + 1}-01-01", "#{self.year}-01-01").where('funding_stream = ?', self.funding_stream).count
        self.no_of_recipients_funded = funder.recent_grants(self.year).where('funding_stream = ?', self.funding_stream).pluck(:recipient_id).uniq.count
      end
    end
  end

  def success_percentage
    self.enquiry_count = ((self.funder.grants.count.to_d / self.application_count.to_d) * 100).round(0) if self.application_count && self.funder.grants.count > 0
  end

  def countries_from_grants
    if self.funder && self.countries.empty?
      if self.funding_stream == 'All'
        self.funder.countries.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").pluck(:alpha2).uniq.each do |c|
          self.countries << Country.find_by_alpha2(c) unless c.blank?
        end
      else
        self.funder.countries.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").where('funding_stream = ?', self.funding_stream).pluck(:alpha2).uniq.each do |c|
          self.countries << Country.find_by_alpha2(c) unless c.blank?
        end
      end
    end
  end

  def districts_from_grants
    if self.funder && self.districts.empty?
      if self.funding_stream == 'All'
        self.funder.districts.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").pluck(:district).uniq.each do |d|
          self.districts << District.find_by_district(d) unless d.blank?
        end
      else
        self.funder.districts.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").where('funding_stream = ?', self.funding_stream).pluck(:district).uniq.each do |d|
          self.districts << District.find_by_district(d) unless d.blank?
        end
      end
    end
  end

  def approval_months_from_grants
    if self.funder && self.approval_months.empty?
      array = []
      if self.funding_stream == 'All'
        self.funder.grants.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").pluck(:approved_on).uniq.each do |d|
          array << ApprovalMonth.find_by_month(d.strftime("%b"))
        end
        self.approval_months << array.uniq
      else
        self.funder.grants.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").where('funding_stream = ?', self.funding_stream).pluck(:approved_on).uniq.each do |d|
          array << ApprovalMonth.find_by_month(d.strftime("%b"))
        end
        self.approval_months << array.uniq
      end
    end
  end

  def funding_type_from_grants
    if self.funder && self.funding_types.empty?
      if self.funding_stream == 'All'
        self.funder.grants.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").pluck(:grant_type).uniq.each do |t|
          self.funding_types << FundingType.find_by_label(t) unless t.blank?
        end
      else
        self.funder.grants.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").where('funding_stream = ?', self.funding_stream).pluck(:grant_type).uniq.each do |t|
          self.funding_types << FundingType.find_by_label(t) unless t.blank?
        end
      end
    end
  end

  def funding_size_and_duration_from_grants
    if self.funder
      if self.funding_stream == 'All'
        self.funding_size_average = self.funder.grants.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").calculate(:average, :amount_awarded) if self.funding_size_average.nil?
        self.funding_size_min = self.funder.grants.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").calculate(:minimum, :amount_awarded) if self.funding_size_min.nil?
        self.funding_size_max = self.funder.grants.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").calculate(:maximum, :amount_awarded) if self.funding_size_max.nil?

        self.funding_duration_average = self.funder.grants.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").calculate(:average, :days_from_start_to_end) if self.funding_duration_average.nil?
        self.funding_duration_min = self.funder.grants.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").calculate(:minimum, :days_from_start_to_end) if self.funding_duration_min.nil?
        self.funding_duration_max = self.funder.grants.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").calculate(:maximum, :days_from_start_to_end) if self.funding_duration_max.nil?
      else
        self.funding_size_average = self.funder.grants.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").where('funding_stream = ?', self.funding_stream).calculate(:average, :amount_awarded) if self.funding_size_average.nil?
        self.funding_size_min = self.funder.grants.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").where('funding_stream = ?', self.funding_stream).calculate(:minimum, :amount_awarded) if self.funding_size_min.nil?
        self.funding_size_max = self.funder.grants.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").where('funding_stream = ?', self.funding_stream).calculate(:maximum, :amount_awarded) if self.funding_size_max.nil?

        self.funding_duration_average = self.funder.grants.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").where('funding_stream = ?', self.funding_stream).calculate(:average, :days_from_start_to_end) if self.funding_duration_average.nil?
        self.funding_duration_min = self.funder.grants.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").where('funding_stream = ?', self.funding_stream).calculate(:minimum, :days_from_start_to_end) if self.funding_duration_min.nil?
        self.funding_duration_max = self.funder.grants.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").where('funding_stream = ?', self.funding_stream).calculate(:maximum, :days_from_start_to_end) if self.funding_duration_max.nil?
      end
    end
  end

  def funded_organisation_age
    if self.funder && self.funder.recipients.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").where('funding_stream = ?', self.funding_stream).count == self.funder.recipients.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").where('funding_stream = ?', self.funding_stream).pluck(:founded_on).count
      if self.funder.grants.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").where('funding_stream = ?', self.funding_stream).count > 0
        if self.funding_stream == 'All'
          count = 0
          sum = 0.0
          self.funder.recipients.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").pluck(:founded_on).uniq.each do |d|
            count += 1
            sum += (Date.today - d) unless d.nil?
          end
          self.funded_average_age = (sum / count).round(1) if self.funded_average_age.nil?
        end
      else
        if self.funder.grants.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").where('funding_stream = ?', self.funding_stream).count > 0
          count = 0
          sum = 0.0
          self.funder.recipients.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").where('funding_stream = ?', self.funding_stream).pluck(:founded_on).uniq.each do |d|
            count += 1
            sum += (Date.today - d) unless d.nil?
          end
          self.funded_average_age = (sum / count).round(1) if self.funded_average_age.nil?
        end
      end
    end
  end

  def funded_organisation_income_and_staff
    if self.funder && self.funder.profiles.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").count < self.funder.grants.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").where('funding_stream = ?', self.funding_stream).count
      if self.funding_stream == 'All'
        unless self.funder.profiles.count < self.funder.grants.count
          self.funded_average_income = self.funder.profiles.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").calculate(:average, :income) if self.funded_average_income.nil?
          self.funded_average_paid_staff = self.funder.profiles.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").calculate(:average, :staff_count) if self.funded_average_paid_staff.nil?
        end
      else
        unless self.funder.profiles.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").count < self.funder.grants.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").where('funding_stream = ?', self.funding_stream).count
          self.funded_average_income = self.funder.profiles.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").where('funding_stream = ?', self.funding_stream).calculate(:average, :income) if self.funded_average_income.nil?
          self.funded_average_paid_staff = self.funder.profiles.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01").where('funding_stream = ?', self.funding_stream).calculate(:average, :staff_count) if self.funded_average_paid_staff.nil?
        end
      end
    end
  end

  # v2

  def recent_grants
    self.funder.grants.where('approved_on < ? AND approved_on >= ?', "#{self.year + 1}-01-01", "#{self.year}-01-01")
  end

  def order_by_count(data)
    data.sort_by {|_, v| v}.reverse.to_h
  end

  def build_insights(column, array)
    update_attribute(column, (array.count > 0 ? array.to_sentence : nil))
  end

  def set_approval_months_by_count
    array = []
    order_by_count(self.recent_grants.group_by_month(:approved_on).count).keys.each do |k|
      array << k.strftime('%b')
    end
    if array.count == 1 && array[0] == 'Jan'
      update_attribute(:approval_months_by_count, nil)
    else
      if array.count == 12
        update_attribute(:approval_months_by_count, 'every month of the year')
      else
        build_insights(:approval_months_by_count, array.take(3))
      end
    end
  end

  def set_countries_by_count
    build_insights(:countries_by_count,
      order_by_count(self.funder.countries_by_year.group(:name).count).keys.take(3)
    )
  end

  def set_regions_by_count
    build_insights(:regions_by_count,
      order_by_count(self.funder.districts_by_year.group(:district).count).keys.take(3)
    )
  end

  def set_funding_streams_by_count
    build_insights(:funding_streams_by_count,
      order_by_count(self.funder.grants.group(:funding_stream).count).keys.take(3)
    )
  end

  def set_funding_streams_by_giving
    build_insights(:funding_streams_by_giving,
      order_by_count(self.funder.grants.group(:funding_stream).calculate(:sum, :amount_awarded)).keys.take(3)
    )
  end

  def set_shared_recipient_ids
    self.update_column(:shared_recipient_ids, self.funder.shared_recipient_ids)
  end

  def set_insights
    self.set_approval_months_by_count
    self.set_countries_by_count
    self.set_regions_by_count
    self.set_funding_streams_by_count
    self.set_funding_streams_by_giving
    self.set_shared_recipient_ids
  end

end
