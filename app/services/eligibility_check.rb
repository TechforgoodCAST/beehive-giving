class EligibilityCheck < Recommender
  def check(eligibility = {})
    updates = eligibility.clone
    updates.except_nested_key('quiz')
           .delete_if { |_, v| v.empty? }
           .deep_merge(check_restrictions)
  end

  def check!(eligibility = {})
    @proposal.update_column :eligibility, check(eligibility)
  end

  private

    def lookup_answers
      Eligibility.where(category_id: [@proposal.id, @proposal.recipient.id])
                 .pluck(:restriction_id, :eligible).to_h
    end

    def check_restrictions
      result = {}
      answers = lookup_answers
      @funds.pluck(:slug, :restriction_ids).to_h.each do |slug, restrictions|
        comparison = (answers.keys & restrictions)
        next unless comparison.count == restrictions.count
        result[slug] = {
          'quiz' => !answers.slice(*comparison).values.include?(false),
          'count_failing' => answers.slice(*comparison).values
                                    .select { |i| i == false }.count
        }
      end
      result
    end
end
