/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import "babel-polyfill";
import Filter from '../modules/filter'
import Select from '../modules/select'

const filter = new Filter()
const select = new Select()

const selectOpts = {
  '-1': ['individual_notice'],
  '1': ['user_charity_number'],
  '2': ['user_company_number'],
  '3': ['user_charity_number', 'user_company_number']
}

document.addEventListener('turbolinks:load', () => {
  filter.init('filter')
  select.init('user_org_type', selectOpts)
})

document.addEventListener('ajax:success', () => {
  select.init('user_org_type', selectOpts)
})
