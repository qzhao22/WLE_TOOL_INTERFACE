
<!-- Not being Used in current version -->


<?php
ini_set('max_execution_time',36000); set_time_limit(36000);
$caseid = $_GET ['Cid'];
$modelfolder = "./1018_ABM_SWAT/";
$modeldir = $modelfolder . 'ABM_SWAT_1018.R';
$folderDir = "./Case/" . $caseid;
$currentfolder = $folderDir;
$currentcase = $caseid;
include "linkdatabase.php";
header ( "Cache-Control: no-cache, must-revalidate" );
if ($conn === false) {
	echo "Could not connect.\n";
	die ( print_r ( sqlsrv_errors (), true ) );
}

rename ( $currentfolder . '/User_ESS.csv', $modelfolder . 'User_ESS.csv' );
$rcommand = 'Rscript ' . $modeldir;
//system ( $rcommand, $out );
sleep(10);

copy ( $modelfolder . 'eco_summary.csv', $currentfolder . '/eco_summary.csv' );
copy ( $modelfolder . 'crop_summary.csv', $currentfolder . '/crop_summary.csv' );
copy ( $modelfolder . 'hydropower_summary.csv', $currentfolder . '/hydropower_summary.csv' );
rename ( $modelfolder . 'User_ESS.csv', $currentfolder . '/User_ESS.csv' );
$tsql8 = "SELECT count(*) FROM Status where Status < 2; ";
$stmt8 = sqlsrv_query ( $conn, $tsql8 );
if (sqlsrv_fetch ( $stmt8 ) === false) {
	echo "3Error in retrieving row.\n";
	die ( print_r ( sqlsrv_errors (), true ) );
}

$num8 = sqlsrv_get_field ( $stmt8, 0 );
$num8 = $num8 - 1;

if ($num8 == 0) {
	$tsql11 = "UPDATE  Status SET Status = 2 where CaseId = " . $currentcase . "; ";
	/* Prepare and execute the query. */

	$stmt11 = sqlsrv_query ( $conn, $tsql11 );
	if ($stmt11) {
	}
		
	else {
		echo "1212Row Update failed.\n";
		die ( print_r ( sqlsrv_errors (), true ) );
	}
} else {
	$tsql9 = "SELECT CaseId FROM Status where Status = 0; ";
	$stmt9 = sqlsrv_query ( $conn, $tsql9 );
	if ($stmt9 === false) {
		echo "Error in executing query.</br>";
		die ( print_r ( sqlsrv_errors (), true ) );
	}
		
	/* Retrieve and display the results of the query. */
	$row9 = sqlsrv_fetch_array ( $stmt9 );
	$currentfolder = "Case/" . $row9 [CaseId];
	$tsql10 = "UPDATE  Status SET Status = 1 where CaseId = " . $row9 [CaseId] . "; ";
	/* Prepare and execute the query. */
		
	$stmt10 = sqlsrv_query ( $conn, $tsql10 );
	if ($stmt10) {
	}

	else {
		echo "1515Row Update failed.\n";
		echo $tsql10;
		die ( print_r ( sqlsrv_errors (), true ) );
	}
	$tsql11 = "UPDATE  Status SET Status = 2 where CaseId = " . $currentcase . "; ";
	/* Prepare and execute the query. */
		
	$stmt11 = sqlsrv_query ( $conn, $tsql11 );
	if ($stmt11) {
	}

	else {
		echo "1616Row Update failed.\n";
		die ( print_r ( sqlsrv_errors (), true ) );
	}
	$currentcase = $row9 [CaseId];
		
	header("Location: ExecuteNext.php?Cid=".$currentcase);
}

sqlsrv_free_stmt ( $stmt8 );
sqlsrv_free_stmt ( $stmt9 );
sqlsrv_free_stmt ( $stmt10 );
sqlsrv_free_stmt ( $stmt11 );
?>