namespace :db do
  desc "Create Funders"
  task :create_funders => :environment do
    require 'faker'

    Funder.create(
      name: 'Forward Foundation',
      mission: 'We harness the innovation and talent of the tech sector to transform young lives.',
      contact_number: '+4420 3021 0630',
      website: 'www.forwardfoundation.org.uk',
      street_address: 'Centro 3, 19 Mandela Street',
      city: 'London',
      region: 'London',
      postal_code: 'NW1 0DU',
      country: 'United Kingdom',
      status: 'Active - currently operational',
      registered: true,
      charity_number: '1144526',
      founded_on: '2011-11-03',
      registered_on: '2011-11-03'
    )
    user = User.create(
      first_name: 'Suraj',
      last_name: 'Vadgama',
      job_role: 'Head of Digital',
      user_email: "suraj@forwardfoundation.org.uk",
      password: '123123',
      role: 'Funder'
    )
    user.organisation = Funder.find(1)
    user.save

    10.times do |n|
      Recipient.create(
        name: Faker::Company.name,
        mission: Faker::Company.catch_phrase,
        contact_number: '01234567890',
        website: 'www.example.com',
        street_address: Faker::Address.street_address,
        city: Faker::Address.city,
        region: Faker::Address.street_name,
        postal_code: Faker::Address.postcode,
        country: Faker::Address.country,
        status: 'Active - currently operational',
        registered: true,
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
        password: '123123',
      )
      user.organisation = Recipient.find(n+1)
      user.save

      profile = Profile.create(
        gender: 'All genders',
        currency: 'GBP (£)',
        goods_services: 'Goods',
        who_pays: 'Goods',
        year: '2014',
        min_age: rand(0..25),
        max_age: rand(10..120),
        income: Faker::Number.number(5),
        expenditure: Faker::Number.number(5),
        volunteer_count: rand(0..100),
        staff_count: rand(0..50),
        job_role_count: rand(0..25),
        department_count: rand(0..25),
        goods_count: rand(0..25),
        units_count: rand(0..5000),
        services_count: rand(0..25),
      )
      profile.organisation = Recipient.find(n+1)
      profile.save
    end
  end
end
