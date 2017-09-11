class EligibilityQuizCell < Cell::ViewModel
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include SimpleForm::ActionViewExtensions::FormHelper

  def show
    load_restrictions
    counts = restrictions_count
    if counts[:restrictions] > 0
      render locals: { f: options[:f], counts: counts }
    else
      render :noquiz
    end
  end

  private

    def load_restrictions
      @restrictions = model.restrictions.includes(:answers).to_a.group_by { |r| r[:category].to_sym }
      @proposal = options[:proposal]
    end

    def restrictions_count
      {
        completed: @restrictions.map{|k, rs| rs.count{|r| r.eligibility(@proposal).present?}}.reduce(:+) || 0,
        restrictions: @restrictions.map{|k, rs| rs.size}.reduce(:+) || 0
      }
    end

end
