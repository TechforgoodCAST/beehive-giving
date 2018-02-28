import dialogPolyfill from 'dialog-polyfill'

export default class Dialog {
  init ($body = document.body, dialog = 'dialog') {
    const $modal = document.querySelector(dialog)
    if (!$modal) return
    dialogPolyfill.registerDialog($modal)

    document.querySelector('.js-show-modal').onclick = () => {
      $body.classList.add('js-open-modal')
      $modal.showModal()
    }

    document.querySelector('.js-close-modal').onclick = () => {
      $body.classList.remove('js-open-modal')
      $modal.close()
    }
  }
}
