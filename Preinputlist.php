<!-- This page is used to provide a list of existing input cases.
     Input cases can be further edited through link provided in this page.
-->
<!DOCTYPE html>
<html lang="en">

<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Agent Based Model Web Based Application</title>
<meta name="description"
	content="Agent Based Model Web Based Application.">
<!-- Bootstrap -->
<link href="./bootstrap/css/bootstrap.min.css" rel="stylesheet">

<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
<script src="http://code.jquery.com/jquery-1.10.2.js"></script>
<!-- Include all compiled plugins (below), or include individual files as needed -->
<script src="./bootstrap/js/bootstrap.min.js"></script>
<script src = "home.js"></script>

<style>
#slider {
	margin: 10px;
}
</style>
<script src="http://code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
</head>
<body>
<?php 
include 'Title.php';
setcookie ( "WLECaseId", '', time () - 3600 * 12 );

?>
<div class = "col-md-12">
<h1>Previous and Default Input</h1>
<p>This is a list of previous and default input case. Click on the link to view ditailed settings</p>
<table class = 'table'>
<tr> <th> Input Case Id</th><th>Basin</th><th>Set-up User</th><th>Set-up Date(UTC)</th><th>Visibility to Public</th><th>Description</th><th>Action</th></tr>
<?php 
include "linkdatabase.php";
$userid = $_COOKIE['WLEUserId'];
if ($conn === false) {
	echo "Could not connect.\n";
	die ( print_r ( sqlsrv_errors (), true ) );
}
$tsql = "SELECT * FROM InputCase,Users WHERE InputCase.UserId = Users.UserId and InputCase.UserId = '".$userid."' ; ";
$stmt = sqlsrv_query ( $conn, $tsql );

if($stmt === false )
{
	echo "Error in retrieving row.\n";
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
			$notes= trim($row[Notes],' ');
			if ($visi===0)
			{$visis='False';}
			else 
			{$visis='True';}
			echo "<tr> <td> <a href = 'StartAInputByWLETOOL.php?w=".$_GET['w']."&h=".$_GET['h']."&CaseId=".$id."&User=".$user."&Date=".$date0."&Basin=".$basin."&Notes=".$notes."&Visi=".$visi."'>$id</a></td><td>$basin</td><td>$user</td><td>$date0</td><td>$visis</td><td>$notes</td><td> <a href = 'StartAInputByWLETOOL.php?w=".$_GET['w']."&h=".$_GET['h']."&CaseId=".$id."&User=".$user."&Date=".$date0."&Basin=".$basin."&Notes=".$notes."&Visi=".$visi."'>Manage</a></td>";
		echo "</tr>";
	}
}
sqlsrv_free_stmt($stmt);
$tsql = "SELECT * FROM InputCase,Users WHERE InputCase.UserId = Users.UserId and InputCase.UserId <> '".$userid."' ; ";
$stmt = sqlsrv_query ( $conn, $tsql );

if($stmt === false )
{
	echo "Error in retrieving row.\n";
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
		$notes= trim($row[Notes],' ');
		if ($visi===1)
		{
			$visis='True';
			echo "<tr> <td> <a href = 'ViewOthersInputs.php?w=".$_GET['w']."&h=".$_GET['h']."&CaseId=".$id."&User=".$user."&Date=".$date0."&Basin=".$basin."&Notes=".$notes."&Visi=".$visi."'>$id</a></td><td>$basin</td><td>$user</td><td>$date0</td><td>$visis</td><td>$notes</td><td> <a href = 'ViewOthersInputs.php?w=".$_GET['w']."&h=".$_GET['h']."&CaseId=".$id."&User=".$user."&Date=".$date0."&Basin=".$basin."&Notes=".$notes."&Visi=".$visi."'>View</a></td></tr>";
		}
		else
		{$visis='False';}
	}
}
sqlsrv_free_stmt($stmt);
sqlsrv_close($conn);
?>
</table>
</div>
</body>
</html>