class ApplicationCell < Cell::ViewModel

    def analysis
        muted = (model.eligible_status(options[:fund].slug) == -1 || suitable_status == -1) ? 'muted' : nil
        render locals: { fund: options[:fund], status: get_application_status, muted: muted }
    end

    def index
        muted = (model.eligible_status(options[:fund].slug) == -1 || suitable_status == -1) ? 'muted' : nil
        render locals: { fund: options[:fund], status: get_application_status, muted: muted }
    end

    private

        def suitable_status
            # return -1 if options[:fund].priorities.present? && model.suitability[options[:fund].slug]&.dig(:quiz, "score") == nil
            model.suitable_status(options[:fund].slug)
        end

        def get_application_status
            status = [model.eligible_status(options[:fund].slug), suitable_status]
            case status
            when [0, 0] # ineligble, unsuitable
                # don't bother applying
                {
                    message: "You're both ineligible and unsuitable for this fund",
                    apply: false,
                    colour: 'red', 
                    symbol: "\u2718".html_safe,
                    status: 'Ineligible',
                }
            when [0, 1], [0, 2] # ineligible, suitable
                # could tweak application profile
                {
                    message: "You're ineligible for this fund, but if you changed your proposal you might be suitable",
                    apply: false,
                    link_to: "#",
                    link_text: "Edit my proposal",
                    colour: 'red', 
                    symbol: "\u2718".html_safe,
                    status: 'Ineligible',
                }
            when  [0, -1] # ineligible, pending
                # don't both applying
                {
                    message: "You're ineligible for this fund",
                    apply: false,
                    colour: 'red', 
                    symbol: "\u2718".html_safe,
                    status: 'Ineligible',
                }
            when [1, 0] # eligible, unsuitable
                {
                    message: "You're eligible for this fund, but it looks like your proposal is not what they're looking for",
                    apply: true,
                    colour: 'yellow', 
                    symbol: "~",
                    status: 'Unsuitable'
                }
            when [1, 1], [1, 2] # eligible, suitable
                {
                    message: "You're eligible and suitable for this fund",
                    apply: true,
                    colour: 'green', 
                    symbol: "\u2714".html_safe,
                    status: 'Apply'
                }
            when [1, -1] # eligible, pending
                {
                    message: "Pending suitability checks",
                    apply: 'pending',
                    symbol: "<span class=\"white dot dot-14 bg-blue mr3\"></span>".html_safe,
                    colour: 'blue',
                    status: 'Pending'
                }
            when [-1, -1] # pending, pending
                {
                    message: "Pending eligibility and suitability checks",
                    apply: 'pending',
                    symbol: "<span class=\"white dot dot-14 bg-blue mr3\"></span>".html_safe,
                    colour: 'blue',
                    status: 'Pending'
                }
            when [-1, 0], [-1, 1], [-1, 2] # pending, xx
                {
                    message: "Pending eligibility checks",
                    apply: 'pending',
                    symbol: "<span class=\"white dot dot-14 bg-blue mr3\"></span>".html_safe,
                    colour: 'blue',
                    status: 'Pending'
                }
            end
        end
    
end