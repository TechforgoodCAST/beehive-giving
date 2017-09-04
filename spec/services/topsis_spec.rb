require 'rails_helper'

describe Topsis do
  before(:all) do
    @suitability = {
      'fund1' => {
        'theme'    => { 'score' => 0.3450 },
        'location' => { 'score' => 1, 'reason' => 'anywhere' },
        'org_type' => { 'score' => 0.08333333333333333 },
        'amount'   => { 'score' => 0 },
        'duration' => { 'score' => 0.6582367211265331 },
        'total'    => 0
      },
      'fund2' => {
        'theme'    => { 'score' => 0 },
        'location' => { 'score' => 0, 'reason' => 'overlap' },
        'org_type' => { 'score' => 0 },
        'amount'   => { 'score' => 0 },
        'duration' => { 'score' => 0 },
        'total'    => 0
      },
      'fund3' => {
        'theme'    => { 'score' => 0 },
        'location' => { 'score' => 1, 'reason' => 'anywhere' },
        'org_type' => { 'score' => 0.08868501529051988 },
        'amount'   => { 'score' => 0 },
        'duration' => { 'score' => 0.22394868978432367 },
        'total'    => 0
      }
    }
  end

  subject { Topsis.new(@suitability) }

  it '#rank' do
    result = {
      'fund1' => 0.9826894106862426,
      'fund2' => 0.0,
      'fund3' => 0.4221238036666428
    }
    expect(subject.rank).to eq result
  end
end
