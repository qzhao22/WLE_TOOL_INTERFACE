<!-- This page is used to  generate the webpage for users to start a new input case or continue edit existing input case.
     A new input case id will be assigned if starting a new input case.
     Otherwise, to continue existing input case, the CaseId should be passed with GET method.
-->

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Agent Based Model Web Based Application</title>
<meta name="description"
	content="Run Model|Agent Based Model Web Based Application.">
<!-- Bootstrap -->
<link href="./bootstrap/css/bootstrap.min.css" rel="stylesheet">

<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
<script src="http://code.jquery.com/jquery-1.10.2.js"></script>
<script src="./bootstrap/js/bootstrap.min.js"></script>
<script src = "home.js"></script>




<script src = "setattr.js"></script>
<script>
$(function(){
	<?php if (!isset($_GET['CaseId'])){
	echo "$('.inputinformation').hide();";}?>
});
</script>
<style>
#slider {
	margin: 10px;
}
</style>
<script src="http://code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
</head>

<?php 
include 'Title.php';
?>


<!-- This code block provide a map for the users to click, which will pop up pages for users to set up input for different agents. -->
<div class='col-md-6'>
	<div class="Scenarios">
		<div class="instructions">
			<h1>Please select one Basin and Scenario.</h1>
			<p>Current basins include the Niger,the Indus and the Mekong basin.</p>
		</div>
		<div class="row">
		<!-- Users should choose the basin which they are going to set up model for here. -->
		<!-- Once select a unique id will be assigned to identify this case in the database.  -->
		<!-- That also means once the basin is select, it can not be changed without changing the case id, and therefore, if the user want to change the basin selected they should clear their previous selection first and then choose another basin. -->
			<div class="col-md-6">
				<label for="Scenarios">Basins:<br></label> <select name="Scenarios"
					id="Scenarios" onChange="ChangeScenarios(this.id);" <?php  if (isset($_GET['CaseId'])){ echo 'disabled';}?>>
					<option value="">--Select a Basin--</option>
					<option value="Mekong" <?php if (isset($_GET['CaseId'])){ if("Mekong"===$_GET['Basin']) {echo "selected";}}?>>Mekong</option>
					<option value="Niger" <?php if (!isset($_GET['CaseId'])){ if("Niger"===$_GET['Basin']) {echo "selected";}}?>>Niger</option>
					<option value="Indus"  <?php if (!isset($_GET['CaseId'])){ if("Indus"===$_GET['Basin']) {echo "selected";}}?>>Indus</option>
				</select>
				<!-- 
			    <label for="Scenario">Scenarios:<br></label> <select name="Scenario"
					id="Scenario" onChange="ChangeScenario(this.id);" <?php//  if (isset($_GET['CaseId'])){ echo 'disabled';}?>>
					<option value="">--Select a Basin--</option>
				    <option value= "Default" <?php //if (isset($_GET['CaseId'])){ if("Default"===$_GET['Scen']) {echo "selected";}}?>>Default</option>
					<option value="Dry" <?php //if (isset($_GET['CaseId'])){ if("Dry"===$_GET['Scen']) {echo "selected";}}?>>Dry</option>
					<option value="Wet" <?php //if (!isset($_GET['CaseId'])){ if("Wet"===$_GET['Scen']) {echo "selected";}}?>>Wet</option>
					<option value="ExtremeDry"  <?php // if (!isset($_GET['CaseId'])){ if("ExtremeDry"===$_GET['Scen']) {echo "selected";}}?>>Extreme Dry</option>
					<option value="ExtremeWet" <?php //if (!isset($_GET['CaseId'])){ if("ExtremeWet"===$_GET['Scen']) {echo "selected";}}?>>Extreme Wet</option>
				</select>
			-->
			</div>

			<div class="col-md-6">
				<button onclick="ClearSettings();" <?php if (isset($_GET['CaseId'])){ echo 'disabled="disabled"';}?>>Clear Current Basin Selection and
					Settings</button>
			</div>


		</div>
		<!-- A map is provided here for the users to click, which will result in a pop up window for collecting input. -->
		<div class="BasinMap">
			<img class="Map" src="<?php  if (isset($_GET['CaseId'])){echo 'BasinMaps/'.$_GET[Basin].'.jpg';}?>" usemap="<?php  if (isset($_GET['CaseId'])){echo '#'.$_GET[Basin].'MapArea';}?>"
				width=<?php $W = $_GET['w']; $H = $_GET['h']; echo '"'.ceil($H*0.4).'"';?>
				id="BasinMapId">
			<map id="MekongMapArea" name="MekongMapArea">
<?php 
include "linkdatabase.php";
$tsql = "SELECT max(POINT_X) FROM Mekong";
/* Execute the query. */
$stmt = sqlsrv_query($conn, $tsql);
if( $stmt === false )
{
     echo "Error in statement execution.\n";
     die( print_r( sqlsrv_errors(), true));
}

/* Retrieve and display the data. The first three fields are retrieved
as strings and the fourth as a stream with character encoding. */
if(sqlsrv_fetch( $stmt ) === false )
{
     echo "Error in retrieving row.\n";
     die( print_r( sqlsrv_errors(), true));
}

$maxX = sqlsrv_get_field( $stmt, 0 );

$tsql = "SELECT min(POINT_X) FROM Mekong";
/* Execute the query. */
$stmt = sqlsrv_query($conn, $tsql);
if( $stmt === false )
{
	echo "Error in statement execution.\n";
	die( print_r( sqlsrv_errors(), true));
}

/* Retrieve and display the data. The first three fields are retrieved
 as strings and the fourth as a stream with character encoding. */
if(sqlsrv_fetch( $stmt ) === false )
{
	echo "Error in retrieving row.\n";
	die( print_r( sqlsrv_errors(), true));
}

$minX = sqlsrv_get_field( $stmt, 0 );

$tsql = "SELECT max(POINT_Y) FROM Mekong";
/* Execute the query. */
$stmt = sqlsrv_query($conn, $tsql);
if( $stmt === false )
{
	echo "Error in statement execution.\n";
	die( print_r( sqlsrv_errors(), true));
}

/* Retrieve and display the data. The first three fields are retrieved
 as strings and the fourth as a stream with character encoding. */
if(sqlsrv_fetch( $stmt ) === false )
{
	echo "Error in retrieving row.\n";
	die( print_r( sqlsrv_errors(), true));
}

$maxY = sqlsrv_get_field( $stmt, 0 );


$tsql = "SELECT min(POINT_Y) FROM Mekong";
/* Execute the query. */
$stmt = sqlsrv_query($conn, $tsql);
if( $stmt === false )
{
	echo "Error in statement execution.\n";
	die( print_r( sqlsrv_errors(), true));
}

/* Retrieve and display the data. The first three fields are retrieved
 as strings and the fourth as a stream with character encoding. */
if(sqlsrv_fetch( $stmt ) === false )
{
	echo "Error in retrieving row.\n";
	die( print_r( sqlsrv_errors(), true));
}

$minY = sqlsrv_get_field( $stmt, 0 );

$xrange = $maxX - $minX;
$yrange = $maxY - $minY;
$ximg = ceil($H*0.4);

$deltamap = 20000;
$xinitial = 850;
$ratio = $ximg/$xinitial;
$yinitial = 1100;
$xfc = 684;
$yfc = 1036;
$xsc = 516; 
$ysc = 973;
/*
$deltamap = 0.2;

$xinitial = 1700;
$ratio = $ximg/$xinitial;
$yinitial = 2200;
$xfc = 1462;
$yfc = 2091;
$xsc = 1222;
$ysc = 1979;*/
$deltax = ($xinitial-$xfc)*$ratio;
$deltay = ($yinitial-$yfc)*$ratio;
$tsql = "SELECT AgentId, SubBasinId, AgentName,POINT_X, POINT_Y FROM Mekong;";
$gapy= $ysc*$ratio*$deltamap/$yrange;
$gapx= $xsc*$ratio*$deltamap/$xrange;
$scalex = $gapx/$deltamap;
$scaley = $gapy/$deltamap;
$stmt = sqlsrv_query ( $conn, $tsql );
$deltaCellx = ($gapx-1)/2;
$deltaCelly = ($gapy-1)/2;
if ($stmt === false) {
	echo "Error in executing query.</br>";
	die ( print_r ( sqlsrv_errors (), true ) );
}

/* Retrieve and display the results of the query. */
while ( $row = sqlsrv_fetch_array ( $stmt ) )
{
	$appd = '';
	$nums = '';
	if(isset($_GET['CaseId'])){
		$appd=','.$_GET['CaseId'];
		$nums = '3';
	}
	echo "<area shape='rect' coords = '".floor(($row['POINT_X']-$minX)*$scalex-$deltaCellx+$deltax).','.floor(($maxY-$row['POINT_Y'])*$scaley-$deltaCelly+$deltay)
	.','.ceil(($row['POINT_X']-$minX)*$scalex+$deltaCellx+$deltax).','.ceil(($maxY-$row['POINT_Y'])*$scaley+$deltaCelly+$deltay)."' onClick= 'SettingAttr".$nums."(".
	$row["AgentId"].','.$row['SubBasinId'].$appd.");'>\n";
}

?>
</map>
			<map id="NigerMapArea" name="NigerMapArea">

<?php 
?>
</map>
			<map id="IndusMapArea" name="IndusMapArea">
<?php

/* Free statement and connection resources. */
sqlsrv_free_stmt ( $stmt );
sqlsrv_close ( $conn );
if (isset($_GET['CaseId'])){
setcookie ( "WLECaseId", '', time () - 3600 * 12 );}
?>

</map>
		</div>
	</div>
</div>

<!-- Following code is used to show the general information of the input case, users could use these information to retrieve their previous input case in the future. -->
<div class='col-md-6'>
	<div class='inputinformation' id='inputinformation'>
		<h1>Input Case Information</h1>
		<table class='table'>
			<tr>
				<td><b>Input Case Id:</b></td>
				<td>
					<div class="col-md-4">
						<p class="inputId" id="inputId"><?php if (isset($_GET['CaseId'])){echo $_GET['CaseId'];}?></p>
					</div>
				</td>
			</tr>
			<tr>
				<td><b>Basin:</b></td>
				<td>
					<div class="col-md-4">
						<p class="Basinname" id="Basinname"><?php if (isset($_GET['CaseId'])){echo $_GET['Basin'];}?></p>
					</div>
				</td>
			</tr>
			<tr>
				<td><b>Created by:</b></td>
				<td>
					<div class="col-md-4">
						<p class="createuser" id="createuser"></p>
						<?php echo $_COOKIE['WLEUserName'];?>
					</div>
				</td>
			</tr>
						<tr>
				<td><b>Visibility to public:</b></td>
				<td>
					<div class="col-md-4">
						<input type="checkbox" id='visi' onchange="ChangeVisibility();" <?php if (isset($_GET['CaseId'])){if($_GET['Visi']){echo "checked";}}?>>
					</div>
				</td>
			</tr>
			 
			<tr>
				<td><b>Creating Time:</b></td>
				<td>
					<div class="col-md-4">
						<p class="creatingtime" id="creatingtime"><?php if (isset($_GET['Date'])){echo $_GET['Date'];}?></p>
					</div>
				</td>
			</tr>
			<tr>
				<td><b>Notes</b></td>
				<td><textarea name="notes" id="notes" cols="50" rows="7"> <?php if (isset($_GET['CaseId'])){echo $_GET['Notes'];}?></textarea>
				<br>
				<br/>
				<button onclick = "submitnotes();">Submit Notes</button>
				</td>
			</tr>
		</table>
	</div>
</div>
</body>
</html>
