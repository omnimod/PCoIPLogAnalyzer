<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>Charts</title>
		<link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.2.13/semantic.min.css">
		<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
		<script src="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.2.13/semantic.min.js"></script>
		<script src="https://code.highcharts.com/highcharts.js"></script>
		<script src="https://code.highcharts.com/modules/exporting.js"></script>
		<style>
			h3, p {
				font-family: "Lucida Grande", "Lucida Sans Unicode", Arial, Helvetica, sans-serif;
				font-weight: normal;
				line-height: 1;
			}
		</style>
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
					<p>Disconnect reason: ${EndReason}</p>
				</div>
				
				<div id="NetworkChart" style="height: 400px; margin: 0 auto"></div>				

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
				
				<div id="BandwidthChart" style="height: 400px; margin: 0 auto"></div>		
				
				<div class="ui left aligned container">
					<p>Average RX (KBytes/s): ${AVG.BdwthStats.AVGRX}</p>
					<p>Average TX (KBytes/s): ${AVG.BdwthStats.AVGTX}</p>			
				</div>

				<div id="LossChart" style="height: 400px; margin: 0 auto"></div>		

				<div class="ui left aligned container">
					<p>MAX RX Loss (&#37;): ${MAX.NetStats.RXLoss}</p>
					<p>AVG RX Loss (&#37;): ${AVG.NetStats.RXLoss}</p>					
					<p>MAX TX Loss (&#37;): ${MAX.NetStats.TXLoss}</p>
					<p>AVG RX Loss (&#37;): ${AVG.NetStats.TXLoss}</p>					
				</div>

				<div id="LatencyChart" style="height: 400px; margin: 0 auto"></div>	

				<div class="ui left aligned container">
					<p>Maximum latency (ms): ${MAX.LatStats.Max}</p>
					<p>Average latency (ms): ${AVG.LatStats.RTT}</p>
				</div>

				<div id="QualityChart" style="height: 400px; margin: 0 auto"></div>	

				<div class="ui left aligned container">
					<p>Maximum Quality (&#37;): ${MAX.QualityStats.Quality}</p>
					<p>Minimum Quality (&#37;): ${MIN.QualityStats.Quality}</p>
				</div>				
				
				<div id="FPSChart" style="height: 400px; margin: 0 auto"></div>	
				
				<div class="ui left aligned container">
					<p>Maximum FPS: ${MAX.QualityStats.FPS}</p>
					<p>Average FPS: ${AVG.QualityStats.FPS}</p>
					<p>Minimum FPS: ${MIN.QualityStats.FPS}</p>
				</div>				
			</div>
		</div>
		<script>
			$(function () {
				var RXTotal = Number($('#RXAudio').text()) + Number($('#RXImage').text()) + Number($('#RXOther').text());
				$('#RXTotal').text(RXTotal);

				var TXTotal = Number($('#TXAudio').text()) + Number($('#TXImage').text()) + Number($('#TXOther').text());
				$('#TXTotal').text(TXTotal);

				Highcharts.setOptions({
					chart: {
							zoomType: 'x'
						},
					subtitle: {
						text: document.ontouchstart === undefined ?
								'Click and drag in the plot area to zoom in' : 'Pinch the chart to zoom in'
					},						
					legend: {
						layout: 'vertical',
						align: 'right',
						verticalAlign: 'middle'
					},
					tooltip: {
						crosshairs: [true],
						borderColor: '#000000',
						shared: true
					},
					plotOptions: {
						line: {
							lineWidth: 0.5,
							marker: {
								enabled: false
							}
						}
					}
				});				

				var NetworkChart = new Highcharts.chart('NetworkChart', {
					title: {
						text: 'Network Statistics'
					},
					xAxis: {
						categories: [${NetStats.Date}]
					},
					yAxis: {
						title: {
							text: 'Packets'
						}
					},
					series: [{
						type: 'line',
						name: 'RX Audio',
						color: '#FF0000',
						data: [${NetStats.RXAudio}]
					},
					{
						type: 'line',
						name: 'RX Image',
						color: '#AA0000',
						data: [${NetStats.RXImage}]
					},
					{
						type: 'line',
						name: 'RX Other',
						color: '#660000',
						data: [${NetStats.RXOther}]
					},
					{
						type: 'line',
						name: 'TX Audio',
						color: '#0000FF',
						data: [${NetStats.TXAudio}]
					},
					{
						type: 'line',
						name: 'TX Image',
						color: '#0000AA',
						data: [${NetStats.TXImage}]
					},
					{
						type: 'line',
						name: 'TX Other',
						color: '#000066',
						data: [${NetStats.TXOther}]
					}]
				});	

				var BandwidthChart = new Highcharts.chart('BandwidthChart', {
					title: {
						text: 'Bandwidth Statistics'
					},
					xAxis: {
						categories: [${BdwthStats.Date}]
					},
					yAxis: {
						title: {
							text: 'KBytes/s'
						}
					},
					series: [{
						type: 'line',
						name: 'BW Limit',
						color: '#00FF00',
						data: [${BdwthStats.BWLimit}]
					},
					{
						type: 'line',
						name: 'Average RX',
						color: '#FF0000',
						data: [${BdwthStats.AVGRX}]
					},
					{
						type: 'line',
						name: 'Average TX',
						color: '#0000FF',
						data: [${BdwthStats.AVGTX}]
					}]
				});	

				var LossChart = new Highcharts.chart('LossChart', {
					title: {
						text: 'Loss Statistics'
					},
					xAxis: {
						categories: [${NetStats.Date}]
					},
					yAxis: {
						title: {
							text: '%'
						}
					},
					series: [{
						type: 'line',
						name: 'RX Loss',
						color: '#AA0000',
						data: [${NetStats.RXLoss}]
					},
					{
						type: 'line',
						name: 'TX Loss',
						color: '#0000AA',
						data: [${NetStats.TXLoss}]
					}]
				});

				var LatencyChart = new Highcharts.chart('LatencyChart', {
					title: {
						text: 'Latency Statistics'
					},
					xAxis: {
						categories: [${LatStats.Date}]
					},
					yAxis: {
						title: {
							text: 'ms'
						}
					},
					series: [{
						type: 'line',
						name: 'Maximum latency',
						color: '#AA00AA',
						data: [${LatStats.Max}]
					},
					{
						type: 'line',
						name: 'Average letency',
						color: '#FF00FF',
						data: [${LatStats.RTT}]
					}]
				});

				var QualityChart = new Highcharts.chart('QualityChart', {
					title: {
						text: 'Quality Statistics'
					},
					xAxis: {
						categories: [${QualityStats.Date}]
					},
					yAxis: {
						title: {
							text: '%'
						}
					},
					series: [{
						type: 'line',
						name: 'Quality',
						color: '#FF6600',
						data: [${QualityStats.Quality}]
					}]
				});
				
				var FPSChart = new Highcharts.chart('FPSChart', {
					title: {
						text: 'FPS Statistics'
					},
					xAxis: {
						categories: [${QualityStats.Date}]
					},
					yAxis: {
						title: {
							text: 'Frames per second'
						}
					},
					series: [{
						type: 'line',
						name: 'Quality',
						color: '#00AA00',
						data: [${QualityStats.FPS}]
					}]
				});	
			});
		</script>
	</body>
</html>