class Microsite
  attr_reader :step

  def initialize(step)
    @step = step
    return if step.respond_to? :save
    raise NotImplementedError, "#{step.class} does not respond to #save"
  end

  def save
    step.save
  end
end
