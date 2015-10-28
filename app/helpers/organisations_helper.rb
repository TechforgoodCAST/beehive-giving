module OrganisationsHelper

  def funding_frequency_distribution(funder, year)
    # if @funding_stream == 'All'
    grants = funder.grants
      .where("approved_on < ? AND approved_on >= ?", "#{year + 1}-01-01", "#{year}-01-01")
    # else
    #   grants = funder.grants
    #     .where("approved_on < ? AND approved_on >= ?", "#{year + 1}-01-01", "#{year}-01-01")
    #     .where("funding_stream = ?", @funding_stream)
    # end

    range_limit = 475000
    increment = grants.calculate(:maximum, :amount_awarded) < range_limit ? 5 : 25

    range = grants.calculate(:maximum, :amount_awarded) < range_limit ? grants.calculate(:maximum, :amount_awarded) : grants.calculate(:minimum, :amount_awarded) + range_limit
    count = (range / (increment * 1000)) + 1
    max = grants.calculate(:maximum, :amount_awarded) + (increment * 1000)

    data = []
    count.times do |i|
      start_amount = i * (increment * 1000)
      end_amount = (i * (increment * 1000)) + (increment * 1000)

      data << {
        target: "#{number_to_currency(i * increment, unit: '£', precision: 0)}k - #{number_to_currency(i * increment + increment, unit: '£', precision: 0)}k",
        grant_count: grants.where('amount_awarded >= ? AND amount_awarded < ?', start_amount, end_amount).count
      }
    end

    unless grants.calculate(:maximum, :amount_awarded) < range_limit
      data << {
        target: "Above #{number_to_currency(count * increment, unit: '£', precision: 0)}k",
        grant_count: grants.where('amount_awarded >= ? AND amount_awarded <= ?', (count * increment) * 1000, grants.calculate(:maximum, :amount_awarded)).count
      }
    end

    data
  end

  def multiple_funding_frequency_distribution(funders)
    increment = 5
    data = []

    max = 45000
    count = (max / (increment * 1000)) + 1

    count.times do |i|
      start_amount = i * (increment * 1000)
      end_amount = (i * (increment * 1000)) + (increment * 1000)

      hash = {
        target: "#{number_to_currency(i * increment, unit: '£', precision: 0)}k - #{number_to_currency(i * increment + increment, unit: '£', precision: 0)}k"
      }

      funders.each_with_index do |funder, f|
        hash[:"funder#{f+1}"] = funder.grants.where('approved_on < ? AND approved_on >= ?', '2015-01-01', '2014-01-01').where('amount_awarded >= ? AND amount_awarded < ?', start_amount, end_amount).count
      end

      data << hash
    end

    data
  end

  def group_grants_by(funder, calculation, funding_stream, years_ago = 1, metric = :amount_awarded)
    years_ago_result = Date.today.year - years_ago

    unless funding_stream.nil?
      funder.grants
        .where("extract(year FROM approved_on) >= ? AND extract(year FROM approved_on) <= ?", years_ago_result, Date.today.year)
        .where("funding_stream = ?", funding_stream)
        .group("DATE_TRUNC('month', approved_on)").calculate(calculation, metric)
    else
      funder.grants
        .where("extract(year FROM approved_on) >= ? AND extract(year FROM approved_on) <= ?", years_ago_result, Date.today.year)
        .group("DATE_TRUNC('month', approved_on)").calculate(calculation, metric)
    end
  end

  def grant_size_data(funder, funding_stream, years_ago)
    average = group_grants_by(funder, :average, funding_stream, years_ago)
    minimum = group_grants_by(funder, :minimum, funding_stream, years_ago)
    maximum = group_grants_by(funder, :maximum, funding_stream, years_ago)
    count = group_grants_by(funder, :count, funding_stream, years_ago)

    merge = [average, minimum, maximum, count].flat_map(&:keys).uniq
    merge = merge.map { |v| {
      approved_on: v.strftime("%Y-%m"),
      average: average[v].to_i,
      minimum: minimum[v],
      maximum: maximum[v],
      count: count[v]
    } }

    merge.map { |v| Hash[
      :approved_on, v[:approved_on],
      :average, v[:average],
      :minimum, v[:minimum],
      :maximum, v[:maximum],
      :count, v[:count]
    ] }
  end

  def grant_duration_data(funder, funding_stream, years_ago)
    average = group_grants_by(funder, :average, funding_stream, years_ago, :days_from_start_to_end )
    minimum = group_grants_by(funder, :minimum, funding_stream, years_ago, :days_from_start_to_end)
    maximum = group_grants_by(funder, :maximum, funding_stream, years_ago, :days_from_start_to_end)

    merge = [average].flat_map(&:keys).uniq
    merge = merge.map { |v| {
      approved_on: v.strftime("%Y-%m"),
      average: (average[v].to_i / 30.4368).to_i,
      minimum: (minimum[v] / 30.4368).to_i,
      maximum: (maximum[v] / 30.4368).to_i
    } }

    merge.map { |v| Hash[
      :approved_on, v[:approved_on],
      :average, v[:average],
      :minimum, v[:minimum],
      :maximum, v[:maximum]
    ] }
  end

  def funding_frequency(funder, years_ago, funding_stream)
    years_ago_result = Date.today.year - years_ago

    unless funding_stream.nil?
      funding_frequency = funder.grants
        .where("extract(year FROM approved_on) = ?", years_ago_result)
        .where("funding_stream = ?", funding_stream)
        .group("DATE_TRUNC('month', approved_on)")
        .count
    else
      funding_frequency = funder.grants
        .where("extract(year FROM approved_on) = ?", years_ago_result)
        .group("DATE_TRUNC('month', approved_on)")
        .count
    end

    funding_frequency = funding_frequency.count
  end

  def grants_location(funder, funding_stream)
    years_ago_result = Date.today.year - @years_ago

    if funding_stream.nil?
      funder.grants
        .where("extract(year FROM approved_on) >= ? AND extract(year from approved_on) <= ?", years_ago_result, Date.today.year)
        .group(:country).count
    else
      funder.grants
        .where("extract(year FROM approved_on) >= ? AND extract(year from approved_on) <= ?", years_ago_result, Date.today.year)
        .where("funding_stream = ?", funding_stream)
        .group(:country).count
    end
  end

  def static_recipient_age_data(years_ago)
    years_ago_result = Date.today.year - years_ago
    data = []
    data << { approved_on: '2013-06', max: 47.1, avg: 11.7, min: 3} if years_ago_result == 2013
    data << { approved_on: '2013-12', max: 8.4, avg: 3.8, min: 1.4 } if years_ago_result == 2013
    data << { approved_on: '2014-07', max: 4.5 , avg: 2.7, min: 1 } if years_ago_result == 2013 || 2014
    data << { approved_on: '2014-11', max: 2.1 , avg: 1.6, min: 1.1 } if years_ago_result == 2013 || 2014
    data
  end

  def static_recipient_income_data(years_ago)
    years_ago_result = Date.today.year - years_ago
    data = []
    data << { approved_on: '2013-06', max: 1130797, avg: 403504.40, min: 53561 } if years_ago_result == 2013
    data << { approved_on: '2013-12', max: 249527, avg: 90074.25, min: 0  } if years_ago_result == 2013
    data << { approved_on: '2014-07', max: 120000, avg: 63738.72, min: 40900 } if years_ago_result == 2013 || 2014
    data << { approved_on: '2014-11', max: 34434.97, avg: 22322.72, min: 10210.46 } if years_ago_result == 2013 || 2014
    data
  end

  def static_beneficiary_target_data
    data = []
    data << { 'target' => 'People in education', '2014' => 100 }
    data << { 'target' => 'People who face income poverty', '2014' => 83 }
    data << { 'target' => 'Unemployed people', '2014' => 67 }
    data << { 'target' => 'People with disabilities', '2014' => 50 }
    data << { 'target' => 'Other Organisations', '2014' => 50 }
    data << { 'target' => 'People with physical diseases or disorders', '2014' => 33 }
    data << { 'target' => 'People with family or relationship challenges', '2014' => 33 }
    data << { 'target' => 'People with mental diseases or disorders', '2014' => 17 }
    data << { 'target' => 'People from a particular ethnic background', '2014' => 17 }
    data << { 'target' => 'People affected by or involved with criminal activities', '2014' => 17 }
    data << { 'target' => 'People with housing/shelter challenges', '2014' => 17 }
    data << { 'target' => 'Animals/Wildlife', '2014' => 0 }
    data << { 'target' => 'Other', '2014' => 0 }
    data << { 'target' => 'People affected by disasters', '2014' => 0 }
    data << { 'target' => 'People with specific religious or spiritual beliefs', '2014' => 0 }
    data << { 'target' => 'People with water/sanitation access challenges', '2014' => 0 }
    data << { 'target' => 'The environment', '2014' => 0 }
    data
  end

  def static_beneficiary_age_data(years_ago)
    years_ago_result = Date.today.year - years_ago
    data = []
    data << { 'target' => 'Disability', '2014' => 50, '2013' => 15 }
    data << { 'target' => 'Physical Health', '2014' => 33, '2013' => 23 }
    data << { 'target' => 'Mental Health', '2014' => 17, '2013' => 31 }
    data << { 'target' => 'Education', '2014' => 100, '2013' => 54 }
    data << { 'target' => 'Unemployment', '2014' => 67, '2013' => 92 }
    data << { 'target' => 'Income Poverty', '2014' => 83, '2013' => 92 }
    data << { 'target' => 'Ethnic Groups', '2014' => 17, '2013' => 23 }
    data << { 'target' => 'Criminal Activities', '2014' => 17, '2013' => 31 }
    data << { 'target' => 'Housing Issues', '2014' => 17, '2013' => 46 }
    data << { 'target' => 'Family Issues', '2014' => 33, '2013' => 62 }
    data << { 'target' => 'Other Organisations', '2014' => 50, '2013' => 54 }
    data
  end

  def compare_funder(funder, funder2, years_ago)
    funder1 = group_grants_by(funder, :count, years_ago)
    funder2 = group_grants_by(funder2, :count, years_ago)

    merge = [funder1, funder2].flat_map(&:keys).uniq
    merge = merge.map { |v| {
      approved_on: v.strftime("%Y-%m"),
      funder1: funder1[v] || 0,
      funder2: funder2[v] || 0
    } }

    merge.map { |v| Hash[
      :approved_on, v[:approved_on],
      :funder1, v[:funder1],
      :funder2, v[:funder2]
    ] }
  end

  def funding_period
    "#{(Date.today.year - @years_ago)}" +
    " to " +
    "#{@funder.grants.order("approved_on").pluck(:approved_on).last.year}"
  end

  def funding_stream_label
    unless @funding_stream.nil?
      @funding_stream
    else
      'All funding'
    end
  end

  def data_not_available(request)
    if @recipient.can_request_funder?(@funder, "#{request}")
      content_tag(:div, class: 'uk-alert uk-alert-warning uk-margin-bottom-remove') do
        content_tag(:span, "Oh snap!", :class => 'uk-text-bold') +
        content_tag(:br, "We don't have this information from " + @funder.name + ". To help us demonstrate the demand for this information, why not hit request...") +
        content_tag(:p, link_to('Request', vote_recipient_path("#{request}" => true, funder_id: @funder.id, recipient_id: @recipient.id), method: 'post', class: 'uk-button uk-width-1-1 shadow', data: {disable_with: "<i class='uk-icon uk-icon-circle-o-notch uk-icon-spin'></i> Requesting..."}))
      end
    else
      content_tag(:div, class: 'uk-alert uk-alert') do
        content_tag(:span, "Thanks for requesting this", :class => 'uk-text-bold') +
        content_tag(:br, "Your interest helps us decide what to focus on - watch this space....") +
        content_tag(:p) do
          content_tag(:button, class: 'uk-button uk-width-1-1', disabled: "") do
            content_tag(:i, " Requested", class: 'uk-icon-check')
          end
        end
      end
    end
  end

  def simple_data_not_available(request)
    if @recipient.can_request_funder?(@funder, "#{request}")
      content_tag(:a, link_to('Request', vote_recipient_path("#{request}" => true, funder_id: @funder.id, recipient_id: @recipient.id), method: 'post', class: 'uk-button uk-width-1-1 shadow', data: {disable_with: "<i class='uk-icon uk-icon-circle-o-notch uk-icon-spin'></i> Requesting..."}))
    else
      content_tag(:button, class: 'uk-button uk-width-1-1', disabled: "") do
        content_tag(:i, " Requested", class: 'uk-icon-check')
      end
    end
  end

  def has_profile_for_year?
    @recipient.profiles.pluck(:year).include?(Date.today.year - @years_ago)
  end

  def profile_missing
    content_tag(:span, "Hey! You don't have a profile for " + "#{(Date.today.year - @years_ago)}" + ". Why not complete one ") +
    content_tag(:b, link_to('here', new_recipient_profile_path(@recipient)))
  end

  def data_progress(funder)
    # years_ago_result = Date.today.year - @years_ago
    # array = []
    #
    # grants = Grant.where('funder_id = ?', funder.id)
    #   .where("extract(year FROM approved_on) = ?", years_ago_result)
    #
    # grants.each do |grant|
    #   array << grant.recipient.profiles.any?
    # end
    #
    # grant_total = grants.uniq.pluck(:recipient_id).count
    # profile_count = array.count(true)
    #
    # if grant_total == 0
    #   percentage = 0
    # else
    #   percentage = ((profile_count.to_f / grant_total.to_f) * 100).round(0)
    # end
    #
    # content_tag(:div, class: 'uk-alert uk-alert-warning') do
    #   content_tag(:span, "Whoa! This information seems to be missing", :class => 'uk-text-bold') +
    #   content_tag(:br, "We're working hard to collect the 'fingerprints' of these previously funded organistions, and you can see our progress below:") +
    #   content_tag(:div, class: 'uk-progress uk-progress-warning') do
    #     content_tag(:span, "#{percentage}%", class: 'uk-progress-bar', style: "width: #{percentage}%;")
    #   end
    # end

    content_tag(:div, class: 'uk-alert uk-alert-warning') do
      content_tag(:span, "Whoa! This information seems to be missing", :class => 'uk-text-bold') +
      content_tag(:br, "We're working hard to collect the 'fingerprints' of these previously funded organistions so you see how you compare.")
    end
  end

  def application_process
    if @funder.grants.where('open_call = ?', false).count > @funder.grants.where('open_call = ?', true).count
      content_tag(:div, 'Invite only', class: 'uk-button uk-button-primary uk-button-mini')
    else
      content_tag(:div, 'Open application', class: 'uk-button uk-button-primary uk-button-mini')
    end
  end

end
