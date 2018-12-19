module CategoryName
  extend ActiveSupport::Concern

  included do
    # Lookup category name from {CATEGORIES} using #category_code.
    #
    # @return [String] the name of the category.
    def category_name
      self.class::CATEGORIES.values.reduce({}, :merge)[category_code]
    end
  end
end
