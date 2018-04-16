module Signup
  class Suitability
    include ActiveModel::Model

    attr_reader :basics, :proposal, :recipient, :user

    def initialize(basics, params = {})
      validate(basics)
      @basics = basics
      @params = params
      load_recipient
      @proposal = @recipient.proposals.new(basics_proposal)
      @user = @recipient.users.new(user_params)
    end

    def country
      @country ||= Country.includes(:districts)
                          .find_by(alpha2: basics_recipient[:country])
    end

    def save
      ActiveRecord::Base.transaction do
        recipient.save!
        proposal.save!
        user.save!
      end
      true
    rescue ActiveRecord::RecordInvalid => e
      errors.add(:base, e.message)
      false
    end

    def recipient_registered
      if user.valid? && recipient.persisted?
        user.save
        user.lock_access_to_organisation(recipient)
        true
      else
        false
      end
    end

    private

      def basics_proposal
        basics.proposal.merge(@params[:proposal] || {})
              .tap do |h|
                h[:themes] = Theme.where(id: h[:themes])
                h[:countries] = [country] if country
              end
      end

      def basics_recipient
        basics.recipient.merge(@params[:recipient] || {})
      end

      def load_recipient
        @recipient = Recipient.new(basics_recipient)
        @recipient.scrape_org # TODO: refactor
        @recipient = @recipient.find_with_reg_nos || @recipient
      end

      def validate(obj)
        return if obj.respond_to?(:valid?) && obj.valid?
        raise(ArgumentError, 'Invalid Signup::Basics object')
      end

      def user_params
        (@params[:user] || {}).merge(terms_version: TERMS_VERSION)
      end
  end
end
