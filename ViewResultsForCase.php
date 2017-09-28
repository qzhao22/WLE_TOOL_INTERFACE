<!-- This page provide a map for the users to click, which will pop up pages for users to view modelling results for different agents.
     Redirected from ViewPreResults.php.
     This page can also be used to compare results from two different runs.
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


<!-- This page provide a map for the users to click, which will pop up pages for users to view modelling results for different agents. -->
<div class='col-md-6'>
		<div class="instructions">
			<h1>Please Click On the Map to view results.</h1>
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
	if (isset($_GET['id2']))
	{
		echo "<area shape='rect' coords = '".floor(($row['POINT_X']-$minX)*$scalex-$deltaCellx+$deltax).','.floor(($maxY-$row['POINT_Y'])*$scaley-$deltaCelly+$deltay)
		.','.ceil(($row['POINT_X']-$minX)*$scalex+$deltaCellx+$deltax).','.ceil(($maxY-$row['POINT_Y'])*$scaley+$deltaCelly+$deltay)."' onClick= 'CpResults(".
		$row["AgentId"].','.$_GET['CaseId'].','.$_GET['id2'].");'>\n";
	}
	else 
	{
	echo "<area shape='rect' coords = '".floor(($row['POINT_X']-$minX)*$scalex-$deltaCellx+$deltax).','.floor(($maxY-$row['POINT_Y'])*$scaley-$deltaCelly+$deltay)
	.','.ceil(($row['POINT_X']-$minX)*$scalex+$deltaCellx+$deltax).','.ceil(($maxY-$row['POINT_Y'])*$scaley+$deltaCelly+$deltay)."' onClick= 'ViewResults(".
	$row["AgentId"].','.$_GET['CaseId'].");'>\n";
	}
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


</body>
</html>