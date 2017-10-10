require 'rails_helper'

describe GeoArea do
  context 'single' do
    before(:each) do
      @app.seed_test_db
          .setup_funds(num: 3)
      @db = @app.instances
      @area = @db[:funds].first.geo_area
    end

    it 'countries required' do
      @area.update(countries: [])
      expect(@area).not_to be_valid
    end

    it 'name required' do
      @area.update(name: nil)
      expect(@area).not_to be_valid
    end
  end
end
