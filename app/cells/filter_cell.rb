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
          unless opt.kind_of?(Array)
            opt = [opt, opt.humanize.capitalize]
          end
          tag.option(opt[1], value: url_encode(opt[0]), selected: selected?(id, opt[0]))
        end.reduce(:+)
      end
    end
end
