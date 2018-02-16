/* eslint-env jest */

import Filter from '../modules/filter'

const filter = new Filter()
const dom = `
  <form class="filter">
    <select id="eligibility">
      <option value="eligible">Eligible</option>
    </select>
    <select id="duration">
      <option value="up-to-2y">Up to 2 years</option>
    </select>
  </form>
`

test('_parseInputs', () => {
  document.body.innerHTML = dom
  const $form = document.querySelector('.filter')

  expect(filter._parseInputs($form))
    .toEqual('eligibility=eligible&duration=up-to-2y')
})

test('_combinedQueryString', () => {
  document.body.innerHTML = dom + `
    <form class="filter">
      <select id="sort">
        <option value="name">Name</option>
      </select>
    </form>
  `

  expect(filter._combinedQueryString('.filter'))
    .toEqual('?eligibility=eligible&duration=up-to-2y&sort=name')
})
