/*
    UI logic of the test runner.

    A run is deliberately started spec by spec instead of in one single call:
    only this way the table fills up while the run is going and you can see
    which spec it is stuck on. A directory selection is resolved into the
    single specs beforehand via dryRun.
*/
(() => {
	const initialData = (typeof window.testRunnerInitialData === "object" && window.testRunnerInitialData !== null)
		? window.testRunnerInitialData
		: {};

	const selectionMode = document.getElementById("selectionMode");
	const labelsInput = document.getElementById("labelsInput");
	const excludesInput = document.getElementById("excludesInput");
	const recurseCheckbox = document.getElementById("recurseCheckbox");
	const directoryPanel = document.getElementById("directoryPanel");
	const bundlePanel = document.getElementById("bundlePanel");
	const directorySelect = document.getElementById("directorySelect");
	const bundleSelect = document.getElementById("bundleSelect");
	const runButton = document.getElementById("runButton");
	const clearButton = document.getElementById("clearButton");
	const statusPill = document.getElementById("statusPill");
	const currentTarget = document.getElementById("currentTarget");
	const bundleTableBody = document.getElementById("bundleTableBody");
	const rawOutput = document.getElementById("rawOutput");

	const summarySpecs = document.getElementById("summarySpecs");
	const summaryPass = document.getElementById("summaryPass");
	const summaryFail = document.getElementById("summaryFail");
	const summaryError = document.getElementById("summaryError");
	const summarySkipped = document.getElementById("summarySkipped");
	const summaryDuration = document.getElementById("summaryDuration");

	const statusClasses = ["status-idle", "status-running", "status-pass", "status-fail"];
	const runnerPath = initialData.runnerPath || window.location.pathname;
	const bundleRowByPath = {};

	let aggregateResult = createEmptyAggregateResult();
	let isRunning = false;

	function createEmptyAggregateResult() {
		return {
			totalSpecs: 0,
			totalPass: 0,
			totalFail: 0,
			totalError: 0,
			totalSkipped: 0,
			totalDuration: 0,
			bundleStats: []
		};
	}

	function setStatus(statusClass, text) {
		statusPill.classList.remove(...statusClasses);
		statusPill.classList.add(statusClass);
		statusPill.textContent = text;
	}

	function setUiLocked(locked) {
		runButton.disabled = locked;
		clearButton.disabled = locked;
		selectionMode.disabled = locked;
		labelsInput.disabled = locked;
		excludesInput.disabled = locked;
		recurseCheckbox.disabled = locked;
		directorySelect.disabled = locked;
		bundleSelect.disabled = locked;
		runButton.textContent = locked ? "Running..." : "Run selection";
	}

	function fillSelect(selectElement, values, selectedValues) {
		selectElement.innerHTML = "";

		values.forEach((value) => {
			const option = document.createElement("option");
			option.value = value;
			option.textContent = value;
			option.selected = selectedValues.includes(value);
			selectElement.appendChild(option);
		});
	}

	function getSelectedValues(selectElement) {
		return Array.from(selectElement.selectedOptions).map((option) => option.value);
	}

	function updateSelectionModeUi() {
		const mode = selectionMode.value;
		directoryPanel.classList.toggle("hidden", mode !== "directory");
		bundlePanel.classList.toggle("hidden", mode !== "bundles");
	}

	function dedupe(values) {
		return Array.from(new Set(
			(values || [])
				.filter((value) => typeof value === "string" && value.trim().length > 0)
				.map((value) => value.trim())
		));
	}

	function clearSummary() {
		summarySpecs.textContent = "0";
		summaryPass.textContent = "0";
		summaryFail.textContent = "0";
		summaryError.textContent = "0";
		summarySkipped.textContent = "0";
		summaryDuration.textContent = "0";
	}

	function updateSummary(result) {
		summarySpecs.textContent = String(result.totalSpecs || 0);
		summaryPass.textContent = String(result.totalPass || 0);
		summaryFail.textContent = String(result.totalFail || 0);
		summaryError.textContent = String(result.totalError || 0);
		summarySkipped.textContent = String(result.totalSkipped || 0);
		summaryDuration.textContent = String(result.totalDuration || 0);
	}

	function clearBundleRows() {
		bundleTableBody.innerHTML = "";
		Object.keys(bundleRowByPath).forEach((key) => delete bundleRowByPath[key]);
	}

	function renderPlaceholderRow(text) {
		clearBundleRows();
		const row = document.createElement("tr");
		const cell = document.createElement("td");
		cell.colSpan = 7;
		cell.className = "subtle";
		cell.textContent = text;
		row.appendChild(cell);
		bundleTableBody.appendChild(row);
	}

	function renderQueueRows(queue) {
		clearBundleRows();

		queue.forEach((bundlePath) => {
			const row = document.createElement("tr");
			const cells = {};

			["status", "name", "specs", "pass", "fail", "error", "duration"].forEach((key) => {
				const cell = document.createElement("td");

				if (key !== "status" && key !== "name") {
					cell.className = "numeric";
					cell.textContent = "0";
				}

				cells[key] = cell;
				row.appendChild(cell);
			});

			cells.status.textContent = "waiting";
			cells.name.textContent = bundlePath;
			bundleTableBody.appendChild(row);

			// The row with the failed expectations sits directly below the spec
			// and stays empty as long as everything is green.
			const failureRow = document.createElement("tr");
			const failureCell = document.createElement("td");
			failureRow.className = "failure-row hidden";
			failureCell.colSpan = 7;
			failureRow.appendChild(failureCell);
			bundleTableBody.appendChild(failureRow);

			bundleRowByPath[bundlePath] = {
				row: row,
				cells: cells,
				failureRow: failureRow,
				failureCell: failureCell
			};
		});
	}

	function setBundleRowState(bundlePath, state, stats) {
		const entry = bundleRowByPath[bundlePath];

		if (!entry) {
			return;
		}

		const hasFailure = (stats.totalFail || 0) > 0 || (stats.totalError || 0) > 0 || state === "failed" || state === "error";

		entry.row.classList.toggle("bundle-row-failed", hasFailure);
		entry.cells.status.textContent = state;
		entry.cells.specs.textContent = String(stats.totalSpecs || 0);
		entry.cells.pass.textContent = String(stats.totalPass || 0);
		entry.cells.fail.textContent = String(stats.totalFail || 0);
		entry.cells.error.textContent = String(stats.totalError || 0);
		entry.cells.duration.textContent = String(stats.totalDuration || 0);
	}

	function renderFailures(bundlePath, failures) {
		const entry = bundleRowByPath[bundlePath];

		if (!entry) {
			return;
		}

		entry.failureCell.innerHTML = "";

		if (!failures.length) {
			entry.failureRow.classList.add("hidden");
			return;
		}

		const list = document.createElement("ul");
		list.className = "failure-list";

		failures.forEach((failure) => {
			const item = document.createElement("li");
			const name = document.createElement("div");
			const message = document.createElement("div");

			name.className = "spec-name";
			name.textContent = failure.name;
			message.className = "spec-message";
			message.textContent = failure.message;

			item.appendChild(name);
			item.appendChild(message);

			if (failure.origin) {
				const origin = document.createElement("div");
				origin.className = "spec-origin";
				origin.textContent = failure.origin;
				item.appendChild(origin);
			}

			list.appendChild(item);
		});

		entry.failureCell.appendChild(list);
		entry.failureRow.classList.remove("hidden");
	}

	/*
		Suites can be nested (describe inside describe), so failures are collected
		recursively. The path in front shows in which block the expectation failed.
	*/
	function collectFailures(suiteStats, parentName) {
		const failures = [];

		(suiteStats || []).forEach((suite) => {
			const suiteName = parentName ? parentName + " > " + suite.name : suite.name;

			(suite.specStats || []).forEach((spec) => {
				if (spec.status === "Passed" || spec.status === "Skipped") {
					return;
				}

				failures.push({
					name: suiteName + " > " + (spec.displayName || spec.name),
					message: spec.failMessage || (spec.error && spec.error.Message) || "Failed without a message.",
					origin: describeOrigin(spec)
				});
			});

			collectFailures(suite.suiteStats, suiteName).forEach((failure) => failures.push(failure));
		});

		return failures;
	}

	// From the stack trace only the first line inside the own spec matters -
	// the lines from TestBox itself say nothing about the failure.
	function describeOrigin(spec) {
		const origins = Array.isArray(spec.failOrigin) ? spec.failOrigin : [];
		const own = origins.find((entry) => entry && typeof entry.template === "string" && entry.template.replace(/\\/g, "/").indexOf("/tests/specs/") !== -1);

		if (!own) {
			return "";
		}

		return own.template.replace(/\\/g, "/").split("/").pop() + ":" + own.line;
	}

	function appendBundleResult(bundlePath, stats, failures) {
		aggregateResult.bundleStats.push({
			path: bundlePath,
			totalSpecs: stats.totalSpecs || 0,
			totalPass: stats.totalPass || 0,
			totalFail: stats.totalFail || 0,
			totalError: stats.totalError || 0,
			totalSkipped: stats.totalSkipped || 0,
			totalDuration: stats.totalDuration || 0,
			failures: failures
		});
		aggregateResult.totalSpecs += stats.totalSpecs || 0;
		aggregateResult.totalPass += stats.totalPass || 0;
		aggregateResult.totalFail += stats.totalFail || 0;
		aggregateResult.totalError += stats.totalError || 0;
		aggregateResult.totalSkipped += stats.totalSkipped || 0;
		aggregateResult.totalDuration += stats.totalDuration || 0;

		updateSummary(aggregateResult);
		rawOutput.textContent = JSON.stringify(aggregateResult, null, 2);
	}

	async function resolveRunQueue(mode, selectedDirectories, selectedBundles, baseParams) {
		if (mode === "bundles") {
			return dedupe(selectedBundles);
		}

		const directories = dedupe(selectedDirectories);

		if (!directories.length) {
			return [];
		}

		const params = new URLSearchParams(baseParams);
		params.set("dryRun", "true");
		params.set("reporter", "json");
		params.set("directory", directories.join(","));
		params.set("bundles", "");

		try {
			const response = await fetch(runnerPath + "?" + params.toString(), { headers: { "Accept": "application/json" } });
			const payload = await response.json();
			const queue = Array.isArray(payload.bundles)
				? dedupe(payload.bundles.map((bundle) => (bundle && (bundle.path || bundle.name)) || ""))
				: [];

			return queue.length ? queue : directories;
		} catch (error) {
			return directories;
		}
	}

	async function runBundle(bundlePath, baseParams) {
		const params = new URLSearchParams(baseParams);
		params.set("reporter", "json");
		params.set("bundles", bundlePath);
		params.set("directory", "");
		params.set("dryRun", "false");

		const response = await fetch(runnerPath + "?" + params.toString(), { headers: { "Accept": "application/json" } });
		const result = await response.json();
		const bundleStats = (Array.isArray(result.bundleStats) && result.bundleStats.length)
			? result.bundleStats[0]
			: null;

		if (!bundleStats) {
			return {
				stats: { totalSpecs: 0, totalPass: 0, totalFail: 0, totalError: 1, totalSkipped: 0, totalDuration: 0 },
				failures: [{ name: bundlePath, message: "The runner did not return a result.", origin: "" }]
			};
		}

		const failures = collectFailures(bundleStats.suiteStats, "");

		// A spec that cannot even be loaded (syntax error, missing component)
		// has no suites at all - the reason is found here.
		if (bundleStats.globalException && bundleStats.globalException.message) {
			failures.push({
				name: bundlePath,
				message: bundleStats.globalException.message,
				origin: bundleStats.globalException.detail || ""
			});
		}

		return { stats: bundleStats, failures: failures };
	}

	async function runSelection() {
		if (isRunning) {
			return;
		}

		const mode = selectionMode.value;
		const selectedDirectories = getSelectedValues(directorySelect);
		const selectedBundles = getSelectedValues(bundleSelect);

		if ((mode === "directory" ? selectedDirectories : selectedBundles).length === 0) {
			window.alert("Please select at least one directory or spec.");
			return;
		}

		const params = new URLSearchParams();
		params.set("mode", "api");
		params.set("recurse", recurseCheckbox.checked ? "true" : "false");
		params.set("labels", labelsInput.value.trim());
		params.set("excludes", excludesInput.value.trim());

		isRunning = true;
		setStatus("status-running", "Running");
		setUiLocked(true);
		clearSummary();
		renderPlaceholderRow("Resolving selection...");
		rawOutput.textContent = "{}";
		currentTarget.textContent = "Current: resolving selection";
		aggregateResult = createEmptyAggregateResult();

		try {
			const queue = await resolveRunQueue(mode, selectedDirectories, selectedBundles, params);

			if (!queue.length) {
				throw new Error("No spec found for this selection.");
			}

			renderQueueRows(queue);

			for (let index = 0; index < queue.length; index += 1) {
				const bundlePath = queue[index];
				currentTarget.textContent = "Current: " + bundlePath + " (" + (index + 1) + "/" + queue.length + ")";
				setBundleRowState(bundlePath, "running", {});

				try {
					const bundleResult = await runBundle(bundlePath, params);
					const failed = (bundleResult.stats.totalFail || 0) > 0 || (bundleResult.stats.totalError || 0) > 0;

					setBundleRowState(bundlePath, failed ? "failed" : "passed", bundleResult.stats);
					renderFailures(bundlePath, bundleResult.failures);
					appendBundleResult(bundlePath, bundleResult.stats, bundleResult.failures);
				} catch (bundleError) {
					const errorStats = { totalSpecs: 0, totalPass: 0, totalFail: 0, totalError: 1, totalSkipped: 0, totalDuration: 0 };
					const failures = [{ name: bundlePath, message: bundleError.message || String(bundleError), origin: "" }];

					setBundleRowState(bundlePath, "error", errorStats);
					renderFailures(bundlePath, failures);
					appendBundleResult(bundlePath, errorStats, failures);
				}
			}

			const red = (aggregateResult.totalFail || 0) > 0 || (aggregateResult.totalError || 0) > 0;
			setStatus(red ? "status-fail" : "status-pass", red ? "Failed" : "Passed");
			currentTarget.textContent = "Current: done";
		} catch (error) {
			setStatus("status-fail", "Error");
			currentTarget.textContent = "Current: error";
			renderPlaceholderRow(error.message || String(error));
			rawOutput.textContent = JSON.stringify({ message: error.message || String(error) }, null, 2);
		} finally {
			isRunning = false;
			setUiLocked(false);
		}
	}

	function clearSelection() {
		Array.from(directorySelect.options).forEach((option) => { option.selected = false; });
		Array.from(bundleSelect.options).forEach((option) => { option.selected = false; });
		clearSummary();
		renderPlaceholderRow("No run started yet.");
		rawOutput.textContent = "{}";
		setStatus("status-idle", "Ready");
		currentTarget.textContent = "Current: nothing";
	}

	async function loadEnvironment() {
		const fields = {
			database: document.getElementById("envDatabase"),
			datasource: document.getElementById("envDatasource"),
			migrations: document.getElementById("envMigrations"),
			objects: document.getElementById("envObjects")
		};

		try {
			const response = await fetch("healthcheck.cfm", { headers: { "Accept": "application/json" } });
			const payload = await response.json();
			const migrations = payload.migrations || {};

			fields.database.textContent = payload.connectedDatabase || payload.database || "?";
			fields.datasource.textContent = payload.applicationDatasource || payload.datasource || "?";
			fields.migrations.textContent = payload.error
				? payload.error
				: String(migrations.core || 0) + " / " + String(migrations.myapp || 0);
			fields.objects.textContent = String(payload.objectsLoaded || 0);

			if (!payload.ok) {
				fields.migrations.classList.add("text-fail");
			}
		} catch (error) {
			Object.values(fields).forEach((field) => { field.textContent = "not reachable"; });
		}
	}

	fillSelect(
		directorySelect,
		Array.isArray(initialData.availableDirectories) ? initialData.availableDirectories : [],
		Array.isArray(initialData.defaultDirectories) ? initialData.defaultDirectories : []
	);
	fillSelect(
		bundleSelect,
		Array.isArray(initialData.availableBundles) ? initialData.availableBundles : [],
		Array.isArray(initialData.defaultBundles) ? initialData.defaultBundles : []
	);

	selectionMode.value = initialData.defaultSelectionMode || "directory";
	labelsInput.value = initialData.defaultLabels || "";
	excludesInput.value = initialData.defaultExcludes || "";
	recurseCheckbox.checked = initialData.defaultRecurse !== false;
	updateSelectionModeUi();

	selectionMode.addEventListener("change", updateSelectionModeUi);
	runButton.addEventListener("click", runSelection);
	clearButton.addEventListener("click", clearSelection);

	loadEnvironment();
})();
