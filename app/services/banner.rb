class Banner
  def initialize(assessment)
    @status = assessment&.suitability_status
  end

  def background
    "bg-light-#{color} border-pale-#{color}"
  end

  def color
    {
      nil        => 'yellow',
      'approach' => 'green',
      'unclear'  => 'yellow',
      'avoid'    => 'red'
    }[@status]
  end

  def indicator
    "bg-#{color}"
  end

  def text
    {
      nil        => 'Unclear if you should apply',
      'approach' => 'Minimum standard of application met',
      'unclear'  => 'Unclear if you should apply',
      'avoid'    => 'Avoid this opportunity'
    }[@status]
  end
end
