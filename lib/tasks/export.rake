namespace :export do

  # usage: be rake export:nonprofits DESTINATON=/path
  desc 'Export nonprofit data for analysis'
  task :nonprofits => :environment do
    require 'csv'
    @destination = ENV['DESTINATION']

    Recipient.joins(:profiles).each_with_index do |r, i|

      data = {
        organisation: r.name,
        founded_on: r.founded_on,
        registered_on: r.registered_on,
        country: r.country,
        charity_number: r.charity_number,
        company_number: r.company_number,

        beneficiaries: r.beneficiaries.pluck(:label),
        gender: r.profiles.first.gender,
        min_age: r.profiles.first.min_age,
        max_age: r.profiles.first.max_age,

        countries_impacted: r.countries.pluck(:alpha2),
        districts_impacted: r.districts.pluck(:label),

        employee_count: r.profiles.first.staff_count,
        volunteer_count: r.profiles.first.volunteer_count,
        trustee_count: r.profiles.first.trustee_count,
        work_implemented_by: r.implementors.pluck(:label),

        income: r.profiles.first.income,
        income_estimated: r.profiles.first.income_actual,
        expenditure: r.profiles.first.expenditure,
        expenditure_estimated: r.profiles.first.income_actual,

        work_delivered: r.implementations.pluck(:label),
        payment_for_work: r.profiles.first.does_sell,
        beneficiaries_count: r.profiles.first.beneficiaries_count,
        beneficiaries_count_estimated: r.profiles.first.beneficiaries_count_actual
      }

      CSV.open(@destination, 'w') { |csv| csv << data.keys } if i < 1

      CSV.open(@destination, 'a+') { |csv| csv << data.values }

    end
  end

  # usage: be rake export:grants DESTINATON=/path
  desc 'Export grants data for analysis'
  task :grants => :environment do
    require 'csv'
    @destination = ENV['DESTINATION']

    Grant.joins(:recipient).each_with_index do |g, i|

      data = {
        funder: Funder.find(g.funder_id).name,
        recipient: Recipient.find(g.recipient_id).name,
        funding_stream: g.funding_stream,
        amount_awarded: g.amount_awarded,
        approved_on: g.approved_on,
        start_on: g.start_on,
        end_on: g.end_on,

        grant_type: g.grant_type,
        open_call: g.open_call,
        attention_how: g.attention_how,
        attention_on: g.attention_on,
        applied_on: g.applied_on,
        amount_applied: g.amount_applied,
        installments: g.installments
      }

      CSV.open(@destination, 'w') { |csv| csv << data.keys } if i < 1

      CSV.open(@destination, 'a+') { |csv| csv << data.values }

    end
  end

  # usage: be rake export:enquiries DESTINATON=/path
  desc 'Export nonprofit data for analysis'
  task :enquiries => :environment do
    require 'csv'
    @destination = ENV['DESTINATION']

    Enquiry.all.each_with_index do |e, i|
      data = {
        organisation: Recipient.find(e.recipient_id).name,
        funder: Funder.find(e.funder_id).name,
        approach_funder_count: e.approach_funder_count,
        funding_stream: e.funding_stream,
        created_at: e.created_at,
        updated_at: e.updated_at
      }
      CSV.open(@destination, 'w') { |csv| csv << data.keys } if i < 1
      CSV.open(@destination, 'a+') { |csv| csv << data.values }
    end
  end

end
