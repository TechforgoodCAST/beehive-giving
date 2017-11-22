module Check
  module Eligibility
    class Theme
      include Check::Base

      def call(proposal, fund)
        validate_call proposal, fund
        proposal_themes = get_proposal_themes(proposal)
        match_score = match_themes(proposal_themes, fund.themes)
        return eligible true if match_score.size > 0
        eligible false
      end

      private

        def get_proposal_themes(proposal)
          # get all the themes from a proposal, including the related themes attached to each theme
          proposal_themes = {}
          proposal.themes.each do |theme|
            proposal_themes[theme.name] = 1
            theme.related.each do |theme_name, theme_score|
              proposal_themes[theme_name] = [theme_score, proposal_themes[theme_name] || 0].max
            end
          end
          proposal_themes
        end

        def match_themes(proposal_themes, fund_themes)
          # return the themes from the proposal that match those from the fund
          fund_theme_names = fund_themes.pluck(:name)
          proposal_themes.select { |theme, score| fund_theme_names.include? theme }
        end
    end
  end
end
