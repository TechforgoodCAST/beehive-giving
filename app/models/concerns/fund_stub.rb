class FundStub
  include ActiveModel::Model

  attr_accessor :funder, :name, :description, :themes

  validates :funder, :name, :description, :themes, presence: true
  validate :type_of_funder, :type_of_themes

  private

    def type_of_funder
      errors.add(:funder, 'not a type of Funder') unless funder.is_a?(Funder)
    end

    def type_of_themes
      errors.add(:themes, 'not a type of Array') unless themes.is_a?(Array)
    end
end
