/* eslint-env jest */

import Dialog from '../modules/dialog'

const dialog = new Dialog()

document.body.innerHTML = `
  <body>
    <a class="js-show-modal">Show</a>
    <a class="js-close-modal">Close</a>
    <dialog></dialog>
  </body>
`
dialog.init()

const $dialog = document.querySelector('dialog')

test('#init, show modal', () => {
  document.querySelector('.js-show-modal').click()
  expect($dialog.hasAttribute('open')).toEqual(true)
})

test('#init, close modal', () => {
  document.querySelector('.js-close-modal').click()
  expect($dialog.hasAttribute('open')).toEqual(false)
})
