let ApplicationHelper = function(d, w) {

  let comingSoonModal = function() {
    $('.why-hidden').on('click', function(e) {
      e.preventDefault();
      $.UIkit.modal("#why-hidden").show();
    });
  }

  return {
    comingSoonModal: comingSoonModal
  }
}(window, document);

$(document).ready(function() {
  ApplicationHelper.comingSoonModal();
});
