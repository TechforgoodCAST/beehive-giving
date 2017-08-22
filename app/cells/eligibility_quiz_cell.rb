class EligibilityQuizCell < Cell::ViewModel
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include SimpleForm::ActionViewExtensions::FormHelper

  def show
    load_restrictions
    render locals: { f: options[:f] }
  end

  private

    def load_restrictions
      @restrictions = model.restrictions.includes(:eligibilities).to_a.group_by { |r| r[:category].to_sym }
      @proposal = options[:proposal]
    end

end
