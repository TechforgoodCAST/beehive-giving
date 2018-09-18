class RecipientsController < ApplicationController
  layout 'fullscreen'

  before_action :load_collection

  def new
    if @collection
      @recipient = Recipient.new
      @recipient.answers = criteria.map do |c|
        Answer.new(category: @recipient, criterion: c)
      end
    else
      redirect_back(fallback_location: root_path)
    end
  end

  def create
    @recipient = Recipient.new(form_params)
    @recipient.user = current_user

    if @recipient.save
      redirect_to new_proposal_path(@collection, @recipient)
    else
      @district = District.find_by(id: form_params[:district_id])
      render :new
    end
  end

  private

    def criteria
      @collection.restrictions.where(category: 'Recipient')
    end

    def form_params
      params.require(:recipient).permit(
        :category_code, :country_id, :description, :district_id, :name,
        :income_band, :operating_for, :charity_number, :company_number,
        :website, answers_attributes: %i[eligible criterion_id]
      )
    end

    def load_collection
      @collection = Funder.find_by(slug: params[:slug]) ||
                    Theme.find_by(slug: params[:slug])

      render('errors/not_found', status: 404) if @collection.nil?
    end
end
