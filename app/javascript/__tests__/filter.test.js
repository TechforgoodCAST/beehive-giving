/* eslint-env jest */

import Filter from '../modules/filter'

const filter = new Filter()

test('_parseInputs', () => {
  document.body.innerHTML = `
    <form id="sort-filter">
      Sort:
      <select id="sort">
        <option value="name">Name</option>
      </select>
      <select id="eligibility">
        <option value="eligible">Eligible</option>
      </select>
    </form>
  `
  const $form = document.getElementById('sort-filter')

  expect(filter._parseInputs($form)).toEqual('?sort=name&eligibility=eligible')
})
