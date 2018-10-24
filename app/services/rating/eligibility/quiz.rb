module Rating
  module Eligibility
    class Quiz
      include Rating::Base

      def link
        # TODO: removed for v3 deplpy
        "<a href='##{@assessment_id}'>Answers</a>".html_safe
      end
    end
  end
end
