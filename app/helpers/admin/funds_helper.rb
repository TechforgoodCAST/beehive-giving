module Admin
  module FundsHelper
    def check_presence(fund, field)
      presence = fund.send(field).present?.to_s
      to_words = { 'true' => 'yes', 'false' => 'no' }
      Arbre::Context.new do
        span to_words[presence], class: "status_tag #{to_words[presence]}"
      end
    end
  end
end
