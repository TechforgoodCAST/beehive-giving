class EligibilityCell < Cell::ViewModel
  include SimpleForm::ActionViewExtensions::FormHelper

  def quiz
    return unless options[:fund].restrictions.exists?
    render locals: { fund: options[:fund] }
  end

  private

    def protect_against_forgery?
      controller.send(:protect_against_forgery?)
    end
end
