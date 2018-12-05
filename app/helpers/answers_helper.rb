module AnswersHelper
  def yes_selected?(eligible, inverted)
    case [eligible, inverted]
    when [true, false]
      false
    when [false, true]
      false
    when [true, true]
      true
    when [false, false]
      true
    else
      nil
    end
  end
end
