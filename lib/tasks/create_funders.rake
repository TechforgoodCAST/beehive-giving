namespace :db do
  desc "Create Funders"
  task :create_funders => :environment do
    Funder.create(
      name: 'Forward Foundation',
      mission: 'We harness the innovation and talent of the tech sector to transform young lives.',
      contact_number: '+44 (0)20 3021 0630',
      website: 'www.forwardfoundation.org.uk/',
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
  end
end
