<!-- This script is used to link a input case to a model case, with the id as a reference. -->
<?php
include "Getinputcaseinfor.php";
$modelcase = $_GET['modelcaseid'];
INCLUDE "linkdatabase.php";
$sql="Insert into ModelLists(CaseId,InputId) Values($modelcase,$id);";
echo $sql;
$stmt=sqlsrv_query($conn, $sql);
if($stmt)
{}
else {
	echo "Row insertion failed.\n";
	die ( print_r ( sqlsrv_errors (), true ) );
}
sqlsrv_free_stmt($stmt);
sqlsrv_close($conn);
?>
