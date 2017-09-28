<!-- This page is used to visualize results of a selected modelling case. 
  
 -->

<!DOCTYPE html>
<html>
<body>
	<script type="text/javascript"
		src="http://echarts.baidu.com/gallery/vendors/echarts/echarts-all-3.js"></script>
	<script type="text/javascript"
		src="http://echarts.baidu.com/gallery/vendors/echarts/extension/dataTool.min.js"></script>
	<script type="text/javascript"
		src="http://echarts.baidu.com/gallery/vendors/echarts/map/js/china.js"></script>
	<script type="text/javascript"
		src="http://echarts.baidu.com/gallery/vendors/echarts/map/js/world.js"></script>
	<script type="text/javascript"
		src="http://api.map.baidu.com/api?v=2.0&ak=ZUONbpqGBsYGXNIYHicvbAbM"></script>
	<script type="text/javascript"
		src="http://echarts.baidu.com/gallery/vendors/echarts/extension/bmap.min.js"></script>
	<h3>
		Click to <a
			href="ResultsVisual.php?Aid=<?php echo $_GET['Aid'];?>&Cid=<?php echo $_GET['Cid']; if(isset($_GET['Cid2'])) echo '&Cid2='.$_GET['Cid2']?>&View=1"><b>View
				Crop Production</b></a> , <a
			href="ResultsVisual.php?Aid=<?php echo $_GET['Aid'];?>&Cid=<?php echo $_GET['Cid']; if(isset($_GET['Cid2'])) echo '&Cid2='.$_GET['Cid2']?>&View=2"><b>View
				Hydropower Generation</b></a> Or <a
			href="ResultsVisual.php?Aid=<?php echo $_GET['Aid'];?>&Cid=<?php echo $_GET['Cid']; if(isset($_GET['Cid2'])) echo '&Cid2='.$_GET['Cid2']?>&View=3"><b>View
				Eco-Services and Health</b></a>
	</h3>

	<h1>
<?php
if (isset ( $_GET ['View'] ) && $_GET ['View'] == 1) {
	echo "Crop Production";
} elseif ((isset ( $_GET ['View'] ) && $_GET ['View'] == 3)) {
	echo "Eco-Services & Health";
	$base = 1;
} else {
	echo 'Hydropower Generation';
}
?>
</h1>
	<div id="main" style="width: 800px; height: 600px;"></div>
	<script type="text/javascript">
        var myChart = echarts.init(document.getElementById('main'));
        <?php
								$aid = $_GET ['Aid'];
								if (isset ( $_GET ['View'] ) && $_GET ['View'] == 1) {
									$file = './Case/'.$_GET ['Cid']."/crop_summary.csv";
									$title = "Crop Production";
									$subadd = 'Agent' . $_GET ['Aid'] .' Case' . $_GET['Cid'];
									$ST = 'Agent' . $_GET ['Aid'];
								} elseif (isset ( $_GET ['View'] ) && $_GET ['View'] == 3) {
									$file = './Case/'.$_GET ['Cid']."/eco_summary.csv";
									$title = "Eco-services & Health";
									$subadd = 'Agent' . $_GET ['Aid'] .' Case' . $_GET['Cid'];
									$ST = 'Agent' . $_GET ['Aid'];
								} else {
									$file = './Case/'.$_GET ['Cid']."/hydropower_summary.csv";
									$title = "Hydropower Generation";
									$subadd = 'Agent' . $_GET ['Aid'] .' Case' . $_GET['Cid'] ;
									$ST = 'Agent' . $_GET ['Aid'];
								}
								$myfile = fopen ( $file, "r" ) or die ( "Unable to open file!" );
								fgets ( $myfile );
								$flag0 = 0;
								while ( ! feof ( $myfile ) ) {
									$currentline = fgets ( $myfile );
									$currentinfor = explode ( ',', $currentline );
									$year = intval ( $currentinfor [0+$base] );
									$agentid = intval ( $currentinfor [1+$base] );
									$subid = trim( $currentinfor [2+$base]) ;
									$data = $currentinfor [3+$base];
									if ($agentid == $aid) {
										$flag0 = 1;
										if (count ( $times ) == 0) {
											$label = array (
													$subid 
											);
											$oneseries = array (
													$data 
											);
											$timeseries = array (
													$year 
											);
											$datas = array (
													$oneseries 
											);
											$times = array (
													$timeseries 
											);
										} else {
											$flag = - 1;
											for($i = 0; $i < count ( $label ); $i ++) {
												if (strcmp($label [$i], $subid)==0) {
													$flag = $i;
												}
										
											}
											if ($flag == - 1) {
												array_push ( $label, $subid );
												$oneseries = array (
														$data 
												);
												$timeseries = array (
														$year 
												);
												array_push ( $datas, $oneseries );
												array_push ( $times, $timeseries );
											} else {
												array_push ( $datas [$flag], $data );
												array_push ( $times [$flag], $year );
											}
										}
									}
								}
								$datasum = $datas[0];
								for ($i = 1; $i<count($label);$i++){
									for ($j = 0; $j<count($datasum);$j++)
									{
										$datasum[$j] = $datasum[$j]+$datas[$i][$j];
									}
								}
								fclose ( $myfile );
								if (isset ( $_GET ['Cid2'] )) {
									if (isset ( $_GET ['View'] ) && $_GET ['View'] == 1) {
										$file2 = './Case/'.$_GET ['Cid2']."/crop_summary.csv";
										$title2 = "Crop Production";
										$subadd2 = 'Agent' . $_GET ['Aid'] .' Case' . $_GET['Cid2'] ;
										$ST2 = 'Agent' . $_GET ['Aid'] .' Case' . $_GET['Cid2'];
									} elseif (isset ( $_GET ['View'] ) && $_GET ['View'] == 3) {
										$file2 ='./Case/'.$_GET ['Cid2']."/eco_summary.csv";
										$title2 = "Eco-services & Health";
										$subadd2 = 'Agent' . $_GET ['Aid'] .' Case' . $_GET['Cid2'];
										$ST2 = 'Agent' . $_GET ['Aid'] .' Case' . $_GET['Cid2'];
									} else {
										$file2 = './Case/'.$_GET ['Cid2']."/hydropower_summary.csv";
										$title2 = "Hydropower Generation";
										$subadd2 = 'Agent' . $_GET ['Aid'] .' Case' . $_GET['Cid2'];
										$ST2 = 'Agent' . $_GET ['Aid'] .' Case' . $_GET['Cid2'];
									}
									$myfile = fopen ( $file2, "r" ) or die ( "Unable to open file!" );
									fgets ( $myfile );
									while ( ! feof ( $myfile ) ) {
										$currentline2 = fgets ( $myfile );
										$currentinfor2 = explode ( ',', $currentline2 );
										$year2 = intval ( $currentinfor2 [0+$base] );
										$agentid2 = intval ( $currentinfor2 [1+$base] );
										$subid2 =  trim($currentinfor2 [2+$base]) ;
										$data2 = $currentinfor2 [3+$base];
										if ($agentid2 == $aid) {
											$flag0 = 1;
											if (count ( $times2 ) == 0) {
												$label2 = array (
														$subid2 
												);
												$oneseries2 = array (
														$data2 
												);
												$timeseries2 = array (
														$year2 
												);
												$datas2 = array (
														$oneseries2 
												);
												$times2 = array (
														$timeseries2 
												);
											} else {
												$flag = - 1;
												for($i = 0; $i < count ( $label2 ); $i ++) {
													if (strcmp($label2 [$i] , $subid2) == 0) {
														$flag = $i;
													}
												}
											
												if ($flag == - 1) {
													array_push ( $label2, $subid2 );
													$oneseries2 = array (
															$data2 
													);
													$timeseries2 = array (
															$year2 
													);
													array_push ( $datas2, $oneseries2 );
													array_push ( $times2, $timeseries2 );
												} else {
													array_push ( $datas2 [$flag], $data2 );
													array_push ( $times2 [$flag], $year2 );
												}
											}
										}
									}
									$datasum2 = $datas2[0];
									for ($i = 1; $i<count($label2);$i++){
										for ($j = 0; $j<count($datasum2);$j++)
										{
											$datasum2[$j] = $datasum2[$j]+$datas2[$i][$j];
										}
									}
									fclose ( $myfile );
								}
								if ($flag0 === 0) {
									echo "document.getElementById('main').hide();";
								}
								?>
        var option = {
    
        	tooltip: {
        		trigger: 'axis'
            		},
        	legend: {
        		data:[<?php
										echo "'" . $subadd . "' ";
										if (isset ( $_GET ['Cid2'] ))
										{
											echo ",'" . $subadd2 . "' ";
										}
										
										
										?>]
        	},

        	
        	xAxis: {
        		name: 'Time/Year',
            
        		data: [<?php
										echo "'" . $times [0] [0] . "' ";
										for($i = 1; $i < count ( $times [0] ); $i ++) {
											echo ",'" . $times [0] [$i] . "' ";
										}
										if (isset ( $_GET ['Cid2'] ) & count ( $times [0] ) == 0) {
											echo "'" . $times2 [0] [0] . "' ";
											for($i = 1; $i < count ( $times2 [0] ); $i ++) {
												echo ",'" . $times2 [0] [$i] . "' ";
											}
										}
										
										?>]
        	},
        	yAxis: {
        		name: 
            	<?php
													if (isset ( $_GET ['View'] ) && $_GET ['View'] == 1) {
														echo "'Crop Yeild'";
													} elseif ((isset ( $_GET ['View'] ) && $_GET ['View'] == 3)) {
														echo "'HotSpot Satisfied'";
													} else
														echo "'Hydropower Generation'";
													?>
            	},
        	series: [
        	<?php
									
										echo chr(123);
										echo "name: '" . $subadd . $label [$i] . "',";
										echo "type: 'bar',";
										echo "stack: '" . $ST . "',";
										echo 'data: [';
										echo $datasum [0];
										for($j = 1; $j < count ( $datasum ); $j ++) {
											echo "," . $datasum [$j] . " ";
										}
										echo "]";
											echo chr(125).',';

									if (isset ( $_GET ['Cid2'] ))
									{
										echo chr(123);
										echo "name: '" . $subadd2 . $label2 [$i] . "',";
										echo "type: 'bar',";
										echo "stack: '" . $ST2 . "',";
										echo 'data: [';
										echo $datasum2 [0];
										for($j = 1; $j < count ( $datasum2 ); $j ++) {
											echo "," . $datasum2 [$j] . " ";
										}
										echo "]";
											echo chr(125);
									}
									
									?>]
        };
                myChart.setOption(option);
      
    </script>
	<?php if($flag0==0) {echo '<b>No Data Exist for This Agent.<b>';}?>
</body>
</html>