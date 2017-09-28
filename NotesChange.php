<!-- execute change notes request for a input case modification -->
<?php
include "linkdatabase.php";

if ($conn === false) {
	echo "Could not connect.\n";
	die ( print_r ( sqlsrv_errors (), true ) );
}
$tsql5 = "UPDATE  InputCase SET Notes='" . $_GET['status'] . "' where  CaseId=" . $_GET['caseid']. "; ";
/* Prepare and execute the query. */
echo $tsql5;
$stmt5 = sqlsrv_query ( $conn, $tsql5 );

if($stmt===false) {
	echo "Row Update failed.\n";
	die ( print_r ( sqlsrv_errors (), true ) );
}
else
	echo 1;
?>