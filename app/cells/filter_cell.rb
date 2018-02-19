include ERB::Util

class FilterCell < Cell::ViewModel
  def show
    render
  end

  private

    def selected?(id, value)
      model[id.to_sym] == value
    end

    def select(id, options)
      tag.select id: id do
        options.map do |opt|
          opt = [opt, opt.humanize.capitalize] unless opt.is_a?(Array)
          tag.option(opt[1], value: url_encode(opt[0]), selected: selected?(id, opt[0]))
        end.reduce(:+)
      end
    end

    def proposal_duration
      ['proposal', "Your proposal (#{options[:funding_duration]} months)"] if
        options[:funding_duration]
    end
end
