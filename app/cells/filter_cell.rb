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
          if opt.kind_of?(Array)
            v = opt[0]
            k = opt[1]
          else
            v = opt
            k = opt.capitalize
          end
          tag.option(k, value: url_encode(v), selected: selected?(v))
        end.reduce(:+)
      end
    end
end
