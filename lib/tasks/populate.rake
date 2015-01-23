namespace :db do
  desc "Erase and fill database"
  task :populate => :environment do
    require 'faker'

    Rake::Task['db:reset'].invoke

    count = 5
    start = count + 1

    count.times do |n|
      funder = Funder.create(
        name: Faker::Company.name,
        contact_number: Faker::PhoneNumber.phone_number,
        website: Faker::Internet.domain_name,
        street_address: Faker::Address.street_address,
        city: Faker::Address.city,
        region: Faker::Address.street_name,
        postal_code: Faker::Address.postcode,
        country: Faker::Address.country,
        charity_number: Faker::Number.number(8),
        company_number: Faker::Number.number(10),
        founded_on: Faker::Date.between(10.years.ago, 5.years.ago),
        registered_on: Faker::Date.between(5.years.ago, Time.now)
      )
      user = User.create(
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        job_role: Faker::Name.title,
        user_email: "funder#{n+1}@example.com",
        password: 'password',
        role: 'Funder'
      )
      user.organisation = Funder.find(n+1)
      user.save
    end

    25.times do |n|
      organisation = Recipient.create(
      name: Faker::Company.name,
      contact_number: Faker::PhoneNumber.phone_number,
      website: Faker::Internet.domain_name,
      street_address: Faker::Address.street_address,
      city: Faker::Address.city,
      region: Faker::Address.street_name,
      postal_code: Faker::Address.postcode,
      country: Faker::Address.country,
      charity_number: Faker::Number.number(8),
      company_number: Faker::Number.number(10),
      founded_on: Faker::Date.between(10.years.ago, 5.years.ago),
      registered_on: Faker::Date.between(5.years.ago, Time.now)
      )
      user = User.create(
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      job_role: Faker::Name.title,
      user_email: "org#{n+1}@example.com",
      password: 'password',
      )
      user.organisation = Recipient.find(n+1+count)
      user.save
    end

    10.times do |n|
      grant = Grant.create(
        funding_stream: 'Main',
        grant_type: 'Unrestricted',
        attention_how: 'Headhunting',
        amount_awarded: Faker::Number.number(5),
        amount_applied: Faker::Number.number(5),
        installments: Faker::Number.digit,
        approved_on: Faker::Date.between(10.years.ago, Time.now),
        start_on: Faker::Date.between(10.years.ago, Time.now),
        end_on: Faker::Date.between(10.years.ago, Time.now),
        attention_on: Faker::Date.between(10.years.ago, Time.now),
        applied_on: Faker::Date.between(10.years.ago, Time.now)
      )
      grant.funder = Funder.find(1)
      grant.recipient = Recipient.find(rand(start..25))
      grant.save
    end

    10.times do |n|
      grant = Grant.create(
      funding_stream: 'Main',
      grant_type: 'Unrestricted',
      attention_how: 'Headhunting',
      amount_awarded: Faker::Number.number(5),
      amount_applied: Faker::Number.number(5),
      installments: Faker::Number.digit,
      approved_on: Faker::Date.between(10.years.ago, Time.now),
      start_on: Faker::Date.between(10.years.ago, Time.now),
      end_on: Faker::Date.between(10.years.ago, Time.now),
      attention_on: Faker::Date.between(10.years.ago, Time.now),
      applied_on: Faker::Date.between(10.years.ago, Time.now)
      )
      grant.funder = Funder.find(2)
      grant.recipient = Recipient.find(rand(start..25))
      grant.save
    end

  end
end
