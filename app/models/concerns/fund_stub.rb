class FundStub
  include ActiveModel::Model

  ATTRIBUTES = %i[funder name description themes geo_area].freeze

  attr_accessor :fund, :funder, :name, :description, :themes, :geo_area

  validates :funder, :name, :description, :geo_area, presence: true
  validate :type_of_funder, :type_of_themes, :type_of_geo_area

  validates :themes, presence: true, unless: -> { state == 'draft' }

  def initialize(opts = {})
    super
    @fund = opts[:fund]
    parse_and_set_attributes(@fund)
  end

  def state
    fund&.state || 'draft'
  end

  def save
    if valid?
      Fund.new(ATTRIBUTES.map { |a| [a, send(a)] }.to_h).save(validate: false)
    else
      false
    end
  end

  private

    def parse_and_set_attributes(fund)
      return unless fund
      attributes = fund.slice(ATTRIBUTES)
      attributes[:themes] = attributes[:themes].to_a
      assign_attributes(attributes)
    end

    def type_of_funder
      type_of_object(:funder, Funder)
    end

    def type_of_geo_area
      type_of_object(:geo_area, GeoArea)
    end

    def type_of_themes
      return if state == 'draft'
      type_of_object(:themes, Array)
    end

    def type_of_object(field, object)
      errors.add(field, "not a type of #{object.name}") unless send(field).is_a?(object)
    end
end
