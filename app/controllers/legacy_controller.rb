class LegacyController < ApplicationController
  before_action :ensure_logged_in

  def reset
    user = User.find_by(id: params[:id])
    return unless user&.legacy?
    cookies.delete(:auth_token)
    user.organisation.present? ? user.organisation.destroy : user.destroy
    redirect_to root_path, notice: 'Account reset, please re-register'
  end

  private

    def legacy_funder; end

    def legacy_fundraiser; end
end
