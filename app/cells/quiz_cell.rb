class QuizCell < Cell::ViewModel
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include SimpleForm::ActionViewExtensions::FormHelper

  def show
    load_questions
    counts = question_count
    if counts[:questions] > 0
      render locals: { f: options[:f], counts: counts }
    else
      render :noquiz
    end
  end

  def show_public
    load_questions
    counts = question_count
    if counts[:questions] > 0
      render locals: { f: options[:f], counts: counts }
    else
      render :noquiz
    end
  end

  def questions_completed
    load_questions
    render locals: { counts: question_count }
  end

  private

    def load_questions
      @groups = options[:groups].present? ? options[:groups] : model.question_groups(options[:quiz_type]).collect{ |v| [v, v] }.to_h
      @questions = {}
      @groups.each do |g, _|
        if options[:quiz_type] == 'Restriction'
          @questions[g] = model.restrictions.where(category: g)
        else
          @questions[g] = model.questions.includes(:criterion).grouped(options[:quiz_type], g)&.map{|q| q.criterion}
        end
      end
      @proposal = options[:proposal]
    end

    def question_count
      {
        completed: @questions.map{|k, qs| qs.count{|q| q.answer(@proposal).present?}}.reduce(:+) || 0,
        questions: @questions.map{|k, qs| qs.size}.reduce(:+) || 0
      }
    end

end
