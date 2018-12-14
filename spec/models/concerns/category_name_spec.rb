require 'rails_helper'

describe CategoryName do
  subject do
    class Subject
      include CategoryName
      CATEGORIES = { 'Group' => { category_code: 'Name' } }
      attr_accessor :category_code
    end
    Subject.new
  end

  it '#category_name' do
    subject.category_code = :category_code
    expect(subject.category_name).to eq('Name')
  end
end
