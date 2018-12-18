require 'rails_helper'

describe OpportunitiesHelper do
  class Subject
    include ActionView::Helpers::NumberHelper
    include OpportunitiesHelper
  end

  subject { Subject.new }

  let(:data) { { 'approach' => 4, 'avoid' => 6 } }
  let(:result) do
    { 'Can apply' => '40%', 'Unclear' => '0%', "Shouldn't apply" => '60%' }
  end

  it('#breakdown') { expect(subject.breakdown(data)).to eq(result) }
end
