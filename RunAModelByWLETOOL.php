<!-- This page is used to start a new modelling case. 
     Redirected from StartaModelfor.php.
     Corresponds to negotiation mode.
     Users can combine multiple input cases together to form a modelling case and submit the modelling case to the server for execution.
     
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

<?php 
include 'Title.php';
?>
<?php
include "linkdatabase.php";
header("Cache-Control: no-cache, must-revalidate");

$basinname=$_GET['basin'];
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

<div class='col-md-6'>
<div class = "Scenarios">
<div class="instructions">
<h1>Modelling case <?php $modelid=$id;echo $id;?> </h1>
<H2>Select input cases to be included in this modeling case.</H2>
<p>Note: The value of earlier selected case will be used if different cases have overlap.</p>
</div>
<div class = "row">
<div class = "col-md-8">
<label for="InputCases">Input Cases:</label>
<select name="InputCase" id="InputCase" onChange='inputcaseinfor(this.id);'>
	<option value="">--Select a Input Case--</option>
	
<?php
$userid = $_COOKIE['WLEUserId'];
		/*
		 * 
		 * Query SQL Server for the login of the user accessing the
		 * database.
		 */
$tsql = "SELECT * FROM InputCase,Users WHERE InputCase.UserId = Users.UserId and InputCase.UserId = '".$userid."' and BasinName='".$_GET['basin']."' ; ";
$stmt = sqlsrv_query ( $conn, $tsql );

		if ($stmt === false) {
			echo "Error in executing query.</br>";
			die ( print_r ( sqlsrv_errors (), true ) );
		}
		
		/* Retrieve and display the results of the query. */
		while ( $row = sqlsrv_fetch_array ( $stmt ) )
		{
			$id = $row[CaseId];
				
			$visi = $row[Visibility];
			$user = $row[Name];
			$date0 = $row[CreatingTime];
			$date0 = $date0->format('Y-m-d H:i:s') ;
			$basin = trim($row[BasinName]);
			$notes= $row[Notes];
			
			echo "<option value=$id>Case $id Set up by $user at $date0</option>";
		}
		
		$tsql = "SELECT * FROM InputCase,Users WHERE InputCase.UserId = Users.UserId and InputCase.UserId <> '".$userid."' ; ";
		$stmt = sqlsrv_query ( $conn, $tsql );
		
		if ($stmt === false) {
			echo "Error in executing query.</br>";
			die ( print_r ( sqlsrv_errors (), true ) );
		}
		
		/* Retrieve and display the results of the query. */
		while ( $row = sqlsrv_fetch_array ( $stmt ) )
		{
			$id = $row[CaseId];
		
			$visi = $row[Visibility];
			$user = $row[Name];
			$date0 = $row[CreatingTime];
			$date0 = $date0->format('Y-m-d H:i:s') ;
			$basin = trim($row[BasinName]);
			$notes= $row[Notes];
		if( $visi===1){
			echo "<option value=$id>Case $id Set up by $user at $date0</option>";
		}
		}
			/* Free statement and connection resources. */
	sqlsrv_free_stmt( $stmt);
	/* Free statement and connection resources. */	
?>
</select>
</div>

<div class = "col-md-4">
<button onclick="AddInputCase(<?php echo "'".$modelid."'";?>);">Add to Modeling Case</button>
</div>


<br/>
<div class='col-md-12'>
<table class = 'table' id = 'inputcaseinfor'>

</table></div>

<br/>
<div class = 'col-md-12'><h2>Added Input Case List</h2></div>
<div class ='col-md-12'>
<table class = 'table' id = 'addedinputcase' >
<tr> <th> Input Case Id</th><th>Basin</th><th>Set-up User</th><th>Set-up Date</th><th>Visibility to Public</th><th>Description</th></tr>

</table>
</div>

</div>
</div>

</div>

<div class='col-md-6'>
<div class="instructions">
<h1>Confirm your settings and Excute model.</h1>
<p>Please click on the "Confirm Settings and Execute model" button to confirm your settings, and to run the model using your settings to get the final result.</p>
</div>
<button onclick="ExecuteModel(<?php echo $modelid;?>);">Confirm Settings and Execute model</button>
<img class = "Result" src = ""  width = <?php $W = $_GET['w']; $H = $_GET['h']; echo '"'.ceil($H*0.4).'"';?> id = "Result" >
</div>
</body>
</html>