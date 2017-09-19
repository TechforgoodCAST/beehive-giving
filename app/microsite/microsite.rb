class Microsite
  attr_reader :step

  def initialize(step)
    @step = step
    %i[save transition].each do |method|
      next if @step.respond_to? method
      raise NoMethodError, "undefined method #{method} for #{@step.inspect}"
    end
  end

  def save
    @step.save
  end

  def transition
    @step.transition
  end
end
