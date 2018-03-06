import qs from 'query-string'

export default class Sort {
  // id: id of HTML form tag
  init (id) {
    this._filterOnChange(id)
  }

  _filterOnChange (id) {
    const $form = document.getElementById(id)
    if (!$form) return

    $form.addEventListener('change', function (e) {
      e.preventDefault()
      const queryString = qs.parse(window.location.search)
      Array.from($form.elements).forEach(el => {
        queryString[el.id] = el.value
      })
      window.location.search = qs.stringify(queryString)
    })
  }
}
