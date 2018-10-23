module Rating
  module Suitability
    class Quiz
      include Rating::Base

      def link
        "<a href='##{@assessment_id}'>Your answers</a>".html_safe
      end
    end
  end
end