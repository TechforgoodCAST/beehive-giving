class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :users, :organisation_id
    add_index :recommendations, :funder_id
    add_index :recommendations, :recipient_id
    add_index :districts_grants, :district_id
    add_index :districts_grants, [:district_id, :grant_id]
    add_index :districts_grants, :grant_id
    add_index :funding_streams_restrictions, :restriction_id
    add_index :funding_streams_restrictions, :funding_stream_id
    add_index :funding_streams_restrictions, [:funding_stream_id, :restriction_id], :name => 'index_funding_streams_restrictions'
    add_index :districts_profiles, :district_id
    add_index :districts_profiles, [:district_id, :profile_id]
    add_index :districts_profiles, :profile_id
    add_index :implementors_profiles, :implementor_id
    add_index :implementors_profiles, [:implementor_id, :profile_id]
    add_index :implementors_profiles, :profile_id
    add_index :beneficiaries_profiles, :profile_id
    add_index :beneficiaries_profiles, [:beneficiary_id, :profile_id]
    add_index :beneficiaries_profiles, :beneficiary_id
    add_index :features, :funder_id
    add_index :features, :recipient_id
    add_index :countries_funder_attributes, :country_id
    add_index :countries_funder_attributes, [:country_id, :funder_attribute_id], :name => 'index_countries_funder_attributes'
    add_index :countries_funder_attributes, :funder_attribute_id
    add_index :organisations, [:id, :type]
    add_index :countries_grants, :country_id
    add_index :countries_grants, [:country_id, :grant_id]
    add_index :countries_grants, :grant_id
    add_index :grants, :funder_id
    add_index :grants, :recipient_id
    add_index :grants, [:funder_id, :recipient_id]
    add_index :countries_profiles, :country_id
    add_index :countries_profiles, [:country_id, :profile_id]
    add_index :countries_profiles, :profile_id
    add_index :districts_funder_attributes, :district_id
    add_index :districts_funder_attributes, [:district_id, :funder_attribute_id], :name => 'index_districts_funder_attributes'
    add_index :districts_funder_attributes, :funder_attribute_id
    add_index :funder_attributes, :funder_id
    add_index :funder_attributes_funding_types, [:funder_attribute_id, :funding_type_id], :name => 'index_funder_attributes_funding_types'
    add_index :funder_attributes_funding_types, :funder_attribute_id
    add_index :funder_attributes_funding_types, :funding_type_id
    add_index :approval_months_funder_attributes, [:approval_month_id, :funder_attribute_id], :name => 'index_approval_months_funder_attributes'
    add_index :approval_months_funder_attributes, :approval_month_id
    add_index :approval_months_funder_attributes, :funder_attribute_id
    add_index :beneficiaries_funder_attributes, [:beneficiary_id, :funder_attribute_id], :name => 'index_beneficiaries_funder_attributes'
    add_index :beneficiaries_funder_attributes, :beneficiary_id
    add_index :implementations_profiles, :implementation_id
    add_index :implementations_profiles, [:implementation_id, :profile_id], :name => 'index_implementations_profiles'
    add_index :implementations_profiles, :profile_id
    add_index :profiles, :organisation_id
    add_index :funding_streams_organisations, :funder_id
    add_index :funding_streams_organisations, [:funder_id, :funding_stream_id], :name => 'index_funding_streams_organisations'
    add_index :funding_streams_organisations, :funding_stream_id
    add_index :feedbacks, :user_id
    add_index :enquiries, :recipient_id
    add_index :enquiries, :funder_id
    add_index :eligibilities, :recipient_id
    add_index :eligibilities, :restriction_id
    add_index :countries_enquiries, [:country_id, :enquiry_id]
    add_index :countries_enquiries, :enquiry_id
    add_index :districts_enquiries, :enquiry_id
    add_index :districts_enquiries, [:district_id, :enquiry_id]
    add_index :districts, :country_id
    add_index :subscriptions, :organisation_id
    add_index :subscriptions, :plan_id
  end
end
