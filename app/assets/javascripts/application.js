// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.

//= require jquery

//= require rails-ujs
//= require turbolinks

//= require uikit/uikit
//= require uikit/core/core
//= require uikit/core/alert
//= require uikit/core/button
//= require uikit/core/cover
//= require uikit/core/dropdown
//= require uikit/core/grid
//= require uikit/core/modal
//= require uikit/core/nav
//= require uikit/core/offcanvas
//= require uikit/core/scrollspy
//= require uikit/core/smooth-scroll
//= require uikit/core/switcher
//= require uikit/core/tab
//= require uikit/core/toggle
//= require uikit/core/touch
//= require uikit/core/utility
//= require uikit/components/form-password
//= require uikit/components/form-select
//= require uikit/components/grid
//= require uikit/components/notify
//= require uikit/components/sticky
//= require uikit/components/tooltip

document.addEventListener('turbolinks:load', function () {
  (function () {
    var $el = $('#eligibility_step_district_ids')
    if ($el.length) $el.treeMultiselect()
  })()
})
