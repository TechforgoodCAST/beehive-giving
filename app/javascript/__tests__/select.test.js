/* eslint-env jest */

import Select from '../modules/select'

const select = new Select()

test('#init, unselected hides all specified', () => {
  document.body.innerHTML = `
    <select id="select">
      <option value></option>
      <option value="1">One</option>
    </select>
    <div class="field"></div>
  `
  expect(document.querySelector('.field').classList.length).toEqual(1)

  select.init('select', { '1': ['field'] })

  expect(document.querySelector('.field').classList[1]).toEqual('hide')
})

test('#init, selected is visible', () => {
  document.body.innerHTML = `
    <select id="select">
      <option value></option>
      <option selected="selected" value="1">One</option>
    </select>
    <div class="field"></div>
  `

  select.init('select', { '1': ['field'] })

  expect(document.querySelector('.field').classList.length).toEqual(1)
})
