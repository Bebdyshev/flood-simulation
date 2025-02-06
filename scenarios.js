Scenarios = {
	scenarios: {},

	// Асинхронная загрузка JSON
	fetch: async function (url = "scenarios.json") {
		try {
			let response = await fetch(url);
			if (!response.ok) throw new Error("Ошибка загрузки JSON");
			this.scenarios = await response.json();
			console.log("Загруженные сценарии:", this.scenarios);
			this.list();
		} catch (error) {
			console.error("Ошибка загрузки JSON:", error);
		}
	},

	list: function () {
		var listElem = document.getElementById("scenarios");
		if (!listElem) {
			console.error("Элемент #scenarios не найден в DOM");
			return;
		}

		var template = _.template(
			'<a href="javascript:Scenarios.load(\'<%= name %>\', start)"><%= name %></a><br>'
		);

		Object.keys(this.scenarios).forEach(scenarioName => {
			console.log("Добавление сценария:", scenarioName);
			listElem.innerHTML += template({ name: scenarioName });
		});
	},

	load: function (scenarioName, callback) {
		var scenario = this.scenarios[scenarioName];

		if (!scenario) {
			console.error(`Сценарий ${scenarioName} не найден`);
			return;
		}

		document.querySelectorAll(".load").forEach(e => e.style.display = "none");
		document.querySelectorAll(".run").forEach(e => e.style.display = "block");

		document.getElementById("scenarioName").innerHTML = `${scenarioName} <br/><small>Loading:</small>`;

		var nMapsToLoad = 0;

		["terrain", "water", "frictionMap"].forEach(map => {
			var mapUrl = scenario.simulation[map];
			if (mapUrl) {
				nMapsToLoad++;
				fetch(mapUrl)
					.then(response => response.arrayBuffer())
					.then(data => mapLoaded(map, "simulation", tiffData(data)))
					.catch(error => console.error(`Ошибка загрузки ${mapUrl}:`, error));
			}
		});

		var satUrl = scenario.visualisation.satellite;
		if (satUrl) {
			nMapsToLoad++;
			fetch(satUrl)
				.then(response => response.blob())
				.then(blob => {
					var satImage = new Image();
					satImage.src = URL.createObjectURL(blob);
					satImage.onload = () => mapLoaded("satellite", "visualisation", satImage);
				})
				.catch(error => console.error(`Ошибка загрузки ${satUrl}:`, error));
		}

		function mapLoaded(name, target, data) {
			scenario[target][name] = data;
			console.log(name, "loaded");
			if (--nMapsToLoad === 0) {
				console.log(scenario);
				Simulation.init(scenario.simulation);
				Visualisation.init(Simulation, scenario.visualisation);
				document.getElementById("scenarioName").innerHTML = scenarioName;
				callback();
			}
		}
	}
};

// Ждём загрузки страницы, потом загружаем сценарии
window.onload = () => Scenarios.fetch();
