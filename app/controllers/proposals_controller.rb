class ProposalsController < ApplicationController
  layout 'fullscreen'

  before_action :load_collection, :load_recipient, :authenticate

  def new
    @proposal = @recipient.build_proposal
    @proposal.user = current_user || User.new

    @proposal.answers = criteria.map do |c|
      Answer.new(category: @proposal, criterion: c)
    end
  end

  def create
    @proposal = @recipient.build_proposal(form_params)
    @proposal.collection = @collection

    if @proposal.save
      ReportMailer.notify(@proposal).deliver_now
      redirect_to new_charge_path(@proposal)
    else
      @districts = District.where(country_id: form_params[:country])
      render :new
    end
  end

  private

    def authenticate
      authorize @recipient, policy_class: ProposalPolicy
    end

    def criteria
      @collection.criteria.where(category: 'Proposal')
                 .where('type = ? OR type = ?', 'Restriction', 'Priority')
    end

    def form_params
      params.require(:proposal).permit(
        :category_code, :country_id, :description, :geographic_scale,
        :max_amount, :max_duration, :min_amount, :min_duration, :public_consent,
        :support_details, :title, nested_attributes,
        country_ids: [], district_ids: [], theme_ids: []
      )
    end

    def nested_attributes
      {
        answers_attributes: %i[eligible criterion_id],
        user_attributes: %i[
          email email_confirmation first_name last_name marketing_consent
          terms_agreed
        ]
      }
    end

    def load_recipient
      @recipient = Recipient.find_by_hashid(params[:hashid])
    end

    def user_not_authorised
      if @recipient&.proposal
        redirect_to report_path(@recipient.proposal)
      else
        render 'errors/not_found', status: 404
      end
    end
end
