class EligibilityCell < Cell::ViewModel
  include SimpleForm::ActionViewExtensions::FormHelper

  def quiz
    @fund = options[:fund]
    render if @fund.restrictions.exists?
  end

  private

    def protect_against_forgery?
      controller.send(:protect_against_forgery?)
    end

    def cell_opts(form)
      {
        quiz_type: 'Restriction',
        proposal: model,
        f: form,
        groups: {
          'Recipient' => 'Is your organisation?',
          'Proposal'  => 'Is your funding proposal for?'
        }
      }
    end

    def form_opts
      if model.present?
        { url: eligibility_path(@fund, model), method: :patch }
      else
        { html: { class: 'muted' } }
      end
    end

    def version
      model ? :show : :show_public
    end
end
