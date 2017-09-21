class Microsite
  attr_reader :step

  def initialize(step)
    @step = step
    return if @step.respond_to? :save
    raise NoMethodError, "undefined method save for #{@step.inspect}"
  end

  def save
    @step.save
  end
end
