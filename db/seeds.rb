# Clear seeds
# User.destroy_all
#
# Funder.destroy_all
# FundingStream.destroy_all

Organisation.destroy_all
Profile.destroy_all

# Grant.destroy_all
# GrantDetails.destroy_all
#
# Enquiries.destroy_all

# Create seeds
# suraj = User.create!(
# name: "Forename Surname",
# role: "Role",
# email: "suraj@forwardfoundation.org.uk",
# type: "Funder",
# encrypted_password: ""
# )
# john = User.create!(
# name: "John Doe",
# role: "CEO",
# email: "ceo@acmeinc.org",
# type: "Organisation",
# encrypted_password: ""
# )
# jane = User.create!(
# name: "Jane Doe",
# role: "Founder",
# email: "founder@notprofit.co.uk",
# type: "Organisation",
# encrypted_password: ""
# )
# p "Created #{User.count} users."

# main = FundingStream.create!(stream: "Main")
# youth = FundingStream.create!(stream: "Youth")
# p "Created #{FundingStream.count} funding streams."
#
# funder = Funder.create!(
# user: suraj,
# funder: "Forward Foundation",
# funding_streams: [main]
# )
# p "Created #{Funder.count} funder."

charity = Organisation.create!(
user: john,
organisation: "Charity",
registration_status: ["Registered Charity/Nonprofit"],
mission: "Mission 1",
date_founded: "01/01/13",
date_registered: "05/01/13",
nonprofit_no: "0123456",
company_no: "",
website: "www.charity.org",
contact_number: "012345567890",
address_street: "123 street",
address_city: "City 1",
address_postal_code: "Postal Code 1",
address_country: "GB",
franchise: FALSE
)
nonprofit = Organisation.create(
user: jane,
organisation: "Notprofit Co",
registration_status: ["School", "Community Interest Company"],
mission: "Mission 2",
date_founded: "01/01/14",
date_registered: "05/01/14",
nonprofit_no: "1234567",
company_no: "1234567",
website: "www.nonprofit.org",
contact_number: "12345678901",
address_street: "456 street",
address_city: "City 2",
address_postal_code: "Postal Code 2",
address_country: "KE",
franchise: TRUE
)
p "Created #{Organisation.count} organisations."

charity_profile = Profile.create!(
organisation: charity,
year: "2013",
where: ["Hackney", "Camden"],
who: ["People in education", "People who face income poverty"],
min_age: 13,
max_age: 19,
gender: "All genders",
currency: "GBP",
income: 150000,
spending: 136789,
voluntary_staff: 16,
paid_staff: 4,
job_roles: 3,
departments: 2,
goods_services: "Services",
pay: "No",
funds: ["Trusts and Foundations", "Public sector"],
social_mission: ["Staff", "Volunteer", "Beneficiary"]
num_services: 3,
services_benefited: 256,
num_goods: 0,
goods_units: 0
)
nonprofit_profile = Profile.create!(
organisation: nonprofit,
year: "2014",
where: ["Nairobi"],
who: ["Unemployed people"],
min_age: 18,
max_age: 35,
gender: "Only female",
currency: "KES",
income: 1421057,
spending: 994740,
voluntary_staff: 10,
paid_staff: 0,
job_roles: 3,
departments: 2,
goods_services: "Services",
pay: "Services",
funds: ["Trusts and Foundations", "Other organisations"],
social_mission: ["Volunteer", "Third-party"]
num_services: 2,
services_benefited: 378,
num_goods: 0,
goods_units: 0
)
p "Created #{Profile.count} organisation profiles."

grant1 = Grant.create!(
funders: [funder],
organisations: [charity],
stream: youth,
details: [grantDetails1],
currency: "GBP",
amount_awarded: "25000",
installments: 1,
type: "Unrestricted",
focus: "Youth",
location: ["Hackney", "Camden"]
)
grantDetails1 = GrantDetails.create!(
grant: grant1,
organisation: charity,
attention_when: "01/06/2013",
# attention_how: "",
application_date: "01/08/2013",
approval_date: "01/10/2013",
start_date: "01/11/2013",
end_date: "01/11/2014"
)
grant2 = Grant.create!(
funders: [funder],
organisations: [nonprofit],
stream: main,
details: [grantDetails2],
currency: "GBP",
amount_awarded: "10000",
installments: 1,
type: "Project costs",
focus: "Gender",
location: ["Nairobi"]
)
grantDetails2 = GrantDetails.create!(
grant: grant2,
organisation: nonprofit,
attention_when: "01/06/2014",
# attention_how: "",
application_date: "01/08/2014",
approval_date: "01/10/2014",
start_date: "01/11/2014",
end_date: "01/11/2015"
)
p "Created #{Grant.count} grants."
