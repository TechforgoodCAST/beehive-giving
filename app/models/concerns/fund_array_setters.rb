module FundArraySetters
  extend ActiveSupport::Concern

  def tags=(arr)
    self[:tags] = arr.reject(&:blank?)
  end

  def permitted_costs=(arr)
    parse_array :permitted_costs, arr
  end

  def permitted_org_types=(arr)
    parse_array :permitted_org_types, arr
  end

  private

    def parse_array(field, arr)
      self[field] = arr.reject(&:blank?).map(&:to_i)
    end
end
