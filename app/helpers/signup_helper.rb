module SignupHelper
  def org_type_hidden(state, type)
    if !state.present?
      false
    elsif state == type
      true
    elsif state == 3
      true
    end
  end

  def charity_hidden?(state)
    org_type_hidden(state, 1)
  end

  def company_hidden?(state)
    org_type_hidden(state, 2)
  end

  def scrape_success?
    (@recipient.charity_number.present? && @recipient.scrape_charity_data) ||
      (@recipient.company_number.present? && @recipient.scrape_company_data)
  end

  def progress_step_helper(step, current)
    if current == step
      'is-active'
    elsif current > step
      'is-completed'
    end
  end
end
