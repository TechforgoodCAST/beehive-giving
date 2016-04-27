require 'test_helper'

class RecipientApproachFunderTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
    setup_funders(3, true)
  end

  test 'approach funder choice visible if eligible on comparison page' do
    @recipient.load_recommendation(@funders[0]).update_attribute(:eligibility, 'Eligible')

    visit funder_path(@funders[0])
    assert page.has_content?('Apply')
  end

  test 'approach funder choice invisible if ineligible on comparison page' do
    @recipient.load_recommendation(@funders[0]).update_attribute(:eligibility, 'Ineligible')

    visit funder_path(@funders[0])
    assert page.has_content?('Why ineligible?')
  end

  test 'funder card displayed with appropriate cta' do
    @recipient.load_recommendation(@funders[0]).update_attribute(:eligibility, 'Eligible')
    visit recipient_apply_path(@funders[0])
    assert_not page.has_css?('.card-cta')
  end

end
