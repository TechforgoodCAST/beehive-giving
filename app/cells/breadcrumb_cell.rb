class BreadcrumbCell < Cell::ViewModel
  def show
    return unless model.is_a?(Hash) && model.present?
    model.delete_if { |k, _v| k.nil? }
    render
  end

  private

    def bold(i)
      i == model.size - 1 ? 'bold' : nil
    end

    def disabled(v)
      v.blank? ? 'disabled' : nil
    end
end
