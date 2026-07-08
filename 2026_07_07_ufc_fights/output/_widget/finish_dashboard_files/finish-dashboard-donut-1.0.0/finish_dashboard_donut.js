(function () {
  "use strict";

  var GROUP = "finish_dash";
  var fightIndex = [];
  var finishColors = {};
  var divisionColors = {};
  var filterHandle = null;
  var activeFilter = null;
  var bound = {};

  function loadConfig() {
    var indexEl = document.getElementById("fight-index");
    var finishEl = document.getElementById("finish-colors");
    var divisionEl = document.getElementById("division-colors");
    if (!indexEl || !finishEl || !divisionEl) {
      return false;
    }
    fightIndex = JSON.parse(indexEl.textContent);
    finishColors = JSON.parse(finishEl.textContent);
    divisionColors = JSON.parse(divisionEl.textContent);
    return true;
  }

  function getActiveRows() {
    if (!filterHandle) {
      return fightIndex;
    }
    var keys = filterHandle.filteredKeys;
    if (keys === null || keys === undefined) {
      return fightIndex;
    }
    var keySet = {};
    keys.forEach(function (k) {
      keySet[k] = true;
    });
    return fightIndex.filter(function (row) {
      return keySet[row.key];
    });
  }

  function keysForFilter(kind, label) {
    return fightIndex
      .filter(function (row) {
        if (kind === "outcome") {
          return row.finish_type === label;
        }
        if (kind === "men") {
          return !row.is_womens && row.weight_class === label;
        }
        return row.is_womens && row.weight_class === "Women's " + label;
      })
      .map(function (row) {
        return row.key;
      });
  }

  function aggregate(rows, kind) {
    var counts = {};

    rows.forEach(function (row) {
      var label;
      if (kind === "outcome") {
        label = row.finish_type;
      } else if (kind === "men") {
        if (row.is_womens) {
          return;
        }
        label = row.weight_class;
      } else {
        if (!row.is_womens) {
          return;
        }
        label = row.weight_class.replace(/^Women's /, "");
      }

      counts[label] = (counts[label] || 0) + 1;
    });

    var order;
    if (kind === "outcome") {
      order = Object.keys(finishColors);
    } else if (kind === "men") {
      order = divisionColors.men_order || [];
    } else {
      order = divisionColors.women_order || [];
    }

    order = order.filter(function (k) {
      return counts[k] > 0;
    });

    return {
      labels: order,
      values: order.map(function (k) {
        return counts[k];
      }),
      colors: order.map(function (k) {
        if (kind === "outcome") {
          return finishColors[k];
        }
        if (kind === "men") {
          return (divisionColors.men || {})[k] || "#999999";
        }
        return (divisionColors.women || {})[k] || "#999999";
      }),
      n: order.reduce(function (sum, k) {
        return sum + counts[k];
      }, 0),
    };
  }

  function titleFor(kind, n) {
    var prefix =
      kind === "outcome"
        ? "Outcome"
        : kind === "men"
          ? "Men's divisions"
          : "Women's divisions";
    return (
      prefix +
      "<br><sup>" +
      n.toLocaleString() +
      " fight" +
      (n === 1 ? "" : "s") +
      "</sup>"
    );
  }

  function bindClick(el, kind) {
    if (bound[el.id]) {
      return;
    }
    bound[el.id] = true;

    el.on("plotly_click", function (event) {
      if (!event || !event.points || !event.points.length) {
        return;
      }
      var label = event.points[0].label;
      if (!label) {
        return;
      }

      if (
        activeFilter &&
        activeFilter.kind === kind &&
        activeFilter.label === label
      ) {
        activeFilter = null;
        filterHandle.clear();
        return;
      }

      activeFilter = { kind: kind, label: label };
      filterHandle.set(keysForFilter(kind, label));
    });

    el.on("plotly_doubleclick", function () {
      activeFilter = null;
      filterHandle.clear();
    });
  }

  function drawDonut(elId, kind, rows) {
    var el = document.getElementById(elId);
    if (!el || typeof Plotly === "undefined") {
      return;
    }

    var agg = aggregate(rows, kind);
    var data = [
      {
        labels: agg.labels,
        values: agg.values,
        type: "pie",
        hole: 0.45,
        textinfo: "label+percent",
        textposition: "outside",
        sort: false,
        marker: {
          colors: agg.colors,
          line: { color: "#FFFFFF", width: 1 },
        },
        hovertemplate: "<b>%{label}</b><br>%{percent}<extra></extra>",
      },
    ];

    var layout = {
      title: {
        text: titleFor(kind, agg.n),
        x: 0.5,
        xanchor: "center",
      },
      showlegend: true,
      legend: { orientation: "h", y: -0.15 },
      margin: { t: 70, b: 50, l: 10, r: 10 },
    };

    var config = { displayModeBar: false, displaylogo: false };

    if (el.data) {
      Plotly.react(el, data, layout, config);
    } else {
      Plotly.newPlot(el, data, layout, config).then(function () {
        bindClick(el, kind);
      });
    }
  }

  function redrawAll() {
    var rows = getActiveRows();
    drawDonut("donut-outcome", "outcome", rows);
    drawDonut("donut-men", "men", rows);
    drawDonut("donut-women", "women", rows);
  }

  function init() {
    if (!loadConfig()) {
      return;
    }

    function tryInit(attempt) {
      if (
        typeof crosstalk === "undefined" ||
        typeof Plotly === "undefined" ||
        !document.getElementById("donut-outcome")
      ) {
        if (attempt < 100) {
          setTimeout(function () {
            tryInit(attempt + 1);
          }, 50);
        }
        return;
      }

      filterHandle = new crosstalk.FilterHandle(GROUP);
      filterHandle.on("change", function (e) {
        if (!e || e.sender !== filterHandle) {
          if (filterHandle.filteredKeys === null) {
            activeFilter = null;
          }
        }
        redrawAll();
      });

      redrawAll();
    }

    tryInit(0);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
