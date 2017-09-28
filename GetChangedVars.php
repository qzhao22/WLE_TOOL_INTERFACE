<!-- Find changed variable for a basin in an input case -->
<?php
$caseid = $_GET['CaseId'];
$agentid = $_GET['agentid'];
$basinid = $_GET['basinid'];
include "linkdatabase.php";
if ($conn === false) {
	echo "Could not connect.\n";
	die ( print_r ( sqlsrv_errors (), true ) );
}
?>
<h3>Agent<?php echo $agentid;?></h3><?php
$tsql = "SELECT * FROM InputLists,Variables  WHERE InputLists.VarId = Variables.VarId and InputLists.CaseId = '".$caseid."' and InputLists.AgentId='".$agentid."' ; ";
$stmt = sqlsrv_query ( $conn, $tsql , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
//$tsql2 = "SELECT * FROM InputLists,ElectiveVariables  WHERE InputLists.VarId = ElectiveVariables.VarId and InputLists.CaseId = '".$caseid."' and InputLists.AgentId='".$agentid."' and InputLists.BasinId='".$basinid."' ; ";
//$stmt2 = sqlsrv_query ( $conn, $tsql2 , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
if($stmt === false )
{
	echo "Error in retrieving row.\n";
	die( print_r( sqlsrv_errors(), true));
}
/*if($stmt2 === false )
{
	echo "Error in retrieving row.\n";
	die( print_r( sqlsrv_errors(), true));
}*/
//if(sqlsrv_num_rows($stmt)+sqlsrv_num_rows($stmt2)<1)
if(sqlsrv_num_rows($stmt)<1)
	echo "All Variables Unchanged!";
else{
	?>
	<tr><th>Variable Name</th><th>Default Value</th><th>Current Value</th></tr>
	<?php 
	while ( $row = sqlsrv_fetch_array ( $stmt ) ) {
		?>
		<tr><td><?php  echo $row[VarName];?></td><td><?php echo $row[DefaultValue];?></td><td><?php echo $row[VarVal];?></td></tr>
		<?php
	}
/*	while ( $row = sqlsrv_fetch_array ( $stmt2 ) ) {
		?>
			<tr><td><?php echo $row[VarName];?></td><td><?php echo $row[DefaultValue];?></td><td><?php echo $row[VarVal];?></td></tr>
			<?php
		}*/
	
}
sqlsrv_free_stmt($stmt); 
//sqlsrv_free_stmt($stmt2);
sqlsrv_close($conn);
?>