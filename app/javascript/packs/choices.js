import Choices from "choices.js";
import "choices.js/assets/styles/css/choices.min.css";

document.addEventListener("turbolinks:load", function () {
    const opts = {
        removeItemButton: true,
        itemSelectText: "Select"
    };

    const selector = ".choices-select";
    if (document.querySelector(selector)) {
        new Choices(selector, opts);
    }

    const questions = document.querySelector(".has_many_container.questions");

    const observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
            new Choices(mutation.addedNodes[0].elements[1], opts);
        });
    });

    if (questions) {
        observer.observe(questions, { childList: true });
    } else {
        observer.disconnect();
    }

    if (document.getElementById("recipient_district_id")) {
        const select = document.getElementById("recipient_country_id");
        const choices = new Choices("#recipient_district_id", opts);
        choicesDistricts(select, choices, ".recipient_district");
    }

    if (document.getElementById("proposal_district_ids")) {
        const select = document.getElementById("proposal_country_id");
        const choices = new Choices("#proposal_district_ids", opts);
        choicesDistricts(select, choices, ".proposal_districts");
    }

}, false);

function choicesDistricts (select, choices, cls) {
    select.value === "" ? hide(cls) : show(cls);

    select.addEventListener("change", function () {
        choices.clearStore();

        if (this.value === "") {
            hide(cls);
        } else {
            show(cls);
            districtsApi(this.value, choices);
        }

    }, false);
}

function districtsApi (alpha2, choices) {
    const url = `/api/v1/districts/${alpha2}`;

    choices.ajax(function (callback) {
        fetch(url)
            .then(function (response) {
                response.json().then(function (data) {
                    callback(data, "value", "label");
                });
            })
            .catch(function (error) {
                console.log(error);
            });
    });
}

function hide (cls) {
    document.querySelector(cls).parentNode.classList.add("hide");
}

function show (cls) {
    document.querySelector(cls).parentNode.classList.remove("hide");
}
