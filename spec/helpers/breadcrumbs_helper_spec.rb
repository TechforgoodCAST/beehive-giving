require 'rails_helper'

describe BreadcrumbsHelper do
  class BreadcrumbsHelperClass
    include ActionView::Helpers
    include Rails.application.routes.url_helpers
    include BreadcrumbsHelper
  end

  subject { BreadcrumbsHelperClass.new }

  it 'hash option missing' do
    expect(subject.breadcrumbs).to be_nil
  end

  it 'hash option empty' do
    expect(subject.breadcrumbs({})).to be_nil
  end

  it 'bold' do
    opts = { 'a' => 'b' }
    expect(subject.breadcrumbs(opts)).to have_css('.bold', count: 1)
  end

  it 'disabled' do
    opts = { 'a' => nil }
    expect(subject.breadcrumbs(opts)).to have_css('.disabled', count: 1)
  end

  it 'custom color' do
    opts = { 'a' => nil }
    expect(subject.breadcrumbs(opts, color: 'blue'))
      .to have_css('.blue', count: 3)
  end
end
