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
  var submittedMode = false;
  var grayOutByKind = {
    men: false,
    women: false,
  };
  var titleFightsOnly = false;
  var linkingYearEvent = false;
  var eventLatestDate = {};
  var allYearsOrdered = [];
  var allEventsOrdered = [];
  var dashTheme = {
    bg: "#0B0B0D",
    surface: "#141418",
    text: "#E5E5E5",
    text_muted: "#A1A1AA",
    accent: "#C8102E",
    accent_gold: "#C9A227",
    border: "#2A2A30",
    dimmed: "#25252D",
  };
  var DIMMED_SLICE = dashTheme.dimmed;

  function loadConfig() {
    var indexEl = document.getElementById("fight-index");
    var finishEl = document.getElementById("finish-colors");
    var divisionEl = document.getElementById("division-colors");
    var themeEl = document.getElementById("dash-theme");
    if (!indexEl || !finishEl || !divisionEl) {
      return false;
    }
    fightIndex = JSON.parse(indexEl.textContent);
    finishColors = JSON.parse(finishEl.textContent);
    divisionColors = JSON.parse(divisionEl.textContent);
    if (themeEl) {
      dashTheme = JSON.parse(themeEl.textContent);
      DIMMED_SLICE = dashTheme.dimmed || DIMMED_SLICE;
    }
    buildEventDateLookup();
    allEventsOrdered = computeAllowedEvents([]);
    allYearsOrdered = computeAllowedYears([]);
    return true;
  }

  function buildEventDateLookup() {
    eventLatestDate = {};
    fightIndex.forEach(function (row) {
      if (!row.event_name || !row.fight_date) {
        return;
      }
      if (
        !eventLatestDate[row.event_name] ||
        row.fight_date > eventLatestDate[row.event_name]
      ) {
        eventLatestDate[row.event_name] = row.fight_date;
      }
    });
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

  function snapshotExternalKeys() {
    if (!listenHandle) {
      return;
    }
    applying = true;
    if (setHandle) {
      setHandle.clear();
    }
    var keys = listenHandle.filteredKeys;
    applying = false;
    if (keys !== null && keys !== undefined) {
      lastExternalKeys = keys;
    } else {
      lastExternalKeys = null;
    }
  }

  function getExternalRows() {
    return rowsFromKeys(lastExternalKeys);
  }

  function getScopedRows() {
    var rows = getExternalRows();
    if (!titleFightsOnly) {
      return rows;
    }
    return rows.filter(function (row) {
      return row.is_title_fight;
    });
  }

  function unionKeys(a, b) {
    var tmp = {};
    a.forEach(function (k) {
      tmp[k] = true;
    });
    b.forEach(function (k) {
      tmp[k] = true;
    });
    return Object.keys(tmp);
  }

  function allWomenKeys(baseRows) {
    return baseRows
      .filter(function (row) {
        return row.is_womens;
      })
      .map(function (row) {
        return row.key;
      });
  }

  function allMenKeys(baseRows) {
    return baseRows
      .filter(function (row) {
        return !row.is_womens;
      })
      .map(function (row) {
        return row.key;
      });
  }

  function divisionFilterKeys(baseRows) {
    var menKeys = keysForKind("men", baseRows);
    var womenKeys = keysForKind("women", baseRows);
    var menSel = selectedLabelsByKind.men.size > 0;
    var womenSel = selectedLabelsByKind.women.size > 0;
    var menGray = grayOutByKind.men;
    var womenGray = grayOutByKind.women;

    if (menGray && womenGray) {
      return [];
    }

    if (menGray) {
      if (womenSel) {
        return womenKeys;
      }
      return allWomenKeys(baseRows);
    }

    if (womenGray) {
      if (menSel) {
        return menKeys;
      }
      return allMenKeys(baseRows);
    }

    if (!menSel && !womenSel) {
      return null;
    }
    if (menSel && womenSel) {
      return unionKeys(menKeys, womenKeys);
    }
    if (menSel) {
      return unionKeys(menKeys, allWomenKeys(baseRows));
    }
    return unionKeys(womenKeys, allMenKeys(baseRows));
  }

  function rowsForDivisionUnion(baseRows) {
    var keys = divisionFilterKeys(baseRows);
    if (!keys) {
      return baseRows;
    }
    return rowsFromKeyList(baseRows, keys);
  }

  function menOnlyActiveCount() {
    if (grayOutByKind.men) {
      return 0;
    }
    var baseRows = getScopedRows();
    var menKeys = keysForKind("men", baseRows);
    return menKeys ? menKeys.length : 0;
  }

  function womenOnlyActiveCount() {
    if (grayOutByKind.women) {
      return 0;
    }
    var baseRows = getScopedRows();
    var womenKeys = keysForKind("women", baseRows);
    return womenKeys ? womenKeys.length : 0;
  }

  function resolveTableKeys() {
    var baseRows = getScopedRows();
    var donutKeys = hasActiveDonutFilter()
      ? donutKeysFromSelection(baseRows)
      : null;

    if (donutKeys) {
      return donutKeys;
    }
    if (titleFightsOnly) {
      return baseRows.map(function (row) {
        return row.key;
      });
    }
    return null;
  }

  function getActiveRows() {
    var keys = resolveTableKeys();
    var baseRows = getScopedRows();
    if (!keys) {
      return baseRows;
    }
    return rowsFromKeyList(baseRows, keys);
  }

  function getActiveKeyCount() {
    var keys = resolveTableKeys();
    if (keys) {
      return keys.length;
    }
    return getScopedRows().length;
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

  function hasActiveDonutFilter() {
    return (
      hasAnyDonutSelection() ||
      grayOutByKind.men ||
      grayOutByKind.women
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

  function otherKindsForDonutDisplay(kind) {
    var kinds = ["outcome", "men", "women"];
    return kinds.filter(function (k) {
      if (k === kind) {
        return false;
      }
      // Division donuts don't filter each other or outcome on the opposite gender.
      if (k === "men" && (kind === "outcome" || kind === "women")) {
        return false;
      }
      if (k === "women" && (kind === "outcome" || kind === "men")) {
        return false;
      }
      return selectedLabelsByKind[k].size > 0;
    });
  }

  function rowsForDonut(kind) {
    var baseRows = getScopedRows();

    if (
      kind === "outcome" &&
      (selectedLabelsByKind.men.size > 0 ||
        selectedLabelsByKind.women.size > 0 ||
        grayOutByKind.men ||
        grayOutByKind.women)
    ) {
      baseRows = rowsForDivisionUnion(baseRows);
    }

    var applyKinds = otherKindsForDonutDisplay(kind);
    var resultKeys = null;

    applyKinds.forEach(function (k) {
      var kindKeys = keysForKind(k, baseRows);
      if (kindKeys === null) {
        return;
      }
      resultKeys =
        resultKeys === null ? kindKeys : intersectKeyLists(resultKeys, kindKeys);
    });

    var rows = rowsFromKeyList(baseRows, resultKeys);

    return rows;
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

  function snapshotExternalKeysAndReapply() {
    var hadDonut = hasActiveDonutFilter();
    submittedMode = false;
    snapshotExternalKeys();
    if (hadDonut) {
      pushDonutFilter();
    } else {
      redrawAll();
    }
  }

  function toggleGrayOutKind(kind) {
    grayOutByKind[kind] = !grayOutByKind[kind];
    if (grayOutByKind[kind]) {
      selectedLabelsByKind[kind].clear();
    }
    lastSliceClick = {};
    submittedMode = false;
    pushDonutFilter();
  }

  function clearSelection() {
    selectedLabelsByKind.outcome.clear();
    selectedLabelsByKind.men.clear();
    selectedLabelsByKind.women.clear();
    grayOutByKind.men = false;
    grayOutByKind.women = false;
    lastSliceClick = {};
    submittedMode = false;
    pushDonutFilter();
  }

  function submitSelection() {
    if (!hasAnyDonutSelection()) {
      return;
    }
    submittedMode = true;
    redrawAll();
  }

  function updateSubmitButton() {
    var btn = document.getElementById("submit-donut-selection");
    if (!btn) {
      return;
    }
    var hasSelection = hasAnyDonutSelection();
    btn.disabled = !hasSelection || submittedMode;
    btn.textContent = submittedMode ? "Applied" : "Apply slices";
  }

  function updateClearButton() {
    var btn = document.getElementById("clear-donut-selection");
    if (!btn) {
      return;
    }
    btn.disabled = !hasActiveDonutFilter();
  }

  function finishSharePct(rows, finishType) {
    if (!rows.length) {
      return "—";
    }
    var count = rows.filter(function (row) {
      return row.finish_type === finishType;
    }).length;
    return Math.round((100 * count) / rows.length) + "%";
  }

  function finishRatePct(rows) {
    if (!rows.length) {
      return "—";
    }
    var finishes = rows.filter(function (row) {
      return (
        row.finish_type === "KO/TKO" || row.finish_type === "Submission"
      );
    }).length;
    return Math.round((100 * finishes) / rows.length);
  }

  function getDisplayedRows() {
    if (!listenHandle) {
      return getActiveRows();
    }
    var keys = listenHandle.filteredKeys;
    if (keys === null || keys === undefined) {
      return fightIndex;
    }
    return rowsFromKeys(keys);
  }

  function updateHeroStats() {
    var activeRows = getDisplayedRows();
    var activeCount = getActiveKeyCount();

    var fightsEl = document.getElementById("stat-fights");
    if (fightsEl) {
      fightsEl.textContent = activeCount.toLocaleString();
    }

    var koEl = document.getElementById("stat-ko");
    if (koEl) {
      koEl.textContent = finishSharePct(activeRows, "KO/TKO");
    }

    var subEl = document.getElementById("stat-sub");
    if (subEl) {
      subEl.textContent = finishSharePct(activeRows, "Submission");
    }

    var decEl = document.getElementById("stat-dec");
    if (decEl) {
      decEl.textContent = finishSharePct(activeRows, "Decision");
    }

    var countEl = document.getElementById("active-count");
    if (countEl) {
      countEl.textContent =
        "Active fights: " + activeCount.toLocaleString();
    }
  }

  function clearExternalFilters() {
    var yearSelectize = getSelectize("year_pick");
    var eventSelectize = getSelectize("event_name");
    if (!yearSelectize || !eventSelectize) {
      return;
    }

    linkingYearEvent = true;

    filterSelectItems(yearSelectize.items)
      .slice()
      .forEach(function (value) {
        yearSelectize.removeItem(value, true);
      });
    filterSelectItems(eventSelectize.items)
      .slice()
      .forEach(function (value) {
        eventSelectize.removeItem(value, true);
      });

    rebuildSelectizeOptions(eventSelectize, allEventsOrdered);
    rebuildSelectizeOptions(yearSelectize, allYearsOrdered);

    linkingYearEvent = false;
    titleFightsOnly = false;
    updateTitleToggle();
    yearSelectize.trigger("change");
  }

  function updateGenderToggles() {
    ["men", "women"].forEach(function (kind) {
      var btn = document.getElementById("toggle-" + kind);
      if (!btn) {
        return;
      }
      var on = !grayOutByKind[kind];
      btn.textContent = kind === "men" ? "Men" : "Women";
      btn.setAttribute("aria-pressed", on ? "true" : "false");
      if (on) {
        btn.classList.add("is-on");
      } else {
        btn.classList.remove("is-on");
      }
    });
  }

  function updateTitleToggle() {
    var btn = document.getElementById("toggle-title-fights");
    if (!btn) {
      return;
    }
    btn.setAttribute("aria-pressed", titleFightsOnly ? "true" : "false");
    if (titleFightsOnly) {
      btn.classList.add("is-on");
    } else {
      btn.classList.remove("is-on");
    }
  }

  function toggleTitleFights() {
    titleFightsOnly = !titleFightsOnly;
    submittedMode = false;
    updateTitleToggle();
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

  function donutKeysFromSelection(baseRows) {
    if (!hasActiveDonutFilter()) {
      return null;
    }
    var resultKeys = null;

    var outcomeKeys = keysForKind("outcome", baseRows);
    if (outcomeKeys !== null) {
      resultKeys = outcomeKeys;
    }

    var divisionKeys = divisionFilterKeys(baseRows);
    if (divisionKeys !== null) {
      resultKeys =
        resultKeys === null
          ? divisionKeys
          : intersectKeyLists(resultKeys, divisionKeys);
    }

    return resultKeys;
  }

  function pushDonutFilter() {
    if (!setHandle) {
      redrawAll();
      return;
    }

    var keys = resolveTableKeys();

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
    submittedMode = false;
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
    var showSubmitted = submittedMode && hasSelection;
    var grayedOut = grayOutByKind[kind];

    if (showSubmitted) {
      order = order.filter(function (k) {
        return selected.has(k);
      });
    }

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
        if (grayedOut) {
          return DIMMED_SLICE;
        }
        if (showSubmitted || !hasSelection || selected.has(k)) {
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
      if (submittedMode) {
        submittedMode = false;
      }
      if (grayOutByKind[kind]) {
        grayOutByKind[kind] = false;
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

  function ensureWomenVisible() {
    var womenWrap = document.getElementById("donut-women-wrap");
    if (womenWrap) {
      womenWrap.style.display = "";
    }
  }

  function drawDonut(elId, kind, rows, subtitleN) {
    var el = document.getElementById(elId);
    if (!el || typeof Plotly === "undefined") {
      return;
    }

    var agg = aggregate(rows, kind);
    var pieTrace = {
      labels: agg.labels,
      values: agg.values,
      type: "pie",
      hole: 0.45,
      textinfo: "label+percent",
      textposition: "outside",
      sort: false,
      marker: {
        colors: agg.colors,
        line: { color: dashTheme.bg || "#1A1A1E", width: 2 },
      },
      textfont: { color: dashTheme.text || "#E5E5E5" },
      hovertemplate: "<b>%{label}</b><br>%{percent}<extra></extra>",
    };

    if (kind !== "outcome") {
      // Rotate the pie so the first division slice (Flyweight) is not clipped
      // at 12 o'clock; +15° keeps top slice labels off the fight-count subtitle.
      pieTrace.rotation = 105;
      pieTrace.insidetextorientation = "horizontal";
    }

    var data = [pieTrace];

    var titleN =
      subtitleN !== undefined && subtitleN !== null ? subtitleN : agg.n;

    var annotations = [];
    if (kind === "outcome" && agg.n > 0) {
      var kpiText;
      if (selectedLabelsByKind.outcome.size > 0) {
        kpiText =
          getActiveKeyCount().toLocaleString() +
          "<br><sup>selected</sup>";
      } else {
        kpiText =
          finishRatePct(rows) +
          "%<br><sup>finishes</sup>";
      }
      annotations.push({
        text: kpiText,
        showarrow: false,
        font: {
          size: 20,
          color: dashTheme.text || "#E5E5E5",
          family: "Barlow Condensed, sans-serif",
        },
        x: 0.5,
        y: 0.5,
      });
    }

    var layout = {
      paper_bgcolor: "rgba(0,0,0,0)",
      plot_bgcolor: "rgba(0,0,0,0)",
      font: {
        color: dashTheme.text || "#E5E5E5",
        family: "Barlow Condensed, sans-serif",
      },
      title: {
        text: titleFor(kind, titleN),
        x: 0.5,
        xanchor: "center",
        font: { size: 16, color: "#F5F5F5" },
      },
      showlegend: true,
      legend: {
        orientation: "h",
        y: kind === "outcome" ? -0.15 : -0.22,
        font: {
          color: dashTheme.text_muted || "#A1A1AA",
          size: kind === "outcome" ? 12 : 11,
        },
        bgcolor: "rgba(0,0,0,0)",
      },
      margin:
        kind === "outcome"
          ? { t: 70, b: 50, l: 10, r: 10 }
          : { t: 80, b: 110, l: 60, r: 60 },
      annotations: annotations,
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
    ensureWomenVisible();
    var menSelected =
      selectedLabelsByKind.men.size > 0 || grayOutByKind.men;
    var womenSelected =
      selectedLabelsByKind.women.size > 0 || grayOutByKind.women;

    updateHeroStats();

    drawDonut(
      "donut-outcome",
      "outcome",
      rowsForDonut("outcome"),
      selectedLabelsByKind.outcome.size > 0 ? getActiveKeyCount() : null
    );
    drawDonut(
      "donut-men",
      "men",
      rowsForDonut("men"),
      menSelected ? menOnlyActiveCount() : null
    );
    drawDonut(
      "donut-women",
      "women",
      rowsForDonut("women"),
      womenSelected ? womenOnlyActiveCount() : null
    );
    updateSubmitButton();
    updateClearButton();
    updateGenderToggles();
    updateTitleToggle();
  }

  function refreshExternalBaseline(retry) {
    snapshotExternalKeysAndReapply();
    if (retry < 40) {
      setTimeout(function () {
        var prevLen = lastExternalKeys ? lastExternalKeys.length : fightIndex.length;
        snapshotExternalKeys();
        var newLen = lastExternalKeys ? lastExternalKeys.length : fightIndex.length;
        if (hasActiveDonutFilter()) {
          pushDonutFilter();
        } else {
          redrawAll();
        }
        if (
          (listenHandle.filteredKeys === null ||
            listenHandle.filteredKeys === undefined) &&
          retry < 20
        ) {
          refreshExternalBaseline(retry + 1);
        } else if (newLen !== prevLen && retry < 40) {
          refreshExternalBaseline(retry + 1);
        }
      }, 100);
    }
  }

  function sortEventChipsDesc(container) {
    var input = container.querySelector(".selectize-input");
    if (!input) {
      return;
    }
    var control = input.querySelector("input");
    if (!control) {
      return;
    }
    var items = Array.prototype.slice.call(input.querySelectorAll(".item"));
    if (items.length < 2) {
      return;
    }
    items.sort(function (a, b) {
      var dateA = eventLatestDate[a.getAttribute("data-value")] || "";
      var dateB = eventLatestDate[b.getAttribute("data-value")] || "";
      return dateB.localeCompare(dateA);
    });
    items.forEach(function (item) {
      input.insertBefore(item, control);
    });
  }

  function sortYearChipsDesc(container) {
    var input = container.querySelector(".selectize-input");
    if (!input) {
      return;
    }
    var control = input.querySelector("input");
    if (!control) {
      return;
    }
    var items = Array.prototype.slice.call(input.querySelectorAll(".item"));
    if (items.length < 2) {
      return;
    }
    items.sort(function (a, b) {
      return (
        Number(b.getAttribute("data-value")) -
        Number(a.getAttribute("data-value"))
      );
    });
    items.forEach(function (item) {
      input.insertBefore(item, control);
    });
  }

  function filterSelectItems(items) {
    return items.filter(function (value) {
      return value !== "";
    });
  }

  function getSelectize(id) {
    var container = document.getElementById(id);
    if (!container) {
      return null;
    }
    var select = container.querySelector("select");
    if (!select || !select.selectize) {
      return null;
    }
    return select.selectize;
  }

  function stripAllOption(selectize) {
    if (!selectize) {
      return;
    }
    if (selectize.items.indexOf("") >= 0) {
      selectize.removeItem("", true);
    }
    if (selectize.options[""]) {
      selectize.removeOption("");
    }
  }

  function computeAllowedEvents(selectedYears) {
    var latestDate = {};
    fightIndex.forEach(function (row) {
      if (
        selectedYears.length > 0 &&
        selectedYears.indexOf(String(row.year)) < 0
      ) {
        return;
      }
      if (
        !latestDate[row.event_name] ||
        row.fight_date > latestDate[row.event_name]
      ) {
        latestDate[row.event_name] = row.fight_date;
      }
    });
    return Object.keys(latestDate).sort(function (a, b) {
      return latestDate[b].localeCompare(latestDate[a]) || a.localeCompare(b);
    });
  }

  function computeAllowedYears(selectedEvents) {
    var years = {};
    fightIndex.forEach(function (row) {
      if (
        selectedEvents.length > 0 &&
        selectedEvents.indexOf(row.event_name) < 0
      ) {
        return;
      }
      years[row.year] = true;
    });
    return Object.keys(years).sort(function (a, b) {
      return Number(b) - Number(a);
    });
  }

  function applySelectizeOptionOrder(selectize, orderedValues) {
    if (!selectize || !orderedValues) {
      return;
    }

    var order = orderedValues.filter(function (value) {
      return Object.prototype.hasOwnProperty.call(selectize.options, value);
    });
    var wasOpen = selectize.isOpen;
    selectize.order = order;
    if (typeof selectize.refreshOptions === "function") {
      selectize.refreshOptions(false);
    }
    if (!wasOpen) {
      selectize.close();
    }
  }

  function needsOptionRebuild(selectize, orderedValues) {
    for (var i = 0; i < orderedValues.length; i++) {
      if (!selectize.options[orderedValues[i]]) {
        return true;
      }
    }
    return false;
  }

  function updateSelectizeOptions(selectize, orderedValues) {
    if (!selectize) {
      return;
    }
    if (needsOptionRebuild(selectize, orderedValues)) {
      rebuildSelectizeOptions(selectize, orderedValues);
    } else {
      refreshSelectizeOptions(selectize, orderedValues);
    }
  }

  function refreshSelectizeOptions(selectize, allowedValues) {
    if (!selectize) {
      return;
    }

    var allowedSet = {};
    allowedValues.forEach(function (value) {
      allowedSet[value] = true;
    });

    var removedSelection = false;
    filterSelectItems(selectize.items)
      .slice()
      .forEach(function (value) {
        if (!allowedSet[value]) {
          selectize.removeItem(value, true);
          removedSelection = true;
        }
      });

    Object.keys(selectize.options).forEach(function (key) {
      if (key === "" || !allowedSet[key]) {
        selectize.removeOption(key);
      }
    });

    allowedValues.forEach(function (value) {
      if (!selectize.options[value]) {
        selectize.addOption({ value: value, label: value });
      }
    });

    applySelectizeOptionOrder(selectize, allowedValues);

    if (removedSelection) {
      selectize.trigger("change");
    }
  }

  function rebuildSelectizeOptions(selectize, orderedValues) {
    if (!selectize) {
      return;
    }

    var allowedSet = {};
    orderedValues.forEach(function (value) {
      allowedSet[value] = true;
    });

    var selected = filterSelectItems(selectize.items).filter(function (value) {
      return allowedSet[value];
    });

    selectize.close();

    Object.keys(selectize.options).slice().forEach(function (key) {
      if (key !== "") {
        selectize.removeOption(key);
      }
    });
    stripAllOption(selectize);

    orderedValues.forEach(function (value) {
      selectize.addOption({ value: value, label: value });
    });

    applySelectizeOptionOrder(selectize, orderedValues);

    selected.forEach(function (value) {
      if (selectize.items.indexOf(value) < 0) {
        selectize.addItem(value, true);
      }
    });
  }

  function syncYearEventFilters() {
    if (linkingYearEvent) {
      return;
    }

    var yearSelectize = getSelectize("year_pick");
    var eventSelectize = getSelectize("event_name");
    if (!yearSelectize || !eventSelectize) {
      return;
    }

    linkingYearEvent = true;

    stripAllOption(yearSelectize);
    stripAllOption(eventSelectize);

    var selectedYears = filterSelectItems(yearSelectize.items).map(String);
    var selectedEvents = filterSelectItems(eventSelectize.items);
    var allowedEvents =
      selectedYears.length === 0
        ? allEventsOrdered
        : computeAllowedEvents(selectedYears);
    var allowedYears =
      selectedEvents.length === 0
        ? allYearsOrdered
        : computeAllowedYears(selectedEvents);

    updateSelectizeOptions(eventSelectize, allowedEvents);
    updateSelectizeOptions(yearSelectize, allowedYears);

    stripAllOption(yearSelectize);
    stripAllOption(eventSelectize);
    sortYearChipsDesc(document.getElementById("year_pick"));
    sortEventChipsDesc(document.getElementById("event_name"));

    linkingYearEvent = false;
  }

  function bindChipClickRemove(container, selectize) {
    var input = container.querySelector(".selectize-input");
    if (!input || container.__chipClickBound) {
      return;
    }
    container.__chipClickBound = true;
    input.addEventListener(
      "mousedown",
      function (e) {
        var item = e.target.closest(".item");
        if (!item || !input.contains(item)) {
          return;
        }
        if (e.target.closest(".remove")) {
          return;
        }
        e.preventDefault();
        e.stopPropagation();
        var value = item.getAttribute("data-value");
        if (!value) {
          return;
        }
        selectize.removeItem(value);
        selectize.close();
      },
      true
    );
  }

  function initSelectizeFilters(retry) {
    if (document.body.__selectizeFiltersBound) {
      return;
    }

    var yearContainer = document.getElementById("year_pick");
    var eventContainer = document.getElementById("event_name");
    if (!yearContainer || !eventContainer) {
      return;
    }

    var yearSelectize = getSelectize("year_pick");
    var eventSelectize = getSelectize("event_name");
    if (!yearSelectize || !eventSelectize) {
      if (retry < 100) {
        setTimeout(function () {
          initSelectizeFilters(retry + 1);
        }, 50);
      }
      return;
    }

    document.body.__selectizeFiltersBound = true;

    stripAllOption(yearSelectize);
    stripAllOption(eventSelectize);

    allEventsOrdered = computeAllowedEvents([]);
    allYearsOrdered = computeAllowedYears([]);

    yearSelectize.on("change", syncYearEventFilters);
    eventSelectize.on("change", syncYearEventFilters);
    syncYearEventFilters();

    yearSelectize.on("dropdown_open", function () {
      var selectedEvents = filterSelectItems(eventSelectize.items);
      applySelectizeOptionOrder(
        yearSelectize,
        selectedEvents.length === 0
          ? allYearsOrdered
          : computeAllowedYears(selectedEvents)
      );
    });
    eventSelectize.on("dropdown_open", function () {
      var selectedYears = filterSelectItems(yearSelectize.items).map(String);
      applySelectizeOptionOrder(
        eventSelectize,
        selectedYears.length === 0
          ? allEventsOrdered
          : computeAllowedEvents(selectedYears)
      );
    });

    yearSelectize.on("change", function () {
      sortYearChipsDesc(yearContainer);
    });
    eventSelectize.on("change", function () {
      sortEventChipsDesc(eventContainer);
    });

    bindChipClickRemove(yearContainer, yearSelectize);
    bindChipClickRemove(eventContainer, eventSelectize);
  }

  function initYearChipClick(retry) {
    initSelectizeFilters(retry);
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

    var submitBtn = document.getElementById("submit-donut-selection");
    if (submitBtn) {
      submitBtn.addEventListener("click", function (e) {
        e.preventDefault();
        submitSelection();
      });
    }

    var menToggle = document.getElementById("toggle-men");
    if (menToggle) {
      menToggle.addEventListener("click", function (e) {
        e.preventDefault();
        toggleGrayOutKind("men");
      });
    }

    var womenToggle = document.getElementById("toggle-women");
    if (womenToggle) {
      womenToggle.addEventListener("click", function (e) {
        e.preventDefault();
        toggleGrayOutKind("women");
      });
    }

    var titleToggle = document.getElementById("toggle-title-fights");
    if (titleToggle) {
      titleToggle.addEventListener("click", function (e) {
        e.preventDefault();
        toggleTitleFights();
      });
    }

    var clearFiltersBtn = document.getElementById("clear-external-filters");
    if (clearFiltersBtn) {
      clearFiltersBtn.addEventListener("click", function (e) {
        e.preventDefault();
        clearExternalFilters();
      });
    }

    listenHandle = new crosstalk.FilterHandle(GROUP);
    setHandle = new crosstalk.FilterHandle(GROUP);

    crosstalk.group(GROUP).var("filter").on("change", onExternalFilterChange);

    refreshExternalBaseline(0);
    initYearChipClick(0);
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
