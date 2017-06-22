module SignupHelper
  def org_type_hidden(state, type)
    if !state.present?
      false
    elsif type.include? state
      true
    end
  end

  def charity_hidden?(state)
    org_type_hidden(state, [1,3])
  end

  def company_hidden?(state)
    org_type_hidden(state, [2,3,5])
  end

  def progress_step_helper(step, current)
    if current == step
      'is-active'
    elsif current > step
      'is-completed'
    end
  end
end
