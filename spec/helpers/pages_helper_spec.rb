require 'rails_helper'

describe PagesHelper do
  subject { Class.new.include(PagesHelper).new }

  it '#add_opportunity_form_url' do
    url = 'https://docs.google.com/forms/d/e/1FAIpQLSfJjDEaPTKpobLfaRVV1S6zQk' \
          'NcSPZY6_EdVwF6HlgUigO2qQ/viewform?usp=pp_url&entry.1976117714=value'
    expect(subject.add_opportunity_form_url('value')).to eq(url)
  end
end
