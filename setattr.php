<!-- This page is used to set attributes for a selected basin or agent.
     Redirected from StartAInutByWLETOOL.php.
     Case, basin, agent information passed through GET and COOKIE method.
-->
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Agent Based Model Web Based Application</title>

<!-- Bootstrap -->
<link href="./bootstrap/css/bootstrap.min.css" rel="stylesheet">

<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
<script src="http://code.jquery.com/jquery-1.10.2.js"></script>
<!-- Include all compiled plugins (below), or include individual files as needed -->
<script src="./bootstrap/js/bootstrap.min.js"></script>
<script src="home.js"></script>

<script src="setattr.js"></script>

<style>
#slider {
	margin: 10px;
}
</style>
<script src="http://code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
</head>
<?php
if (! isset ( $_COOKIE ['WLEUserId'] )) {
	header ( 'Location : Signin.php' );
}
?>
<?php

include "linkdatabase.php";
$userid = $_COOKIE ['WLEUserId'];
$basinid = $_GET ['basinid'];
if (isset ( $_GET ['CaseId'] )) {
	$caseid = $_GET ['CaseId'];
} else {
	if (isset ( $_COOKIE ['WLECaseId'] )) {	
		$caseid = $_COOKIE ['WLECaseId'];
	}
}
$agentid = $_GET ['agentid'];
$basin=$_GET['basin'];
?>

<div class="instructions">
	<h1>Please specify the following input variables.</h1>
	<?php if (isset($_GET['fault'])) echo "<p><font  color='red'> Failed to set variable value, same ranking exists!</font></p>"?>
	<p><strong> Note, rankings for hydropower, ecosystem and agriculture should be different!</strong></p>
</div>
<form
	action="setattrresult.php?CaseId=<?php echo $caseid;?>&basinid=<?php echo $_GET['basinid'];?>&agentid=<?php echo $_GET['agentid'];?>&basin=<?php echo $_GET['basin']?>"
	method='post'>
	<table class='table'>
		<tr>
			<th>Variables</th>
			<th>Default Value</th>
			<th>Current Value</th>
			<th>Change Value</th>
		</tr>
<?php
/*
 * Query SQL Server for the login of the user accessing the
 * database.
 */
$tsql = "SELECT * from Variables where AgentId = ".$_GET['agentid'].";";
$stmt = sqlsrv_query ( $conn, $tsql );
if ($stmt === false) {
	echo "Error in executing query.</br>";
	die ( print_r ( sqlsrv_errors (), true ) );
}

/* Retrieve and display the results of the query. */
while ( $row = sqlsrv_fetch_array ( $stmt ) ) {
	$id=$row[VarId];
	$tsql3 = "SELECT VarVal FROM InputLists where  CaseId=" . $caseid . " and AgentId=" . $agentid . " and VarId=" . $id . "; ";
	$stmt3 = sqlsrv_query ( $conn, $tsql3 , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	if ($stmt3 === false) {
		echo "Error in executing query.</br>";
		die ( print_r ( sqlsrv_errors (), true ) );
	} else {
		if (sqlsrv_num_rows ( $stmt3 ) > 0) {
			while ( $row1 = sqlsrv_fetch_array ( $stmt3 ) ) {
				$currentval = $row1 [VarVal];
			}
		} else {
			$currentval = $row [DefaultValue];
		}
		if ($row[InputType]===1){
		echo "<tr><td>".trim($row[VarName],' ')."</td><td>$row[DefaultValue]</td><td id = '$row[VarId]_varVal'>$currentval</td><td><input type='range' id='$row[VarId]_var' name='$row[VarId]_var'
			value = '$currentval' min='$row[MinVal]' max ='$row[MaxVal]' onchange = " . '"barOnChange(' . "'$row[VarId]_varVal','$row[VarId]_var'" . ');"/></td></tr>';
	}
	elseif ($row[InputType]===2){
		echo "<tr><td>".trim($row[VarName],' ')."</td><td>$row[DefaultValue]</td><td id = '$row[VarId]_varVal'>$currentval</td><td>";
		for($counttemp = $row[MinVal] ; $counttemp <= $row[MaxVal]; $counttemp++)
		{ 
			$checked = '';
			
			if ( $counttemp == $currentval)
			{
				$checked = " checked = 'checked' ";
			}
				
			echo "<input type='radio' id='$row[VarId]_var_$counttemp' name='$row[VarId]_var'
		value = '$counttemp' $checked $counttemp onchange = " . '"ratioOnChange(' . "'$row[VarId]_varVal','$row[VarId]_var'" . ');"/>'.$counttemp.'&nbsp&nbsp&nbsp';
			
		}
		echo '</td></tr>';
	}
	}
}
/* Free statement and connection resources. */
sqlsrv_free_stmt ( $stmt );
sqlsrv_free_stmt ( $stmt3 );
?>
</table>

	<hr />
<!-- 
	<h1>Select from following items to modify corresponding input
		variables.</h1>
	<label for="InputVariables">Variables:</label> <select name="ChangeVar"
		id="ChangeVariables">
		<option value="">--Select a Variable--</option>
<?php
		/*
		 * Query SQL Server for the login of the user accessing the
		 * database.
		
		$tsql = "SELECT * from ElectiveVariables;";
		$stmt = sqlsrv_query ( $conn, $tsql , array(), array( "Scrollable" => SQLSRV_CURSOR_FORWARD));
		if ($stmt === false) {
			echo "Error in executing query.</br>";
			die ( print_r ( sqlsrv_errors (), true ) );
		}
		
		/* Retrieve and display the results of the query. 
		while ( $row = sqlsrv_fetch_array ( $stmt ) )
		{
			echo "<option value=$row[VarId]_var>$row[VarName]</option>";
		}
			/* Free statement and connection resources. 
	sqlsrv_free_stmt( $stmt);
	/* Free statement and connection resources. */	
?>
</select> <input type="button" name="SelectVar"
		onclick="SelectAndChange(<?php echo "'".$userid."','".$basinid."','".$agentid."','".$caseid."','".$basin."'"?>);" value="Select and Change Value" />
	<div class="AddedVars">
		<table id="AddedVarsList" class='table'>
			<tr>
				<th>Variables</th>
				<th>Default Value</th>
				<th>Current Value</th>
				<th>Change Value</th>
			</tr>
		</table>
	</div>
	<hr /> -->
	<input type="submit" value="Submit" />
</form>

</html>

<?php 
sqlsrv_close( $conn);
?>






