<!-- This page is used to show the users other users' inputs, it is allowed for the users to view but not allowed to modify the data. -->

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
<!-- Include all compiled plugins (below), or include individual files as needed -->
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
<!-- This page is used to show the users other users' inputs, it is allowed for the users to view but not allowed to modify the data. -->
<div class='col-md-6'>
	<div class="Scenarios">
		<div class="instructions">
			<h1>Input Case</h1>
		</div>
		<div class="row">
			<div class="col-md-6">
				<label for="Scenarios">Basins:<br></label> <select name="Scenarios"
					id="Scenarios" onChange="ChangeScenarios(this.id);" <?php  if (isset($_GET['CaseId'])){ echo 'disabled';}?>>
					<option value="">--Select a Basin--</option>
					<option value="Mekong" <?php if (isset($_GET['CaseId'])){ if("Mekong"===$_GET['Basin']) {echo "selected";}}?>>Mekong</option>
					<option value="Niger" <?php if (!isset($_GET['CaseId'])){ if("Niger"===$_GET['Basin']) {echo "selected";}}?>>Niger</option>
					<option value="Indus"  <?php if (!isset($_GET['CaseId'])){ if("Indus"===$_GET['Basin']) {echo "selected";}}?>>Indus</option>
				</select>
			</div>

			<div class="col-md-6">
			</div>


		</div>
		
		<!-- Following code shows a map for current basin, it will retrieve the agent id when users click on the map. -->
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
	.','.ceil(($row['POINT_X']-$minX)*$scalex+$deltaCellx+$deltax).','.ceil(($maxY-$row['POINT_Y'])*$scaley+$deltaCelly+$deltay)."' onClick= 'ShowVarVals".$nums."(".
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
<div class='col-md-6'>
	<div class='inputinformation' id='inputinformation'>
		<h1>Input Case Information</h1>
<table class = 'table' id = 'caseinfor' >
<tr> <th> Input Case Id</th><th>Basin</th><th>Set-up User</th><th>Set-up Date</th><th>Visibility to Public</th><th>Description</th></tr>
<?php
$id = $_GET["CaseId"];
$user=$_GET["User"];
$date0=$_GET["Date"];
$basin=$_GET["Basin"];
$notes=$_GET["Notes"];
$visi=$_GET["Visi"];
if ($visi===1)
{
	$visis='True';
}
else
{$visis='False';}
		echo "<tr> <td> $id</td><td>$basin</td><td>$user</td><td>$date0</td><td>$visis</td><td>$notes</td></tr>";
?>
</table>
<h1>Inputs set for selected sub-basin and agent.</h1>
<p>Note: Variables whose value not changed by users,i.e. set as default values, will not be shown here.</p>
<table class = 'table' id = 'varvalues' >
</table>
	</div>
</div>
</body>
</html>