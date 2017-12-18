/* eslint-env jest */

import Select from '../modules/select'

const select = new Select()

const body = (select = 'select', selected = '', field = 'field') => {
  return `
    <select id=${select}>
      <option value></option>
      <option selected=${selected} value="1">One</option>
    </select>
    <div class=${field}></div>
  `
}

test('#init, unselected hides all specified', () => {
  document.body.innerHTML = body()

  expect(document.querySelector('.field').classList.length).toEqual(1)

  select.init('select', { '1': ['field'] })

  expect(document.querySelector('.field').classList[1]).toEqual('hide')
})

test('#init, selected is visible', () => {
  document.body.innerHTML = body('select', 'selected')
  select.init('select', { '1': ['field'] })

  expect(document.querySelector('.field').classList.length).toEqual(1)
})

test('#orgType, requires Array as argument', () => {
  expect(() => select.orgType('prefix')).toThrow()
})

test('#orgType, unselected hides all specified', () => {
  document.body.innerHTML = body('prefix_org_type', '', 'prefix_charity_number')

  expect(document.querySelector('.prefix_charity_number').classList.length).toEqual(1)

  select.orgType(['prefix'])

  expect(document.querySelector('.prefix_charity_number').classList[1]).toEqual('hide')
})

test('#orgType, selected is visible', () => {
  document.body.innerHTML = body('prefix_org_type', 'selected', 'prefix_charity_number')
  select.orgType(['prefix'])

  expect(document.querySelector('.prefix_charity_number').classList.length).toEqual(1)
})
