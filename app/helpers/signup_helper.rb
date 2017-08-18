module SignupHelper
  def progress_step_helper(step, current)
    if current == step
      'is-active'
    elsif current > step
      'is-completed'
    end
  end
end
