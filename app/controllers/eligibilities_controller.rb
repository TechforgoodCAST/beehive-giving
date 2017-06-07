class EligibilitiesController < ApplicationController
  before_action :ensure_logged_in
  before_action :load_fund, # TODO: refactor
                :load_restrictions, :load_eligibilities

  def new # TODO: refactor
    return redirect_to account_upgrade_path(@recipient) unless
      @proposal.checked_fund?(@fund) || @proposal.show_fund?(@fund)

    @org_criteria = find_or_initialize_eligibilities(@recipient, 'Organisation')
    @proposal_criteria = find_or_initialize_eligibilities(@proposal, 'Proposal')

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
      @recipient.increment!(:funds_checked) unless
        @proposal.checked_fund?(@fund)
      EligibilityCheck.new(Fund.active, @proposal).check!(@proposal.eligibility)
    end
    render :new
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

    def select_by_category(array, category_type, key = 'category_type')
      array.select { |i| i[key] == category_type }
    end

    def find_or_initialize_eligibilities(category, category_type)
      eligibilities = select_by_category(@eligibilities, category_type)
      restrictions = select_by_category(@restrictions,
                                        category_type, 'category')

      (restrictions.pluck(:id) - eligibilities.pluck(:restriction_id))
        .each do |restriction_id|
        eligibilities << Eligibility.new(
          category_id: category.id, restriction_id: restriction_id
        )
      end
      eligibilities.sort_by { |i| i[:restriction_id] }
    end

    def eligibility_params(parent)
      params.require(:check).require(parent)
            .permit(eligibilities_attributes:
                      [:id, :eligible, :restriction_id, :category_id])
    end

    def migrate_legacy_eligibilities
      eligbilities = Eligibility.where(
        category_id: @recipient.id, category_type: 'Proposal'
      )
      eligbilities&.update_all(category_id: @proposal.id)
    end

    def update_eligibility_params
      migrate_legacy_eligibilities

      # TODO: refactor performance
      categories = @restrictions.pluck(:category).uniq
      check = [categories.include?('Organisation'),
               categories.include?('Proposal')]
      case check
      when [true, true]
        update_recipient = @recipient
                           .update_attributes(eligibility_params(:recipient))
        update_proposal = @proposal
                          .update_attributes(eligibility_params(:proposal))
        [update_recipient, update_proposal].include?(false) ? false : true
      when [true, false]
        @recipient.update_attributes(eligibility_params(:recipient))
      when [false, true]
        @proposal.update_attributes(eligibility_params(:proposal))
      end
    end
end
