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

document.addEventListener('turbolinks:load', () => {
  filter.init('filter')
  select.orgType('user')
  select.orgType('basics_step')
})

document.addEventListener('ajax:success', () => {
  select.orgType('user')
})
