/* eslint-env jest */

import Sort from '../modules/sort'

const sort = new Sort()

const triggerChange = (id) => {
  const $form = document.getElementById(id)
  $form.dispatchEvent(new Event('change'))
}

document.body.innerHTML = `
  <form id="sort-form">
    <select id="sort">
      <option value="eligibility">Eligibility</option>
      <option value="name">Name</option>
    </select>
  </form>
`

Object.defineProperty(
  window.location, 'search', { value: '?existing=query', writable: true }
)

sort.init('sort-form')

test('appends query string', () => {
  triggerChange('sort-form')
  expect(window.location.search).toEqual('existing=query&sort=eligibility')
})

test('appends query string', () => {
  document.getElementById('sort').children[1].selected = true
  triggerChange('sort-form')
  expect(window.location.search).toEqual('existing=query&sort=name')
})
