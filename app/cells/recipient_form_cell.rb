class RecipientFormCell < Cell::ViewModel
  def show
    render locals: { f: options[:f] }
  end

  def lookup
    render locals: { f: options[:f] }
  end

  def submit
    render locals: {
      f: options[:f],
      button_text: options[:button_text] || 'Next',
      disable_with_text: options[:disable_with_text] || "We're off the mark..."
    }
  end

  private

    def scrape_failure # TODO: refactor
      'fade-out' if options[:scrape_success]
    end

    def scrape_success # TODO: refactor
      'fade-out' unless options[:scrape_success]
    end
end
