module SignupHelper

  def progress_step_helper(step, current)
    if current == step
      'is-active'
    elsif current > step
      'is-completed'
    else
      return
    end
  end

  def profile_state_step_helper(profile_state)
    case profile_state
    when 'beneficiaries'
      { count: 1, message: 'Who does your organisation or project primarily benefit?' }
    when 'location'
      { count: 2, message: 'Where your organisation or project has an impact.' }
    when 'team'
      { count: 3, message: 'The workforce behind your organisation or project.' }
    when 'work'
      { count: 4, message: 'What your organisation or project provides.' }
    when 'finance'
      { count: 5, message: 'The finances of your organisation or project.' }
    else
      return
    end
  end

end
