<?php
//<!-- Get a new input case id for a new input case. It inserts a row in the inputCase Table. -->

header("Cache-Control: no-cache, must-revalidate");
include "linkdatabase.php";
// Get the basin Name.
$basinname=$_GET['basinname'];
if ($conn === false) {
	echo "Could not connect.\n";
	die ( print_r ( sqlsrv_errors (), true ) );
}
$count = 0;
$flag = 0;
while ( $flag === 0 ) {
	/* Set up the parameterized query. */
	$tsql = "INSERT INTO InputCase(IpAddr,UserId,Visibility,BasinName) VALUES('" . $_SERVER ['REMOTE_ADDR'] . "','".$_COOKIE ['WLEUserId']."',0,'".$basinname."') ";
	/* Prepare and execute the query. */
	$stmt = sqlsrv_query ( $conn, $tsql );
	if ($stmt) {
	} 
    
	else {
		echo "Row insertion failed.\n";
		die ( print_r ( sqlsrv_errors (), true ) );
	}
	// Check whether the insert have been successful.
	$tsql = "SELECT * FROM InputCase WHERE CaseId In (SELECT Max(CaseId) from InputCase); ";
	
	$stmt = sqlsrv_query ( $conn, $tsql );
	
	/* Execute the query. */
	if ($stmt === false) {
		echo "Error in statement execution.\n";
		die ( print_r ( sqlsrv_errors (), true ) );
	} 

	else {
		while ( $row = sqlsrv_fetch_array ( $stmt ) ) {
			$ip = $row [IpAddr];
			$id = $row[CaseId];
		}
	}
	$ip = trim($ip,' ');
	if (!strcmp($_SERVER ['REMOTE_ADDR'],$ip)) {
		$flag = 1;
	}
	if ($count ===10)
	{
		$flag=1;
	}
	$count = $count+1;
}

// Used for clear old and set new cookies for identifying this input case in other pages.
setcookie ( "WLECaseId", '', time () - 3600 * 12 );
setcookie ( "WLECaseId", $id, time () + 3600 * 12 );
echo $id;
sqlsrv_free_stmt ( $stmt );
sqlsrv_close ( $conn );
?>
