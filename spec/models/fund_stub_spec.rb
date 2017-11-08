describe FundStub do
  context 'single' do
    before(:each) do
      @app.seed_test_db
          .setup_funds(num: 3)
      @db = @app.instances
      #   @fund = @db[:funds].first
      @funder = @db[:funder]
    end

    # needs name

    # name should be name of the funder

    # requires a description

    # requires themes

    # geo_areas

    # permitted_costs is empty

    # other validations not needed


  end
end