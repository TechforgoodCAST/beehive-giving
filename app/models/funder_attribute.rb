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

  validates :year, inclusion: { in: Profile::VALID_YEARS }
  validates :year, uniqueness: { scope: [:funding_stream, :funder_id], message: 'only one year per funder' }
  validates :funding_stream, uniqueness: { scope: [:year, :funder_id], message: 'only one funding stream of each kind per funder' }
  validates :application_link, format: {
    with: %r/^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/,
    multiline: true,
    message: 'enter a valid website address e.g. www.example.com'
  }, if: :application_link

  # refactor dry?
  def save_all_age_groups_if_all_ages
    if age_group_ids.include?(AgeGroup.first.id)
      self.age_group_ids = AgeGroup.pluck(:id)
    end
  end

  def grant_count_from_grants
    if funder && funder.grants.count.positive?
      if funding_stream == 'All'
        self.grant_count = funder.grants.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").count
        self.no_of_recipients_funded = funder.recent_grants(year).pluck(:recipient_id).uniq.count
      else
        self.grant_count = funder.grants.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").where('funding_stream = ?', funding_stream).count
        self.no_of_recipients_funded = funder.recent_grants(year).where('funding_stream = ?', funding_stream).pluck(:recipient_id).uniq.count
      end
    end
  end

  def success_percentage
    self.enquiry_count = ((funder.grants.count.to_d / application_count.to_d) * 100).round(0) if application_count && funder.grants.count.positive?
  end

  def countries_from_grants
    if funder && countries.empty?
      if funding_stream == 'All'
        funder.countries.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").pluck(:alpha2).uniq.each do |c|
          countries << Country.find_by_alpha2(c) unless c.blank?
        end
      else
        funder.countries.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").where('funding_stream = ?', funding_stream).pluck(:alpha2).uniq.each do |c|
          countries << Country.find_by_alpha2(c) unless c.blank?
        end
      end
    end
  end

  def districts_from_grants
    if funder && districts.empty?
      if funding_stream == 'All'
        funder.districts.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").pluck(:district).uniq.each do |d|
          districts << District.find_by_district(d) unless d.blank?
        end
      else
        funder.districts.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").where('funding_stream = ?', funding_stream).pluck(:district).uniq.each do |d|
          districts << District.find_by_district(d) unless d.blank?
        end
      end
    end
  end

  def approval_months_from_grants
    if funder && approval_months.empty?
      array = []
      if funding_stream == 'All'
        funder.grants.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").pluck(:approved_on).uniq.each do |d|
          array << ApprovalMonth.find_by_month(d.strftime('%b'))
        end
        approval_months << array.uniq
      else
        funder.grants.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").where('funding_stream = ?', funding_stream).pluck(:approved_on).uniq.each do |d|
          array << ApprovalMonth.find_by_month(d.strftime('%b'))
        end
        approval_months << array.uniq
      end
    end
  end

  def funding_type_from_grants
    if funder && funding_types.empty?
      if funding_stream == 'All'
        funder.grants.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").pluck(:grant_type).uniq.each do |t|
          funding_types << FundingType.find_by_label(t) unless t.blank?
        end
      else
        funder.grants.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").where('funding_stream = ?', funding_stream).pluck(:grant_type).uniq.each do |t|
          funding_types << FundingType.find_by_label(t) unless t.blank?
        end
      end
    end
  end

  def funding_size_and_duration_from_grants
    if funder
      if funding_stream == 'All'
        self.funding_size_average = funder.grants.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").calculate(:average, :amount_awarded) if funding_size_average.nil?
        self.funding_size_min = funder.grants.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").calculate(:minimum, :amount_awarded) if funding_size_min.nil?
        self.funding_size_max = funder.grants.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").calculate(:maximum, :amount_awarded) if funding_size_max.nil?

        self.funding_duration_average = funder.grants.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").calculate(:average, :days_from_start_to_end) if funding_duration_average.nil?
        self.funding_duration_min = funder.grants.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").calculate(:minimum, :days_from_start_to_end) if funding_duration_min.nil?
        self.funding_duration_max = funder.grants.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").calculate(:maximum, :days_from_start_to_end) if funding_duration_max.nil?
      else
        self.funding_size_average = funder.grants.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").where('funding_stream = ?', funding_stream).calculate(:average, :amount_awarded) if funding_size_average.nil?
        self.funding_size_min = funder.grants.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").where('funding_stream = ?', funding_stream).calculate(:minimum, :amount_awarded) if funding_size_min.nil?
        self.funding_size_max = funder.grants.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").where('funding_stream = ?', funding_stream).calculate(:maximum, :amount_awarded) if funding_size_max.nil?

        self.funding_duration_average = funder.grants.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").where('funding_stream = ?', funding_stream).calculate(:average, :days_from_start_to_end) if funding_duration_average.nil?
        self.funding_duration_min = funder.grants.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").where('funding_stream = ?', funding_stream).calculate(:minimum, :days_from_start_to_end) if funding_duration_min.nil?
        self.funding_duration_max = funder.grants.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").where('funding_stream = ?', funding_stream).calculate(:maximum, :days_from_start_to_end) if funding_duration_max.nil?
      end
    end
  end

  def funded_organisation_age
    if funder && funder.recipients.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").where('funding_stream = ?', funding_stream).count == funder.recipients.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").where('funding_stream = ?', funding_stream).pluck(:founded_on).count
      if funder.grants.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").where('funding_stream = ?', funding_stream).count.positive?
        if funding_stream == 'All'
          count = 0
          sum = 0.0
          funder.recipients.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").pluck(:founded_on).uniq.each do |d|
            count += 1
            sum += (Date.today - d) unless d.nil?
          end
          self.funded_average_age = (sum / count).round(1) if funded_average_age.nil?
        end
      else
        if funder.grants.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").where('funding_stream = ?', funding_stream).count.positive?
          count = 0
          sum = 0.0
          funder.recipients.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").where('funding_stream = ?', funding_stream).pluck(:founded_on).uniq.each do |d|
            count += 1
            sum += (Date.today - d) unless d.nil?
          end
          self.funded_average_age = (sum / count).round(1) if funded_average_age.nil?
        end
      end
    end
  end

  def funded_organisation_income_and_staff
    if funder && funder.profiles.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").count < funder.grants.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").where('funding_stream = ?', funding_stream).count
      if funding_stream == 'All'
        unless funder.profiles.count < funder.grants.count
          self.funded_average_income = funder.profiles.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").calculate(:average, :income) if funded_average_income.nil?
          self.funded_average_paid_staff = funder.profiles.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").calculate(:average, :staff_count) if funded_average_paid_staff.nil?
        end
      else
        unless funder.profiles.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").count < funder.grants.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").where('funding_stream = ?', funding_stream).count
          self.funded_average_income = funder.profiles.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").where('funding_stream = ?', funding_stream).calculate(:average, :income) if funded_average_income.nil?
          self.funded_average_paid_staff = funder.profiles.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01").where('funding_stream = ?', funding_stream).calculate(:average, :staff_count) if funded_average_paid_staff.nil?
        end
      end
    end
  end

  # v2

  def recent_grants
    funder.grants.where('approved_on < ? AND approved_on >= ?', "#{year + 1}-01-01", "#{year}-01-01")
  end

  def order_by_count(data)
    data.sort_by { |_, v| v }.reverse.to_h
  end

  def build_insights(column, array)
    update_attribute(column, (array.count.positive? ? array.to_sentence : nil))
  end

  def set_approval_months_by_count
    array = []
    order_by_count(recent_grants.group_by_month(:approved_on).count).keys.each do |k|
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
      order_by_count(funder.countries_by_year.group(:name).count).keys.take(3))
  end

  def set_regions_by_count
    build_insights(:regions_by_count,
      order_by_count(funder.districts_by_year.group(:district).count).keys.take(3))
  end

  def set_funding_streams_by_count
    build_insights(:funding_streams_by_count,
      order_by_count(funder.grants.group(:funding_stream).count).keys.take(3))
  end

  def set_funding_streams_by_giving
    build_insights(:funding_streams_by_giving,
      order_by_count(funder.grants.group(:funding_stream).calculate(:sum, :amount_awarded)).keys.take(3))
  end

  def set_shared_recipient_ids
    update_column(:shared_recipient_ids, funder.shared_recipient_ids)
  end

  def set_insights
    set_approval_months_by_count
    set_countries_by_count
    set_regions_by_count
    set_funding_streams_by_count
    set_funding_streams_by_giving
    set_shared_recipient_ids
  end

end
