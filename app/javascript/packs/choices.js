import Choices from 'choices.js'
import 'choices.js/assets/styles/css/choices.min.css'

document.addEventListener('turbolinks:load', () => {
  const selector = '.choices-select'
  if (document.querySelector(selector)) {
    return new Choices(selector, {
      removeItemButton: true,
      itemSelectText: 'Select'
    })
  }
})
