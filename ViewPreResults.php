<!-- This page is for the users to view the results of previous execution of the model. 
     A list of all modelling cases will provided.
     The status of each case will also be shown, and a link will be provided for each case to view the result if execution has been finished.

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

<!-- This page is for the users to view the results of previous execution of the model. -->

<?php 
include 'Title.php';
?>
<?php
include "linkdatabase.php";
header("Cache-Control: no-cache, must-revalidate");

if ($conn === false) {
	echo "Could not connect.\n";
	die ( print_r ( sqlsrv_errors (), true ) );
}

?>
<div class='col-md-12'>
<?php 
	if(!isset($_GET['C']))
			{
				echo "<h1>View Results </h1>";
			}
			elseif($_GET['C']==0)
			{
				echo "<h1>Select First Case You Want to Compare </h1>";
			}
			elseif($_GET['C']==1)
			{
				echo "<h1>Select Second Case You Want to Compare </h1>";
			}
		?>
<p>This is a list of previous modeling cases. Click on the link to view the results.</p>
<table class = 'table'>
<tr> <th> Modeling Case Id</th><th>Basin</th><th>Set-up User</th><th>Set-up Date(UTC)</th><th>Action</th></tr>
	<!-- The following php code is used to retrieve the existing results that the users could be view. -->
<?php
$userid = $_COOKIE['WLEUserId'];

//$tsql = "SELECT * FROM ModelCase,Users,Status WHERE ModelCase.CaseId = Status.CaseId AND ModelCase.UserId = Users.UserId and ModelCase.UserId = '".$userid."' ; ";
$tsql = "SELECT * FROM ModelCase,Users,Status WHERE ModelCase.CaseId = Status.CaseId AND ModelCase.UserId = Users.UserId; ";

$stmt = sqlsrv_query ( $conn, $tsql );
		if ($stmt === false) {
			echo "Error in executing query.</br>";
			die ( print_r ( sqlsrv_errors (), true ) );
		}
		
		/* Retrieve and display the results of the query. */
		while ( $row = sqlsrv_fetch_array ( $stmt ) )
		{
			$id = $row[CaseId];
			$user = $row[Name];
	
			$date0 = $row[CreatingTime];
			$date0 = $date0->format('Y-m-d H:i:s') ;
			$basin = trim($row[BasinName]);
			if(!isset($_GET['C']))
			{
				if($row[Status] == 0)
				{
					echo "<tr> <td>$id</td><td>$basin</td><td>$user</td><td>$date0</td><td> Waiting </td>";
						
				}
				elseif ($row[Status] == 1)
				{
					echo "<tr> <td>$id</td><td>$basin</td><td>$user</td><td>$date0</td><td> Executing</td>";
						
				}
				else
				{
				echo "<tr> <td> <a href = 'ViewResultsForCase.php?w=".$_GET['w']."&h=".$_GET['h']."&CaseId=".$id."&User=".$user."&Date=".$date0."&Basin=".$basin."'>$id</a></td><td>$basin</td><td>$user</td><td>$date0</td><td> <a href = 'ViewResultsForCase.php?w=".$_GET['w']."&h=".$_GET['h']."&CaseId=".$id."&User=".$user."&Date=".$date0."&Basin=".$basin."'>View Results</td>";
				}}
				
			elseif($_GET['C']==0)
			
			{
				if($row[Status] == 0)
				{
					echo "<tr> <td>$id</td><td>$basin</td><td>$user</td><td>$date0</td><td> Waiting </td>";
				
				}
				elseif ($row[Status] == 1)
				{
					echo "<tr> <td>$id</td><td>$basin</td><td>$user</td><td>$date0</td><td> Executing</td>";
				
				}
				else {
				echo "<tr> <td> <a href = 'ViewPreResults.php?C=1&w=".$_GET['w']."&h=".$_GET['h']."&CaseId=".$id."&User=".$user."&Date=".$date0."&Basin=".$basin."'>$id</a></td><td>$basin</td><td>$user</td><td>$date0</td><td> <a href = 'ViewPreResults.php?C=1&w=".$_GET['w']."&h=".$_GET['h']."&CaseId=".$id."&User=".$user."&Date=".$date0."&Basin=".$basin."'>Select</a></td>";
			}}
			elseif($_GET['C']==1)
			{
				if($row[Status] == 0)
				{
					echo "<tr> <td>$id</td><td>$basin</td><td>$user</td><td>$date0</td><td> Waiting </td>";
				
				}
				elseif ($row[Status] == 1)
				{
					echo "<tr> <td>$id</td><td>$basin</td><td>$user</td><td>$date0</td><td> Executing</td>";
				
				}else{
				if ($id != $_GET['CaseId'])
				{
				echo "<tr> <td> <a href = 'ViewResultsForCase.php?C=2&id2=".$_GET['CaseId']."&w=".$_GET['w']."&h=".$_GET['h']."&CaseId=".$id."&User=".$user."&Date=".$date0."&Basin=".$basin."'>$id</a></td><td>$basin</td><td>$user</td><td>$date0</td><td> <a href = 'ViewResultsForCase.php?C=2&id2=".$_GET['CaseId']."&w=".$_GET['w']."&h=".$_GET['h']."&CaseId=".$id."&User=".$user."&Date=".$date0."&Basin=".$basin."'>Select</a></td>";
				}
				}
				}
		}
		
	sqlsrv_free_stmt( $stmt);
	/* Free statement and connection resources. */	
?>
</table>
</div>

</html>