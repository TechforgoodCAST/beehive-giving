module CriteriaFor
  extend ActiveSupport::Concern

  included do
    def criteria_for(category, questions)
      send(questions).where(category: category.to_s.classify).distinct
    end
  end
end
