class RecipientAttributeController < ApplicationController
  before_filter :ensure_logged_in, :load_recipient

  def new
    unless @recipient.attribute
      @attribute = @recipient.build_recipient_attribute
    else
      redirect_to root_path
      flash[:alert] = "Only one allowed"
    end
  end

  def create
    @attribute = @recipient.build_recipient_attribute(attribute_params)

    if @attribute.save
      flash[:notice] = 'Saved!'
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
    @attribute = @recipient.attribute
  end

  def update
    if @recipient.attribute.update_attributes(attribute_params)
      redirect_to root_path, notice: 'Updated!'
    else
      render :edit
    end
  end

  private

  def attribute_params
    params.require(:recipient_attribute).permit(:recipient, :problem, :solution)
  end

  def load_recipient
    @recipient = Recipient.find_by_slug(params[:recipient_id])
  end
end
