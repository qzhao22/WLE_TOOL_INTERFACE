
<?php
include "linkdatabase.php";
$id = $_GET['caseid'];
//<!-- This script is used to acquire and print case information according to a given case id. -->
$tsql = "SELECT * FROM InputCase,Users WHERE InputCase.UserId = Users.UserId and InputCase.CaseId = ".$id." ; ";
$stmt = sqlsrv_query ( $conn, $tsql );
if($stmt === false )
{
	echo $id."Error in retrieving row.\n";
	die( print_r( sqlsrv_errors(), true));
}

else{
	while ( $row = sqlsrv_fetch_array ( $stmt ) ) {
		$id = $row[CaseId];
			
		$visi = $row[Visibility];
		$user = $row[Name];
		$date0 = $row[CreatingTime];
		$date0 = $date0->format('Y-m-d H:i:s') ;
		$basin = trim($row[BasinName]);
		$notes= $row[Notes];
		if ($visi===1)
		{
			$visis='True';
		}
		else
		{$visis='False';}
		echo "<tr> <td> $id</td><td>$basin</td><td>$user</td><td>$date0</td><td>$visis</td><td>$notes</td></tr>";

	}
}
sqlsrv_free_stmt($stmt);
sqlsrv_close($conn);
?>