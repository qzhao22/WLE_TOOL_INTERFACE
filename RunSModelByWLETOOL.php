<!-- This page is used to start a new modelling case. 
     Redirected from StartaSModelfor.php.
     Corresponds to scenario mode.
     Users can choose one case from the input cases to the server for execution.
     
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
<!-- Include all compiled plugins (below), or include individual files as needed -->
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
<body>
<?php 
include 'Title.php';
?>
<?php
include "linkdatabase.php";
header("Cache-Control: no-cache, must-revalidate");
$basinname=$_GET['Basin'];
if ($conn === false) {
	echo "Could not connect.\n";
	die ( print_r ( sqlsrv_errors (), true ) );
}
$count = 0;
$flag = 0;
while ( $flag === 0 ) {
	/* Set up the parameterized query. */
	$tsql = "INSERT INTO ModelCase(IpAddr,UserId,BasinName) VALUES('" . $_SERVER ['REMOTE_ADDR'] . "','".$_COOKIE ['WLEUserId']."','".$basinname."') ";
	/* Prepare and execute the query. */
	$stmt = sqlsrv_query ( $conn, $tsql );
	if ($stmt) {
	} 
    
	else {
		echo "Row insertion failed.\n";
		die ( print_r ( sqlsrv_errors (), true ) );
	}
	$tsql = "SELECT * FROM ModelCase WHERE CaseId In (SELECT Max(CaseId) from ModelCase); ";
	
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

sqlsrv_free_stmt ( $stmt );
?>

<div class='col-md-12'>
<div class="instructions">
<h1>Modelling case <?php $modelid=$id;echo $id;?> </h1></div>
<table class = 'table'>
<tr> <th> Input Case Id</th><th>Basin</th><th>Set-up User</th><th>Set-up Date</th><th>Visibility to Public</th><th>Description</th><th>Execute</th></tr>
<?php 
include "linkdatabase.php";
$userid = $_COOKIE['WLEUserId'];
if ($conn === false) {
	echo "Could not connect.\n";
	die ( print_r ( sqlsrv_errors (), true ) );
}
$tsql = "SELECT * FROM InputCase,Users WHERE InputCase.UserId = Users.UserId and InputCase.UserId = '".$userid."' and InputCase.BasinName= '".$_GET[Basin]."'; ";
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
			echo "<tr> <td> $id</a></td><td>$basin</td><td>$user</td><td>$date0</td><td>$visis</td><td>$notes</td><td>";
			echo '<button onclick="ExecuteModelSingle('.$modelid.','.$id.');"> Execute model</button></td></tr>';
			echo "</tr>";
	}
}
sqlsrv_free_stmt($stmt);
$tsql = "SELECT * FROM InputCase,Users WHERE InputCase.UserId = Users.UserId and InputCase.UserId <> '".$userid."' and InputCase.BasinName= '".$_GET[Basin]."'; ";
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
			echo "<tr> <td> $id</a></td><td>$basin</td><td>$user</td><td>$date0</td><td>$visis</td><td>$notes</td><td>";
			echo '<button onclick="ExecuteModelSingle('.$modelid.','.$id.');"> Execute model</button></td></tr>';
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