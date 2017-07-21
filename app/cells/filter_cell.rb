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
          tag.option(opt.capitalize, value: opt, selected: selected?(opt))
        end.reduce(:+)
      end
    end
end
