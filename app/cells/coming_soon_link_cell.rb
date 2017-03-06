class ComingSoonLinkCell < Cell::ViewModel
  def show(text, styles = '')
    link_to text, '#why-hidden',
            class: 'why-hidden ' + styles,
            onclick: "goog_report_conversion('#why-hidden')"
  end
end
