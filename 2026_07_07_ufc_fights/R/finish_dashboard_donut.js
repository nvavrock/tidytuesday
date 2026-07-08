(function () {
  "use strict";

  var GROUP = "finish_dash";
  var fightIndex = [];
  var finishColors = {};
  var divisionColors = {};
  var listenHandle = null;
  var setHandle = null;
  var lastExternalKeys = null;
  var applying = false;
  var selectedLabelsByKind = {
    outcome: new Set(),
    men: new Set(),
    women: new Set(),
  };
  var bound = {};
  var plotted = {};
  var suppressClickUntil = 0;
  var lastSliceClick = {};
  var DIMMED_SLICE = "#D1D5DB";

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

  function rowsFromKeys(keys) {
    if (keys === null || keys === undefined) {
      return fightIndex;
    }
    if (keys.length === 0) {
      return [];
    }
    var keySet = {};
    keys.forEach(function (k) {
      keySet[k] = true;
    });
    return fightIndex.filter(function (row) {
      return keySet[row.key];
    });
  }

  function getExternalRows() {
    return rowsFromKeys(lastExternalKeys);
  }

  function getActiveRows() {
    var rows = getExternalRows();
    var donutKeys = donutKeysFromSelection();
    if (!donutKeys || donutKeys.length === 0) {
      return rows;
    }
    var keySet = {};
    donutKeys.forEach(function (k) {
      keySet[k] = true;
    });
    return rows.filter(function (row) {
      return keySet[row.key];
    });
  }

  function getActiveKeyCount() {
    if (!listenHandle) {
      return getActiveRows().length;
    }
    var keys = listenHandle.filteredKeys;
    if (keys === null || keys === undefined) {
      return fightIndex.length;
    }
    return keys.length;
  }

  function resolveSliceLabel(el, event) {
    var pt = event.points[0];
    if (!pt) {
      return null;
    }
    var labels = el.__sliceLabels;
    if (
      labels &&
      pt.pointNumber !== undefined &&
      labels[pt.pointNumber] !== undefined
    ) {
      return labels[pt.pointNumber];
    }
    var raw = (pt.label || "").trim();
    if (el.__sliceKind === "outcome") {
      var names = Object.keys(finishColors);
      for (var i = 0; i < names.length; i++) {
        if (raw === names[i] || raw.indexOf(names[i]) === 0) {
          return names[i];
        }
      }
    }
    return raw;
  }

  function hasAnyDonutSelection() {
    return (
      selectedLabelsByKind.outcome.size > 0 ||
      selectedLabelsByKind.men.size > 0 ||
      selectedLabelsByKind.women.size > 0
    );
  }

  function keysForKind(kind, baseRows) {
    var labelSet = selectedLabelsByKind[kind];
    if (!labelSet.size) {
      return null;
    }
    var tmp = {};
    labelSet.forEach(function (lab) {
      keysForFilter(kind, lab, baseRows).forEach(function (k) {
        tmp[k] = true;
      });
    });
    return Object.keys(tmp);
  }

  function intersectKeyLists(a, b) {
    var keySet = {};
    b.forEach(function (k) {
      keySet[k] = true;
    });
    return a.filter(function (k) {
      return keySet[k];
    });
  }

  function rowsFromKeyList(baseRows, keys) {
    if (!keys) {
      return baseRows;
    }
    var keySet = {};
    keys.forEach(function (k) {
      keySet[k] = true;
    });
    return baseRows.filter(function (row) {
      return keySet[row.key];
    });
  }

  function rowsForDonut(kind) {
    var baseRows = getExternalRows();
    var kinds = ["outcome", "men", "women"];
    var resultKeys = null;

    kinds.forEach(function (k) {
      if (k === kind) {
        return;
      }
      var kindKeys = keysForKind(k, baseRows);
      if (kindKeys === null) {
        return;
      }
      resultKeys =
        resultKeys === null ? kindKeys : intersectKeyLists(resultKeys, kindKeys);
    });

    return rowsFromKeyList(baseRows, resultKeys);
  }

  function refreshDatatable() {
    if (typeof jQuery === "undefined") {
      return;
    }
    jQuery(".datatables.html-widget").each(function () {
      var table = jQuery(this).data("datatable");
      if (table && table.draw) {
        table.draw(false);
      }
    });
  }

  function snapshotExternalKeys() {
    if (!listenHandle) {
      return;
    }
    applying = true;
    if (setHandle) {
      setHandle.clear();
    }
    lastExternalKeys = listenHandle.filteredKeys;
    applying = false;
  }

  function clearSelection() {
    selectedLabelsByKind.outcome.clear();
    selectedLabelsByKind.men.clear();
    selectedLabelsByKind.women.clear();
    lastSliceClick = {};
    pushDonutFilter();
  }

  function keysForFilter(kind, label, rows) {
    return rows
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

  function donutKeysFromSelection() {
    if (!hasAnyDonutSelection()) {
      return null;
    }
    var baseRows = getExternalRows();
    var kinds = ["outcome", "men", "women"];
    var resultKeys = null;

    kinds.forEach(function (kind) {
      var kindKeys = keysForKind(kind, baseRows);
      if (kindKeys === null) {
        return;
      }
      resultKeys =
        resultKeys === null ? kindKeys : intersectKeyLists(resultKeys, kindKeys);
    });

    return resultKeys;
  }

  function pushDonutFilter() {
    if (!setHandle) {
      redrawAll();
      return;
    }

    var keys = donutKeysFromSelection();

    applying = true;
    if (!keys || keys.length === 0) {
      setHandle.clear();
    } else {
      setHandle.set(keys);
    }
    applying = false;
    refreshDatatable();
    redrawAll();
  }

  function onExternalFilterChange(e) {
    if (e && e.sender === setHandle) {
      if (!applying) {
        redrawAll();
        refreshDatatable();
      }
      return;
    }

    snapshotExternalKeys();
    pushDonutFilter();
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

    var selected = selectedLabelsByKind[kind];
    var hasSelection = selected.size > 0;

    return {
      labels: order,
      values: order.map(function (k) {
        return counts[k];
      }),
      colors: order.map(function (k) {
        var base;
        if (kind === "outcome") {
          base = finishColors[k];
        } else if (kind === "men") {
          base = (divisionColors.men || {})[k] || "#999999";
        } else {
          base = (divisionColors.women || {})[k] || "#999999";
        }
        if (!hasSelection || selected.has(k)) {
          return base;
        }
        return DIMMED_SLICE;
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

  function onDblclickClear() {
    suppressClickUntil = Date.now() + 400;
    clearSelection();
  }

  function attachSurfaceDblclick(el) {
    var surface = el.querySelector(".surface");
    if (!surface || surface.__finishDblclickBound) {
      return;
    }
    surface.__finishDblclickBound = true;
    surface.addEventListener("dblclick", function (e) {
      e.preventDefault();
      e.stopPropagation();
      onDblclickClear();
    });
  }

  function bindDblclickClear(el) {
    if (el.__finishDblclickClear) {
      return;
    }
    el.__finishDblclickClear = true;
    el.addEventListener("dblclick", onDblclickClear, true);
    el.on("plotly_afterplot", function () {
      attachSurfaceDblclick(el);
    });
    attachSurfaceDblclick(el);
  }

  function bindClick(el, kind) {
    if (typeof el.removeAllListeners === "function") {
      el.removeAllListeners("plotly_click");
      el.removeAllListeners("plotly_doubleclick");
    }

    if (!bound[el.id]) {
      bound[el.id] = true;
      bindDblclickClear(el);
    }

    el.on("plotly_doubleclick", onDblclickClear);

    el.on("plotly_click", function (event) {
      if (Date.now() < suppressClickUntil) {
        return;
      }
      if (!event || !event.points || !event.points.length) {
        return;
      }
      var label = resolveSliceLabel(el, event);
      if (!label) {
        return;
      }

      var now = Date.now();
      var prev = lastSliceClick[el.id];
      if (prev && prev.label === label && now - prev.at < 400) {
        lastSliceClick[el.id] = null;
        onDblclickClear();
        return;
      }
      lastSliceClick[el.id] = { at: now, label: label };

      var labelSet = selectedLabelsByKind[kind];
      if (labelSet.has(label)) {
        labelSet.delete(label);
      } else {
        labelSet.add(label);
      }

      if (!hasAnyDonutSelection()) {
        lastSliceClick = {};
        pushDonutFilter();
        return;
      }

      pushDonutFilter();
    });
  }

  function drawDonut(elId, kind, rows, subtitleN) {
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

    var titleN =
      subtitleN !== undefined && subtitleN !== null ? subtitleN : agg.n;

    var layout = {
      title: {
        text: titleFor(kind, titleN),
        x: 0.5,
        xanchor: "center",
      },
      showlegend: true,
      legend: { orientation: "h", y: -0.15 },
      margin: { t: 70, b: 50, l: 10, r: 10 },
    };

    var config = { displayModeBar: false, displaylogo: false, doubleClick: false };

    function afterPlot() {
      el.__sliceLabels = agg.labels.slice();
      el.__sliceKind = kind;
      bindClick(el, kind);
    }

    if (!plotted[elId]) {
      plotted[elId] = true;
      Plotly.newPlot(el, data, layout, config).then(afterPlot);
    } else {
      Plotly.react(el, data, layout, config).then(afterPlot);
    }
  }

  function redrawAll() {
    var activeCount = getActiveKeyCount();

    var countEl = document.getElementById("active-count");
    if (countEl) {
      countEl.textContent =
        "Active fights: " + activeCount.toLocaleString();
    }

    drawDonut(
      "donut-outcome",
      "outcome",
      rowsForDonut("outcome"),
      selectedLabelsByKind.outcome.size > 0 ? activeCount : null
    );
    drawDonut(
      "donut-men",
      "men",
      rowsForDonut("men"),
      selectedLabelsByKind.men.size > 0 ? activeCount : null
    );
    drawDonut(
      "donut-women",
      "women",
      rowsForDonut("women"),
      selectedLabelsByKind.women.size > 0 ? activeCount : null
    );
  }

  function initDashboard() {
    if (!loadConfig()) {
      return;
    }

    var clearBtn = document.getElementById("clear-donut-selection");
    if (clearBtn) {
      clearBtn.addEventListener("click", function (e) {
        e.preventDefault();
        clearSelection();
      });
    }

    listenHandle = new crosstalk.FilterHandle(GROUP);
    setHandle = new crosstalk.FilterHandle(GROUP);
    snapshotExternalKeys();

    crosstalk.group(GROUP).var("filter").on("change", onExternalFilterChange);

    redrawAll();
  }

  function boot() {
    function tryBoot(attempt) {
      if (
        typeof crosstalk === "undefined" ||
        typeof Plotly === "undefined" ||
        !document.getElementById("donut-outcome") ||
        !document.getElementById("fight-index")
      ) {
        if (attempt < 200) {
          setTimeout(function () {
            tryBoot(attempt + 1);
          }, 50);
        }
        return;
      }
      initDashboard();
    }

    if (document.readyState === "complete") {
      tryBoot(0);
    } else {
      window.addEventListener("load", function () {
        tryBoot(0);
      });
    }
  }

  boot();
})();
