require 'rails_helper'

describe Article do
  subject { build(:article) }

  it { is_expected.to be_valid }

  it 'requires title' do
    subject.title = ''
    expect(subject).not_to be_valid
  end

  it 'requires slug' do
    subject.slug = ''
    expect(subject).not_to be_valid
  end

  it 'slug is unique' do
    subject.save!
    duplicate = build(:article, slug: subject.slug)
    expect(duplicate).not_to be_valid
  end

  it 'requires body' do
    subject.body = ''
    expect(subject).not_to be_valid
  end

  it '#body_html returns html' do
    html = '<h2><strong><a href="http://www.beehivegiving.org" ' \
           "target=\"_blank\" rel=\"noopener\">www.beehivegiving.org</a>" \
           "</strong></h2>\n"
    expect(subject.body_html).to eq(html)
  end
end
