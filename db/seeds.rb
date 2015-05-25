# # Create implementors
# Implementor.destroy_all
# [
#   "Paid staff",
#   "Volunteers",
#   "Beneficiaries",
#   "Third parties",
#   "Other"
# ].each do |state|
#   Implementor.create(label:state)
# end
#
# # Create beneficiaries
# Beneficiary.destroy_all
# [
#   "People with disabilities",
#   "People with physical diseases or disorders",
#   "People with mental diseases or disorders",
#   "People in education",
#   "Unemployed people",
#   "People with income poverty",
#   "People from a particular ethnic background",
#   "People affected by or involved with criminal activities",
#   "People with housing/shelter challenges",
#   "People with family or relationship challenges",
#   "Organisations",
#   "Other",
#   "People with a specific sexual orientation",
#   "People with specific religious or spiritual beliefs",
#   "People affected by disasters",
#   "People with water/sanitation access challenges",
#   "People with food access challenges",
#   "Animals/Wildlife",
#   "The environment"
# ].each do |state|
#   Beneficiary.create(label:state)
# end
#
# # Create implementations
# Implementation.destroy_all
# [
#   "Buildings/Facilities to Beneficiary",
#   "Campaign to Beneficiary",
#   "Finance to Beneficiary",
#   "Membership to Beneficiary",
#   "Product to Beneficiary",
#   "Research to Beneficiary",
#   "Service to Beneficiary",
#   "Software to Beneficiary",
#   "Other"
# ].each do |state|
#   Implementation.create(label:state)
# end
