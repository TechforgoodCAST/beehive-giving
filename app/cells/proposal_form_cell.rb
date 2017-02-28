class ProposalFormCell < Cell::ViewModel
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include SimpleForm::ActionViewExtensions::FormHelper

  property :recipient
  property :affect_people
  property :affect_other
  property :affect_geo

  def show
    load_beneficiaries
    load_districts
    render
  end

  private

    def load_beneficiaries
      @beneficiaries ||= Beneficiary.all
    end

    def filter_beneficiaries(category)
      @beneficiaries.select { |b| b[:category] == category }
    end

    def hidden(property)
      'uk-hidden' unless property
    end

    def within_country
      affect_geo == 0 || affect_geo == 1
    end

    def entire_country
      affect_geo == 2
    end

    def multiple_countries
      affect_geo == 3
    end

    def load_districts # TODO: refactor
      @recipient_country = Country.find_by(alpha2: recipient.country) ||
                           recipient.profiles.first.countries.first
      @district_ids = @recipient_country
                      .districts.order(:region, :name).map do |d|
                        [
                          d.name,
                          d.id,
                          { "data-section": district_section(d) }
                        ]
                      end
    end

    def district_section(district) # TODO: refactor
      if district.region.nil?
        district.sub_country.nil? ? 'All regions' : district.sub_country
      else
        "#{district.sub_country}/#{district.region}"
      end
    end
end
