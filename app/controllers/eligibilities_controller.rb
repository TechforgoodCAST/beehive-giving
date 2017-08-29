class EligibilitiesController < ApplicationController
  before_action :ensure_logged_in
  before_action :load_fund, # TODO: refactor
                :load_restrictions, :load_eligibilities

  def new # TODO: refactor
    return redirect_to account_upgrade_path(@recipient) unless
      @proposal.checked_fund?(@fund) || @proposal.show_fund?(@fund)

    return if @recipient.subscribed?

    if @recipient.incomplete_first_proposal?
      session[:return_to] = @fund.slug
      redirect_to edit_signup_proposal_path(@proposal)
    elsif current_user.feedbacks.count < 1 &&
          (!@proposal.checked_fund?(@fund) && @recipient.funds_checked == 2)
      session[:redirect_to_funder] = @fund.slug
      redirect_to new_feedback_path
    elsif @recipient.funds_checked < 3 || @proposal.checked_fund?(@fund)
      render :new
    else
      redirect_to account_upgrade_path(@recipient)
    end
  end

  def create
    if update_eligibility_params
      params[:mixpanel_eligibility_tracking] = true
      @recipient.update_funds_checked!(@proposal.eligibility)
    end
    case params.dig(:check, :return_to)
    when "eligibility"
      redirect_to eligibility_proposal_fund_path(@proposal, @fund)
    else
      redirect_to proposal_fund_path(@proposal, @fund)
    end
  end

  private

    def load_fund # TODO: refactor to applicaiton controller?
      @fund = Fund.includes(:funder).find_by(slug: params[:id])
    end

    def load_restrictions
      @restrictions = @fund.restrictions.to_a
    end

    def load_eligibilities
      @eligibilities = Eligibility.where(
        restriction: @restrictions.pluck(:id),
        category: [@recipient.id, @proposal.id]
      ).to_a
    end

    def get_restriction_param(r_id)
      p = params.dig(:check, "restriction_#{r_id}_eligible")
      return nil unless p
      if p == "true"
        return true
      elsif p == "false"
        return false
      end
    end

    def migrate_legacy_eligibilities
      eligbilities = Eligibility.where(
        category_id: @recipient.id, category_type: 'Proposal'
      )
      eligbilities&.update_all(category_id: @proposal.id)
    end

    def update_eligibility_params
      migrate_legacy_eligibilities

      @restrictions.each do |r|
        e = Eligibility.find_or_initialize_by(
          restriction_id: r.id,
          category_id: (@recipient.id if r.category=="Organisation") || @proposal.id,
          category_type: r.category
        )
        e.eligible = get_restriction_param(r.id)
        e.save
      end
      @proposal.save
    end
end
