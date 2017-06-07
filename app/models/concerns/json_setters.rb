module JsonSetters
  extend ActiveSupport::Concern

  def tags=(arr)
    parse_json :tags, arr.reject { |i| i == '' }
  end

  def sources=(json)
    parse_json :sources, json
  end

  def amount_awarded_distribution=(json)
    parse_json :amount_awarded_distribution, json
  end

  def award_month_distribution=(json)
    parse_json :award_month_distribution, json
  end

  def org_type_distribution=(json)
    parse_json :org_type_distribution, json
  end

  def income_distribution=(json)
    parse_json :income_distribution, json
  end

  def country_distribution=(json)
    parse_json :country_distribution, json
  end

  def beneficiary_distribution=(json)
    parse_json :beneficiary_distribution, json
  end

  private

    def parse_json(field, json)
      self[field] = JSON.parse json
    rescue TypeError
      self[field] = JSON.parse json.to_json
    end
end
