export default class Filter {
  init (form) {
    this._filterOnChange(form)
  }

  _filterOnChange (form) {
    const $form = document.getElementById(form)
    if (!$form) return
    const self = this
    $form.addEventListener('change', function (e) {
      e.preventDefault()
      if (window.Turbolinks) {
        window.Turbolinks.visit(self._parseInputs(this))
      } else {
        window.location = self._parseInputs(this)
      }
    })
  }

  _parseInputs (form) {
    return '?' + [...form.elements].map((el) => `${el.id}=${el.value}`).join('&')
  }
}
