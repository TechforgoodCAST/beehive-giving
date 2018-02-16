export default class Filter {
  init (cls) {
    this._filterOnChange(cls)
  }

  _filterOnChange (cls) {
    const self = this
    document.addEventListener('change', function (e) {
      const $form = e.target.form
      if ($form.classList.contains(cls.substring(1))) {
        e.preventDefault()
        if (window.Turbolinks) {
          window.Turbolinks.visit(self._combinedQueryString(cls))
        } else {
          window.location = self._combinedQueryString(cls)
        }
      }
    })
  }

  _parseInputs (form) {
    return [...form.elements].map((el) => `${el.id}=${el.value}`).join('&')
  }

  _combinedQueryString (cls) {
    return '?' + [
      ...document.querySelectorAll(cls)
    ].map(f => this._parseInputs(f)).join('&')
  }
}
