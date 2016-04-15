require 'test_helper'

class RecipientFundingThemesTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
    @initial_proposal = create(:initial_proposal, recipient: @recipient)
    setup_funders(3)
    {
      'acme-2': 'tag1; tag2',
      'acme-3': 'tag1; tag2',
      'acme-4': 'tag1'
    }.each { |k, v| Funder.find_by_slug(k).update_attribute(:tag_list, v) }
  end

  test 'only recommended funders show funding themes' do
    skip
    @recipient.load_recommendation(Funder.last).update_attribute(:score, 0)
    visit all_funders_path
    assert page.has_css?('.redacted', count: 1)
  end

  test 'clicking funding theme shows related funders' do
    skip
    visit recommended_funders_path
    Capybara.match = :first
    click_link('tag1')
    assert_equal tag_path('tag1'), current_path
    assert page.has_css?('.funder', count: 3)

    visit tag_path('tag2')
    assert page.has_css?('.funder', count: 2)
  end

  test 'only one funder is not redacted when viewing a tag' do
    skip
    visit tag_path('tag1')
    assert page.has_css?('.locked-funder', count: 2)
  end

end
