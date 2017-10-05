class EligibilitiesController < ApplicationController
  before_action :ensure_logged_in
  before_action :load_fund, # TODO: refactor
                :load_questions, :load_answers

  def create
    if @recipient.incomplete_first_proposal?
      session[:return_to] = @fund.slug
      return redirect_to edit_signup_proposal_path(@proposal)
    elsif !can_check_eligibility?
      return redirect_to account_upgrade_path(@recipient)
    end

    if update_eligibility_params
      params[:mixpanel_eligibility_tracking] = true
      @recipient.update_funds_checked!(@proposal.eligibility)

      redirect_to proposal_fund_path(@proposal, @fund)
    end
  end

  private

    def load_fund # TODO: refactor to applicaiton controller?
      @fund = Fund.includes(:funder).find_by(slug: params[:id])
    end

    def load_questions
      @questions = @fund.questions&.map{|q| q.criterion}.compact
    end

    def load_answers
      @answers = Answer.where(
        criterion: @questions.pluck(:id),
        category_id: @recipient.id,
        category_type: 'Recipient'
      ).to_a + Answer.where(
        criterion: @questions.pluck(:id),
        category_id: @proposal.id,
        category_type: 'Proposal'
      ).to_a
    end

    def can_check_eligibility?
      return true if @recipient.subscribed?
      return (@recipient.funds_checked < 3 || @proposal.checked_fund?(@fund))
    end

    def get_question_param(r)
      p = params.dig(:check, r.form_input_id)
      return nil unless p
      if p == "true"
        return true
      elsif p == "false"
        return false
      end
    end

    def migrate_legacy_eligibilities
      eligbilities = Answer.where(
        category_id: @recipient.id, category_type: 'Proposal'
      )
      eligbilities&.update_all(category_id: @proposal.id)
    end

    def update_eligibility_params
      migrate_legacy_eligibilities

      @questions.each do |r|
        e = Answer.find_or_initialize_by(
          criterion_id: r.id,
          category_id: (@recipient.id if r.category=="Recipient") || @proposal.id,
          category_type: r.category
        )
        e.eligible = get_question_param(r)
        e.save
      end
      @proposal.save
    end
end
