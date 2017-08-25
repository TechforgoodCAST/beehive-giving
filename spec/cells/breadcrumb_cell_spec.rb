require 'rails_helper'

describe BreadcrumbCell do
  controller ApplicationController

  it 'missing path option' do
    breadcrumb = cell(:breadcrumb).call(:show)
    expect(breadcrumb).not_to have_css '.bread'
  end

  it 'path option empty' do
    breadcrumb = cell(:breadcrumb, {}).call(:show)
    expect(breadcrumb).not_to have_css '.bread'
  end

  it '#bold' do
    breadcrumb = cell(:breadcrumb, 'a' => 'b').call(:show)
    expect(breadcrumb).to have_css '.bold', count: 1
  end

  it '#disabled' do
    breadcrumb = cell(:breadcrumb, 'a' => nil).call(:show)
    expect(breadcrumb).to have_css '.disabled', count: 1
  end
end
