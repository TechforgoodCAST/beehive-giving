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
      @user = User.new(@params[:user])
    end

    def save
      # TODO: refactor
      ![recipient.valid?, proposal.valid?, user.valid?].include?(false)
    end

    private

      def basics_proposal
        # TODO: refactor
        basics.proposal.merge(@params[:proposal] || {})
              .tap do |h|
                h[:themes] = Theme.where(id: h[:themes])
                h[:countries] = Country.where(alpha2: basics_recipient[:country])
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
        raise ArgumentError, "#{obj} is not a valid Signup::Basics object"
      end
  end
end
