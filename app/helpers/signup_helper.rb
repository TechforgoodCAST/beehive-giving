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
    (@recipient.charity_number.present? && @recipient.scrape_charity_data) || (@recipient.company_number.present? && @recipient.scrape_company_data)
  end

  def progress_step_helper(step, current)
    if current == step
      'is-active'
    elsif current > step
      'is-completed'
    end
  end

  def profile_state_step_helper(profile_state)
    case profile_state
    when 'beneficiaries'
      { count: 1, message: 'Who your organisation or project primarily benefits.' }
    when 'location'
      { count: 2, message: 'Where your organisation or project has an impact.' }
    when 'team'
      { count: 3, message: 'The workforce behind your organisation or project.' }
    when 'work'
      { count: 4, message: 'What your organisation or project provides.' }
    when 'finance'
      { count: 5, message: 'The finances of your organisation or project.' }
    end
  end
end
