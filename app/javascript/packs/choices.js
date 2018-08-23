import Choices from 'choices.js'
import 'choices.js/assets/styles/css/choices.min.css'

document.addEventListener('turbolinks:load', () => {
  const opts = {
    removeItemButton: true,
    itemSelectText: 'Select'
  }

  const selector = '.choices-select'
  if (document.querySelector(selector)) {
    return new Choices(selector, opts);
  }

  // TODO: refactor
  const countrySelect = document.getElementById('recipient_country_id');
  const districtWrapper = document.querySelector('.recipient_district');
  new Choices(countrySelect, opts);
  var example = new Choices('#recipient_district_id', opts);

  if (countrySelect.value === '') {
    districtWrapper.classList.add('hide')
  } else {
    districtWrapper.classList.remove('hide')
  }

  countrySelect.addEventListener('change', function () {
    example.clearStore();

    if (this.value === '') {
      districtWrapper.classList.add('hide')
    } else {
      districtWrapper.classList.remove('hide')

      const url = `/api/v1/districts/${this.value}`;

      example.ajax(function(callback) {
        fetch(url)
        .then(function(response) {
          response.json().then(function(data) {
            callback(data, 'value', 'label');
          })
        })
        .catch(function(error) {
          console.log(error);
        });
      });
    }
  }, false)

}, false)
