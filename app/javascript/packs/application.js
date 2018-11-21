/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import "babel-polyfill";
import Dialog from "../modules/dialog";
import Select from "../modules/select";
import Sort from "../modules/sort";

const dialog = new Dialog();
const select = new Select();
const sort = new Sort();

document.addEventListener("turbolinks:load", function () {
    dialog.init();
    sort.init("sort-form");

    const unincorporatedFields = [
        "recipient_name",
        "recipient_income_band",
        "recipient_operating_for",
        "recipient_website"
    ];

    const incorporatedFields = [
        "recipient_description",
        "recipient_name",
        "recipient_charity_number",
        "recipient_company_number",
        "recipient_income_band",
        "recipient_operating_for",
        "recipient_website"
    ];

    select.init("recipient_category_code", {
        "102": incorporatedFields,
        "201": unincorporatedFields,
        "202": unincorporatedFields,
        "203": unincorporatedFields,
        "301": incorporatedFields,
        "302": incorporatedFields,
        "303": incorporatedFields
    });

    select.init("proposal_category_code", {
        "101": ["proposal_support_details"],
        "201": ["seeking-funding"],
        "202": ["seeking-funding"],
        "203": ["seeking-funding"]
    });

    select.init("proposal_geographic_scale", {
        "local": ["proposal_country_id", "proposal_districts"],
        "regional": ["proposal_country_id", "proposal_districts"],
        "national": ["proposal_country_id"],
        "international": ["proposal_countries"]
    });
}, false);

// Utility
window.trackOutboundLink = function (url) {
    window.ga("send", "event", "outbound", "click", url, {
        "transport": "beacon"
    });
};
