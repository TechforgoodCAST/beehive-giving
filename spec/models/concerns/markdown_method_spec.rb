require 'rails_helper'

describe MarkdownMethod do
  subject { Class.new.include(MarkdownMethod).new }

  it '#markdown' do
    expect(subject.markdown('**bold**')).to eq("<p><strong>bold</strong></p>\n")
  end
end
