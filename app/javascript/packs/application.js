/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import 'babel-polyfill'
import Dialog from '../modules/dialog'
import Select from '../modules/select'
import Sort from '../modules/sort'

const dialog = new Dialog()
const select = new Select()
const sort = new Sort()

document.addEventListener('turbolinks:load', () => {
  dialog.init()
  sort.init('sort-form')

  const unincorporatedFields = [
    'recipient_name',
    'recipient_income_band',
    'recipient_operating_for',
    'recipient_website'
  ]

  const incorporatedFields = [
    'recipient_description',
    'recipient_name',
    'recipient_charity_number',
    'recipient_company_number',
    'recipient_income_band',
    'recipient_operating_for',
    'recipient_website'
  ]

  const recipientOpts = {
    102: incorporatedFields,
    201: unincorporatedFields,
    202: unincorporatedFields,
    203: unincorporatedFields,
    301: incorporatedFields,
    302: incorporatedFields,
    303: incorporatedFields
  }

  select.init('recipient_category_code', recipientOpts)
})

// TODO: review
// Prevent turbolinks on funds#show and funds#hidden for Google Optimize
document.addEventListener('turbolinks:before-visit', (e) => {
  if (/\/proposals\/[0-9]+\/funds\/[^theme]|\/hidden/.test(e.data.url)) {
    e.preventDefault()
    window.location = e.data.url
  }
})

// Utility
window.trackOutboundLink = (url) => {
  window.ga('send', 'event', 'outbound', 'click', url, {
    'transport': 'beacon',
    'hitCallback': () => { window.open(url) }
  })
}
