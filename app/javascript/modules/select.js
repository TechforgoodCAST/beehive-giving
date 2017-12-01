export default class Select {
  // select: id of HTML select tag
  // opts: { <select.option.value>: [classes, to, hide/show] }
  init (select, opts) {
    this._hideOpts(select, opts)
    this._selectOnChange(select, opts)
  }

  orgType (prefix) {
    const select = `${prefix}_org_type`
    const opts = {
      '-1': ['individual_notice'],
      '1': [`${prefix}_charity_number`],
      '2': [`${prefix}_company_number`],
      '3': [`${prefix}_charity_number`, `${prefix}_company_number`],
      '5': [`${prefix}_company_number`]
    }
    this.init(select, opts)
  }

  _hideOpts (select, opts) {
    const $select = document.getElementById(select)
    if (!$select) return

    const selectedClasses = opts[$select.value] || []

    const classes = [].concat.apply([], Object.values(opts))
                      .filter(i => selectedClasses.indexOf(i) === -1)

    classes.forEach((cls) => {
      for (const el of Array.from(document.getElementsByClassName(cls))) {
        el.classList.add('hide')
      }
    })
  }

  _selectOnChange (select, opts) {
    const $select = document.getElementById(select)
    if (!$select) return
    const self = this
    $select.addEventListener('change', function (e) {
      self._hideOpts(select, opts)
      if (opts[this.value]) {
        const classes = opts[this.value].map(i => '.' + i)
        const $els = document.querySelectorAll(classes)
        for (const el of $els) {
          el.classList.remove('hide')
        }
      }
    })
  }
}
