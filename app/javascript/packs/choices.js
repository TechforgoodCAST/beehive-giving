import Choices from 'choices.js'
import 'choices.js/assets/styles/css/choices.min.css'

document.addEventListener('turbolinks:load', () => {
  return new Choices('.choices-select', {
    removeItemButton: true,
    itemSelectText: 'Select'
  })
})
