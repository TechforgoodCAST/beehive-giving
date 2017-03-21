class SubmitFormCell < Cell::ViewModel
  def show
    options[:f].button :button,
                       options[:button_text],
                       class: classes,
                       data: { disable_with: disable_with }
  end

  private

    def classes
      'uk-button uk-button-primary uk-button-large uk-width-medium-1-2 ' \
      'uk-float-right'
    end

    def disable_with_text
      options[:disable_with_text] || ''
    end

    def disable_with
      "<i style='color: #fff;'
          class='uk-icon uk-icon-circle-o-notch uk-icon-spin'></i>
       <span style='color: #fff;'> #{disable_with_text}</span>"
    end
end
