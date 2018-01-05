<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>Charts</title>
		<link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.2.13/semantic.min.css">
		<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
		<script src="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.2.13/semantic.min.js"></script>
		<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.min.js"></script>
		</head>
	<body>
		<!--General info block-->	
		<div class="ui one column stackable grid center aligned container segment">
			<div class="column">
				<h3>General Info</h3>
				<div class="ui left aligned container">
					<p>Log file: ${LogFile}</p>
					<p>Server name: ${Server.Name}</p>
					<p>Server IP address: ${Server.IP}</p>
					<p>Client IP address: ${Client.IP}</p>
					<p>PCoIP software version: ${Version.Full}</p>
					<p>Encryption algorythm: ${Encryption}</p>
					<p>Session start time: ${StartTime}</p>
					<p>Session end time: ${EndTime}</p>
					<p>Session duration: ${Duration}</p>
				</div>
			</div>
		</div>

		<!--Network block-->	
		<div class="ui two column stackable grid center aligned container segment">
			<div class="column">
				<h4>Network Statistics</h4>
				<canvas id="NetworkChart" width="600" height="600"></canvas>
				<div class="ui left aligned container">
					<p>RX Audio (Packets): <span id="RXAudio">${LAST.NetStats.RXAudio}</span></p>
					<p>RX Image (Packets): <span id="RXImage">${LAST.NetStats.RXImage}</span></p>
					<p>RX Other (Packets): <span id="RXOther">${LAST.NetStats.RXOther}</span></p>
					<p>Total RX (Packets): <span id="RXTotal"></span></p>
					<p>TX Audio (Packets): <span id="TXAudio">${LAST.NetStats.TXAudio}</span></p>
					<p>TX Image (Packets): <span id="TXImage">${LAST.NetStats.TXImage}</span></p>
					<p>TX Other (Packets): <span id="TXOther">${LAST.NetStats.TXOther}</span></p>
					<p>Total TX (Packets): <span id="TXTotal"></span></p>				
				</div>	
			</div>
			<div class="column">
				<h4>Bandwidth Usage</h4>
				<canvas id="BandwidthChart" width="600" height="600"></canvas>
				<div class="ui left aligned container">
					<p>Average RX (KBytes/s): ${AVG.BdwthStats.AVGRX}</p>
					<p>Average TX (KBytes/s): ${AVG.BdwthStats.AVGTX}</p>			
				</div>					
			</div>
		</div>

		<!--Network quality block-->
		<div class="ui two column stackable grid center aligned container segment">
			<div class="column">
				<h4>Loss</h4>
				<canvas id="LossChart" width="600" height="600"></canvas>
				<div class="ui left aligned container">
					<p>MAX RX Loss (&#37;): ${MAX.NetStats.RXLoss}</p>
					<p>AVG RX Loss (&#37;): ${AVG.NetStats.RXLoss}</p>					
					<p>MAX TX Loss (&#37;): ${MAX.NetStats.TXLoss}</p>
					<p>AVG RX Loss (&#37;): ${AVG.NetStats.TXLoss}</p>					
				</div>				
			</div>
			<div class="column">
				<h4>Latency</h4>
				<canvas id="LatencyChart" width="600" height="600"></canvas>
				<div class="ui left aligned container">
					<p>Maximum latency (ms): ${MAX.LatStats.Max}</p>
					<p>Average latency (ms): ${AVG.LatStats.RTT}</p>
				</div>
			</div>
		</div>

		<!--Image quality block-->
		<div class="ui two column stackable grid center aligned container segment">
			<div class="column">
				<h4>Quality</h4>
				<canvas id="QualityChart" width="600" height="600"></canvas>
				<div class="ui left aligned container">
					<p>Maximum Quality (&#37;): ${MAX.QualityStats.Quality}</p>
					<p>Minimum Quality (&#37;): ${MIN.QualityStats.Quality}</p>
				</div>				
			</div>
			<div class="column">
				<h4>FPS</h4>
				<canvas id="FPSChart" width="600" height="600"></canvas>
				<div class="ui left aligned container">
					<p>Maximum FPS: ${MAX.QualityStats.FPS}</p>
					<p>Average FPS: ${AVG.QualityStats.FPS}</p>
					<p>Minimum FPS: ${MIN.QualityStats.FPS}</p>
				</div>
			</div>
		</div>
		<script>
			var RXTotal = Number($('#RXAudio').text()) + Number($('#RXImage').text()) + Number($('#RXOther').text());
			$('#RXTotal').text(RXTotal);

			var TXTotal = Number($('#TXAudio').text()) + Number($('#TXImage').text()) + Number($('#TXOther').text());
			$('#TXTotal').text(TXTotal);

			var ctx = document.getElementById("NetworkChart").getContext('2d');
			var NetworkChart = new Chart(ctx, {
				type: 'line',
				data: {
					labels: [${NetStats.Date}],
					datasets: [
					{
						label: 'Total RX (Audio), Packets',
						data: [${NetStats.RXAudio}],
						borderWidth: 1,
						borderColor: '#FF0000',
						backgroundColor: 'rgba(0, 0, 0, 0.0)'
					},
					{
						label: 'Total RX (Image), Packets',
						data: [${NetStats.RXImage}],
						borderWidth: 1,
						borderColor: '#AA0000',
						backgroundColor: 'rgba(0, 0, 0, 0.0)'
					},
					{
						label: 'Total RX (Other), Packets',
						data: [${NetStats.RXOther}],
						borderWidth: 1,
						borderColor: '#660000',
						backgroundColor: 'rgba(0, 0, 0, 0.0)'
					},
					{
						label: 'Total TX (Audio), Packets',
						data: [${NetStats.TXAudio}],
						borderWidth: 1,
						borderColor: '#0000FF',
						backgroundColor: 'rgba(0, 0, 0, 0.0)'
					},
					{
						label: 'Total TX (Image), Packets',
						data: [${NetStats.TXImage}],
						borderWidth: 1,
						borderColor: '#0000AA',
						backgroundColor: 'rgba(0, 0, 0, 0.0)'
					},
					{
						label: 'Total TX (Other), Packets',
						data: [${NetStats.TXOther}],
						borderWidth: 1,
						borderColor: '#000066',
						backgroundColor: 'rgba(0, 0, 0, 0.0)'
					}
					]
				},
				options: {
				elements: {
					line: {
						tension: 0
					}
				},
					scales: {
						yAxes: [{
							ticks: {
								beginAtZero:true
							}
						}]
					}
				}
			});			

			var ctx = document.getElementById("BandwidthChart").getContext('2d');
			var BandwidthChart = new Chart(ctx, {
				type: 'line',
				data: {
					labels: [${BdwthStats.Date}],
					datasets: [
					{
						label: 'BW Limit, KBytes/s',
						data: [${BdwthStats.BWLimit}],
						borderWidth: 1,
						borderColor: '#00ff00',
						backgroundColor: 'rgba(0, 0, 0, 0.0)'
					},
					{
						label: 'Average RX, KBytes/s',
						data: [${BdwthStats.AVGRX}],
						borderWidth: 1,
						borderColor: '#ff0000',
						backgroundColor: 'rgba(0, 0, 0, 0.0)'
					},
					{
						label: 'Average TX, KBytes/s',
						data: [${BdwthStats.AVGTX}],
						borderWidth: 1,
						borderColor: '#0000ff',
						backgroundColor: 'rgba(0, 0, 0, 0.0)'
					}
					]
				},
				options: {
				elements: {
					line: {
						tension: 0
					}
				},
					scales: {
						yAxes: [{
							ticks: {
								beginAtZero:true
							}
						}]
					}
				}
			});		

			var ctx = document.getElementById("LossChart").getContext('2d');
			var LossChart = new Chart(ctx, {
				type: 'line',
				data: {
					labels: [${NetStats.Date}],
					datasets: [
					{
						label: 'RX Loss, %',
						data: [${NetStats.RXLoss}],
						borderWidth: 1,
						borderColor: '#AA0000',
						backgroundColor: 'rgba(0, 0, 0, 0.0)'
					},
					{
						label: 'TX Loss, %',
						data: [${NetStats.TXLoss}],
						borderWidth: 1,
						borderColor: '#0000AA',
						backgroundColor: 'rgba(0, 0, 0, 0.0)'
					}
					]
				},
				options: {
				elements: {
					line: {
						tension: 0
					}
				},
					scales: {
						yAxes: [{
							ticks: {
								beginAtZero:true
							}
						}]
					}
				}
			});

			var ctx = document.getElementById("LatencyChart").getContext('2d');
			var LatencyChart = new Chart(ctx, {
				type: 'line',
				data: {
					labels: [${LatStats.Date}],
					datasets: [
					{
						label: 'Maximum latency, ms',
						data: [${LatStats.Max}],
						borderWidth: 1,
						borderColor: '#AA00AA',
						backgroundColor: 'rgba(0, 0, 0, 0.0)'
					},
					{
						label: 'Average letency, ms',
						data: [${LatStats.RTT}],
						borderWidth: 1,
						borderColor: '#FF00FF',
						backgroundColor: 'rgba(0, 0, 0, 0.0)'
					}
					]
				},
				options: {
				elements: {
					line: {
						tension: 0
					}
				},
					scales: {
						yAxes: [{
							ticks: {
								beginAtZero:true
							}
						}]
					}
				}
			});

			var ctx = document.getElementById("QualityChart").getContext('2d');
			var QualityChart = new Chart(ctx, {
				type: 'line',
				data: {
					labels: [${QualityStats.Date}],
					datasets: [
					{
						label: 'Quality, %',
						data: [${QualityStats.Quality}],
						borderWidth: 1,
						borderColor: '#FF6600',
						backgroundColor: 'rgba(0, 0, 170, 0.0)'
					}
					]
				},
				options: {
				elements: {
					line: {
						tension: 0
					}
				},
					scales: {
						yAxes: [{
							ticks: {
								suggestedMax: 100,
								beginAtZero:true
							}
						}]
					}
				}
			});

			var ctx = document.getElementById("FPSChart").getContext('2d');
			var FPSChart = new Chart(ctx, {
				type: 'line',
				data: {
					labels: [${QualityStats.Date}],
					datasets: [
					{
						label: 'FPS',
						data: [${QualityStats.FPS}],
						borderWidth: 1,
						borderColor: '#00aa00',
						backgroundColor: 'rgba(0, 170, 0, 0.0)'
					}
					]
				},
				options: {
				elements: {
					line: {
						tension: 0
					}
				},
					scales: {
						yAxes: [{
							ticks: {
								beginAtZero:true
							}
						}]
					}
				}
			});
		</script>			
	</body>
</html>