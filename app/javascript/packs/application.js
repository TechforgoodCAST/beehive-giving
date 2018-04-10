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

  select.orgType(['signup_basics', 'basics_step', 'eligibility_step'])

  const eligibilityStepOpts = {
    '0': ['districts'],
    '1': ['districts'],
    '2': ['recipient_country'],
    '3': ['eligibility_step_country_ids']
  }
  select.init('eligibility_step_affect_geo', eligibilityStepOpts)

  // TODO: refactor
  const affectGeoOpts = {
    '0': ['signup_suitability_proposal_districts'],
    '1': ['signup_suitability_proposal_districts'],
    '2': ['signup_suitability_recipient_country'],
    '3': ['signup_suitability_proposal_countries']
  }
  select.init('signup_suitability_proposal_affect_geo', affectGeoOpts)
})

// TODO: remove
document.addEventListener('ajax:success', () => {
  select.orgType('user')
})

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
