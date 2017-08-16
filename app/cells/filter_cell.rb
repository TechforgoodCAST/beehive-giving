include ERB::Util

class FilterCell < Cell::ViewModel
  def show
    render
  end

  private

    def selected?(value)
      model.value? value
    end

    def select(id, options)
      tag.select id: id do
        options.map do |opt|
          unless opt.kind_of?(Array)
            opt = [opt, opt.capitalize]
          end
          tag.option(opt[1], value: url_encode(opt[0]), selected: selected?(opt[0]))
        end.reduce(:+)
      end
    end
end
