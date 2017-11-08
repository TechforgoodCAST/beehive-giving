class FundStub
  include ActiveModel::Model

  attr_accessor :funder, :name, :description, :themes, :geo_area

  validates :funder, :name, :description, :themes, :geo_area, presence: true
  validate :type_of_funder, :type_of_themes, :type_of_geo_area

  private

    def type_of_funder
      type_of_object(:funder, Funder)
    end

    def type_of_geo_area
      type_of_object(:geo_area, GeoArea)
    end

    def type_of_themes
      type_of_object(:themes, Array)
    end

    def type_of_object(field, object)
      errors.add(field, "not a type of #{object.name}") unless send(field).is_a?(object)
    end
end
