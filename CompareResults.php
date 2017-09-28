<!-- Not being Used in current version -->
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

if ($conn === false) {
	echo "Could not connect.\n";
	die ( print_r ( sqlsrv_errors (), true ) );
}

?>

<div class='col-md-6'>
<div class = "Scenarios">
<div class="instructions">
<h1>Your Previous Modeling Cases </h1>
</div>
<div class = "row">
<div class = "col-md-12">
<label for="ModelingCases">Modeling Cases:</label>
<select name="Modelcase" id="Modelcase" onChange='showresult(this.id);'>
	<option value="">--Select a Input Case--</option>
	
<?php
$userid = $_COOKIE['WLEUserId'];
		/*
		 * 
		 * Query SQL Server for the login of the user accessing the
		 * database.
		 */
$tsql = "SELECT * FROM ModelCase,Users WHERE ModelCase.UserId = Users.UserId and ModelCase.UserId = '".$userid."' ; ";
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
			
			echo "<option value=$id>Case $id Set up by $user at $date0 for $basin</option>";
		}
		
	sqlsrv_free_stmt( $stmt);
	/* Free statement and connection resources. */	
?>
</select>
</div>
<div class = "col-md-12">
<label for="ModelingCases">Results:</label>
<select name="Modelcase" id="Modelcase" onChange='showresult(this.id);'>
	<option value="">--Select a Input Case--</option>
	<option value = 'WaterSupply'>Water Supply</option>
	<option value = 'EvironmentalFlow'>Environmental Flow</option>
</select>
</div>

</div>
</div>

</div>
<div class='col-md-6'>
<div class = "Scenarios">
<div class="instructions">
<h1>Select Another Modelling Case to Compare </h1>
</div>
<div class = "row">
<div class = "col-md-12">
<label for="ModelingCases">Modeling Cases:</label>
<select name="Modelcase" id="Modelcase" onChange='showresult(this.id);'>
	<option value="">--Select a Input Case--</option>
	
<?php
$userid = $_COOKIE['WLEUserId'];
		/*
		 * 
		 * Query SQL Server for the login of the user accessing the
		 * database.
		 */
$tsql = "SELECT * FROM ModelCase,Users WHERE ModelCase.UserId = Users.UserId and ModelCase.UserId = '".$userid."' ; ";
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
			
			echo "<option value=$id>Case $id Set up by $user at $date0 for $basin</option>";
		}
		
	sqlsrv_free_stmt( $stmt);
	/* Free statement and connection resources. */	
?>
</select>
</div>
<div class = "col-md-12">
<label for="ModelingCases">Results:</label>
<select name="Modelcase" id="Modelcase" onChange='showresult(this.id);'>
	<option value="">--Select a Input Case--</option>
	<option value = 'WaterSupply'>Water Supply</option>
	<option value = 'EvironmentalFlow'>Environmental Flow</option>
</select>
</div>

</div>
</div>

</div>

</html>