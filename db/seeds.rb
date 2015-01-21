# Clear seeds
# Funder.destroy_all
Grant.destroy_all

# Create seeds
# funder = Funder.create!(
#   name: 'Forward Foundation',
#   contact_number: '1',
#   website: '1',
#   street_address: '1',
#   city: '1',
#   region: '1',
#   postal_code: '1',
#   country: 'United Kingdom',
#   charity_number: '01',
#   founded_on: '2015-01-01'
# )
# p "Created #{Funder.count} funders."

grant1 = Grant.create!(
  # funder_id: 1,
  approved_on: "2015-01-19",
  amount_awarded: "10000"
)
# grant2 = Grant.create!(
# approved_on: "2015-01-18",
# amount_awarded: "15000"
# )
# grant3 = Grant.create!(
# approved_on: "2015-01-17",
# amount_awarded: "11000"
# )
# grant4 = Grant.create!(
# approved_on: "2015-01-16",
# amount_awarded: "25000"
# )
# grant5 = Grant.create!(
# approved_on: "2015-01-15",
# amount_awarded: "18000"
# )
p "Created #{Grant.count} grants."
