# Clear seeds
Grant.destroy_all

# Create seeds
grant1 = Grant.create!(
  approved_on: "2015-01-19",
  amount_awarded: "10000"
)
grant2 = Grant.create!(
approved_on: "2015-01-18",
amount_awarded: "15000"
)
grant3 = Grant.create!(
approved_on: "2015-01-17",
amount_awarded: "11000"
)
grant4 = Grant.create!(
approved_on: "2015-01-16",
amount_awarded: "25000"
)
grant5 = Grant.create!(
approved_on: "2015-01-15",
amount_awarded: "18000"
)
p "Created #{Grant.count} grants."
