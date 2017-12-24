<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>Charts</title>
		<link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.2.13/semantic.min.css">
		<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
		<script src="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.2.13/semantic.min.js"></script>
		<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.bundle.js"></script>
		</head>
	<body>
	
		<!--General info block-->	
		<div class="ui one column stackable grid center aligned container segment">
			<div class="column">
				<h3>General Info</h3>
				<div class="ui left aligned container">
					<p>Log file: <span id="LogFileName"></span></p>
					<p>Server name: <span id="PCoIPServerName"></span></p>
					<p>Server IP address: <span id="PCoIPServerAddress"></span></p>
					<p>Client IP address: <span id="PCoIPClientAddress"></span></p>
					<p>Encryption algorythm: <span id="PCoIPSessionEncryption"></span></p>

					<p>Session start time: <span id="StardDate"></span></p>
					<p>Session end time: <span id="EndDate"></span></p>
					<p>Session duration (Seconds): <span id="PCoIPSessionDuration"></span></p>
				</div>
			</div>
		</div>
		
		<!--Bandwidth block-->	
		<div class="ui two column stackable grid center aligned container segment">
			<div class="column">
				<h4>Network Statistics</h4>
				<canvas id="NetworkChart" width="600" height="600"></canvas>
				<div class="ui left aligned container">
					<p>Total RX, Audio (KBytes): <span id="RXAudioTotal"></span></p>
					<p>Total RX, Image (KBytes): <span id="RXImageTotal"></span></p>
					<p>Total RX, Other (KBytes): <span id="RXOtherTotal"></span></p>
					<p>Total RX (KBytes): <span id="RXTotal"></span></p>
					<p>Total TX, Audio (KBytes): <span id="TXAudioTotal"></span></p>
					<p>Total TX, Image (KBytes): <span id="TXImageTotal"></span></p>
					<p>Total TX, Other (KBytes): <span id="TXOtherTotal"></span></p>
					<p>Total TX (KBytes): <span id="TXTotal"></span></p>				
				</div>	
			</div>
			<div class="column">
				<h4>Bandwidth Usage</h4>
				<canvas id="BandwidthChart" width="600" height="600"></canvas>
				<div class="ui left aligned container">
					<p>Average RX (KBytes/s): <span id="AVGRX"></span></p>
					<p>Average TX (KBytes/s): <span id="AVGTX"></span></p>			
				</div>					
			</div>
		</div>
		
		<!--Network quality block-->
		<div class="ui two column stackable grid center aligned container segment">
			<div class="column">
				<h4>Loss</h4>
				<canvas id="LossChart" width="600" height="600"></canvas>
				<div class="ui left aligned container">
					<p>MAX RX Loss (&#37;): <span id="MAXRXLoss"></span></p>
					<p>AVG RX Loss (&#37;): <span id="AVGRXLoss"></span></p>					
					<p>MAX TX Loss (&#37;): <span id="MAXTXLoss"></span></p>
					<p>AVG RX Loss (&#37;): <span id="AVGTXLoss"></span></p>					
				</div>				
			</div>
			<div class="column">
				<h4>Latency</h4>
				<canvas id="LatencyChart" width="600" height="600"></canvas>
				<div class="ui left aligned container">
					<p>Maximum latency (ms): <span id="MAXLatency"></span></p>
					<p>Average latency (ms): <span id="AVGLatency"></span></p>
				</div>

			</div>
		</div>
		
		<!--Image quality block-->
		<div class="ui two column stackable grid center aligned container segment">
			<div class="column">
				<h4>Quality</h4>
				<canvas id="QualityChart" width="600" height="600"></canvas>
				<div class="ui left aligned container">
					<p>Maximum Quality (&#37;): <span id="MAXQuality"></span></p>
					<p>Minimum Quality (&#37;): <span id="MINQuality"></span></p>
				</div>				
			</div>
			<div class="column">
				<h4>FPS</h4>
				<canvas id="FPSChart" width="600" height="600"></canvas>
				<div class="ui left aligned container">
					<p>Maximum FPS: <span id="MAXFPS"></span></p>
					<p>Average FPS: <span id="AVGFPS"></span></p>
					<p>Minimum FPS: <span id="MINFPS"></span></p>
				</div>

			</div>
		</div>
		<script>
			${Variables}		
					
			var ctx = document.getElementById("NetworkChart").getContext('2d');
			var NetworkChart = new Chart(ctx, {
				type: 'line',
				data: {
					labels: [${Networkchartlabels}],
					datasets: [
					{
						label: 'Total RX (Audio), KBytes',
						data: [${NetworkchartRXAudio}],
						borderWidth: 1,
						borderColor: '#FF0000',
						backgroundColor: 'rgba(0, 0, 0, 0.0)'
					},
					{
						label: 'Total RX (Image), KBytes',
						data: [${NetworkchartRXImage}],
						borderWidth: 1,
						borderColor: '#AA0000',
						backgroundColor: 'rgba(0, 0, 0, 0.0)'
					},
					{
						label: 'Total RX (Other), KBytes',
						data: [${NetworkchartRXOther}],
						borderWidth: 1,
						borderColor: '#660000',
						backgroundColor: 'rgba(0, 0, 0, 0.0)'
					},
					{
						label: 'Total TX (Audio), KBytes',
						data: [${NetworkchartTXAudio}],
						borderWidth: 1,
						borderColor: '#0000FF',
						backgroundColor: 'rgba(0, 0, 0, 0.0)'
					},
					{
						label: 'Total TX (Image), KBytes',
						data: [${NetworkchartTXImage}],
						borderWidth: 1,
						borderColor: '#0000AA',
						backgroundColor: 'rgba(0, 0, 0, 0.0)'
					},
					{
						label: 'Total TX (Other), KBytes',
						data: [${NetworkchartTXOther}],
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
					labels: [${Bandwidthchartlabels}],
					datasets: [
					{
						label: 'Average RX, KBytes/s',
						data: [${BandwidthchartAVGRX}],
						borderWidth: 1,
						borderColor: '#ff0000',
						backgroundColor: 'rgba(0, 0, 0, 0.0)'
					},
					{
						label: 'Average TX, KBytes/s',
						data: [${BandwidthchartAVGTX}],
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
					labels: [${Losschartlabels}],
					datasets: [
					{
						label: 'RX Loss, %',
						data: [${LosschartRXLoss}],
						borderWidth: 1,
						borderColor: '#AA0000',
						backgroundColor: 'rgba(0, 0, 0, 0.0)'
					},
					{
						label: 'TX Loss, %',
						data: [${LosschartTXLoss}],
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
					labels: [${Latencychartlabels}],
					datasets: [
					{
						label: 'Maximum latency, ms',
						data: [${LatencychartMAXLatency}],
						borderWidth: 1,
						borderColor: '#AA00AA',
						backgroundColor: 'rgba(0, 0, 0, 0.0)'
					},
					{
						label: 'Average letency, ms',
						data: [${LatencychartAVGLatency}],
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
					labels: [${Qualitychartlabels}],
					datasets: [
					{
						label: 'Quality, %',
						data: [${QualitychartQuality}],
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
					labels: [${FPSchartlabels}],
					datasets: [
					{
						label: 'FPS',
						data: [${FPSchartFPS}],
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
