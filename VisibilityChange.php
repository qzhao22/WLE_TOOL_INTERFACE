<?php
// Change the visibility of some input cases in the database according to the requirement sent by the user 
include "linkdatabase.php";

if ($conn === false) {
	echo "Could not connect.\n";
	die ( print_r ( sqlsrv_errors (), true ) );
}
$tsql5 = "UPDATE  InputCase SET Visibility='" . $_GET['status'] . "' where  CaseId=" . $_GET['caseid']. "; ";
echo $tsql5;
$stmt5 = sqlsrv_query ( $conn, $tsql5 );
if ($stmt) {
}

else {
	echo "Row Update failed.\n";
	die ( print_r ( sqlsrv_errors (), true ) );
}
?>