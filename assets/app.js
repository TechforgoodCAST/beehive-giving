function arrayPercentages(arr) {
  let sum = arr.reduce((s, v) => (s += v), 0);
  return arr.map((v) => ((v / sum) * 100).toFixed(2));
}

Chart.defaults.global.defaultFontFamily = '"Cabin", Helvetica, sans-serif';
Chart.defaults.global.defaultFontSize = 16;

const PRIMARY_COLOUR = "#3B88F5";
const SECONDARY_COLOUR = "#1C4073";
const HIGHLIGHT_COLOUR = "rgb(255, 204, 28)";

Vue.filter("formatNumber", function (value) {
  return new Intl.NumberFormat().format(value);
});

Vue.component("bar-chart", {
  extends: VueChartJs.HorizontalBar,
  mixins: [VueChartJs.mixins.reactiveProp],
  props: ["chartData", "hideLegend", "percentages"],
  data() {
    return {};
  },
  computed: {
    options: function () {
      component = this;
      return {
        responsive: true,
        legend: {
          display: this.hideLegend ? false : true,
        },
        scales: {
          xAxes: [
            {
              gridLines: {
                display: false,
              },
              ticks: {
                display: true,
                maxTicksLimit: 2,
                callback: function (value, index, values) {
                  return component.percentages ? value + "%" : value;
                },
              },
              display: component.percentages ? true : false,
            },
          ],
          yAxes: [
            {
              gridLines: {
                display: false,
              },
            },
          ],
        },
      };
    },
  },
  mounted() {
    this.renderChart(this.chartData, this.options);
  },
});

var app = new Vue({
  delimiters: ["#{", "}#"], // To avoid conflicts with Liquid template language (https://shopify.github.io/liquid/) used by Jekyll.
  el: "#app",
  data() {
    return {
      stats: null,
      show: "all",
      charts: {
        "Type of recipient": "recipient_category",
        "Type of recipient": "recipient_income_band",
        "Type of recipient": "recipient_operating_for",
        "Type of recipient": "geographic_scale",
        "Type of funding": "category ",
        // "Type of recipient": 'recipient_income_band',
        "Amount of funding": "amount_bins",
        "Duration of funding": "duration_bins",
        "Project area": "area",
        "Project themes": "themes",
      },
    };
  },
  computed: {
    currentStats: function () {
      if (this.stats) {
        return this.show.split(".").reduce((o, i) => o[i], this.stats);
      }
    },
    allStats: function () {
      if (this.stats) {
        return this.stats["all"];
      }
    },
    currentTitle: function () {
      if (this.show != "all") {
        return this.show.replace("theme.", "").replace("area.", "");
      }
      return "All proposals";
    },
    currentExample: function () {
      if (this.currentStats) {
        return this.currentStats["examples"][
          Math.floor(Math.random() * this.currentStats["examples"].length)
        ];
      }
    },
    wordCountStats: function () {
      if (this.currentStats) {
        return {
          max: Math.max(...Object.values(this.currentStats['word_counts'])),
          min: Math.min(...Object.values(this.currentStats['word_counts'])),
        }
      }
    },
  },
  mounted() {
    fetch("/beehive-giving/assets/results.json")
      .then((r) => r.json())
      .then((response) => (this.stats = response));
  },
  methods: {
    chartData: function (chart, label, percentages, highlight_value) {
      if (!this.stats) {
        return {};
      }
      if (typeof percentages == "undefined") {
        percentages = true;
      }
      if (!label) {
        label = this.show;
      }
      if (label == "all" && this.allStats) {
        var data = this.allStats[chart];
      } else if (this.currentStats) {
        var data = this.currentStats[chart];
      } else {
        return;
      }
      var datasets = [
        {
          label: this.currentTitle,
          backgroundColor: Object.keys(data).map((k) => {
            if (k == highlight_value) {
              return HIGHLIGHT_COLOUR;
            }
            return label == "all" ? PRIMARY_COLOUR : SECONDARY_COLOUR;
          }),
          data: percentages
            ? arrayPercentages(Object.values(data))
            : Object.values(data),
        },
      ];
      if (label != "all") {
        datasets.push({
          label: "All proposals",
          backgroundColor: PRIMARY_COLOUR,
          data: percentages
            ? arrayPercentages(Object.values(this.allStats[chart]))
            : Object.values(this.allStats[chart]),
        });
      }

      if (chart == "recipient_income_band") {
        // from https://data.ncvo.org.uk/profile/
        ncvo_values = [77601, 57956, 24820, 5464, 751];
        datasets.push({
          label: "All charities (NCVO Almanac)",
          backgroundColor: "#4f276d",
          data: percentages ? arrayPercentages(ncvo_values) : ncvo_values,
        });
      }

      if (chart == "duration_bins") {
        // from 360Giving colab notebook
        // Under 12 months    17055
        // 12 months          36665
        // 18 months            858
        // 2 years             3341
        // 3 years             8979
        // 4 years +           1539
        ncvo_values = [17055, 36665, 858, 3341, 8979, 1539];
        datasets.push({
          label: "Grants on 360Giving",
          backgroundColor: "#4f276d",
          data: percentages ? arrayPercentages(ncvo_values) : ncvo_values,
        });
      }

      if (chart == "amount_bins") {
        // from 360Giving colab notebook
        // Under £500       4089
        // £500 - £1k       7305
        // £1k - £2k       10799
        // £2k - £5k       26644
        // £5k - £10k      44389
        // £10k - £100k    26007
        // £100k - £1m      9387
        // Over £1m          968
        ncvo_values = [4089, 7305, 10799, 26644, 44389, 26007, 9387, 968];
        datasets.push({
          label: "Grants on 360Giving",
          backgroundColor: "#4f276d",
          data: percentages ? arrayPercentages(ncvo_values) : ncvo_values,
        });
      }

      return {
        labels: Object.keys(data),
        datasets: datasets,
      };
    },
    biggestValue: function (chart) {
      if (!this.currentStats) {
        return "";
      }
      var data = this.currentStats[chart];
      var sortedData = Object.entries(data).sort((a, b) => b[1] - a[1]);
      return sortedData[0][0];
    },
    fontSize: function (count) {
      var scaling = 20;
      if (this.wordCountStats.max > this.wordCountStats.min) {
        scaling = 50;
      }
      return (((count / this.wordCountStats.max) * scaling) + 10) + "px";
    },
  },
});
