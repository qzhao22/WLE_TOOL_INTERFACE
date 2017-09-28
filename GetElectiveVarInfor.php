<!-- Not being Used in current version -->

<?php
include "linkdatabase.php";
$varid = $_GET['Name'];
$varid = explode('_',$varid);
$varid = $varid[0];
$userid = $_GET['uid'];
$agentid = $_GET['aid'];
$basinid = $_GET['bid'];
$basin = $_GET['ba'];
$caseid = $_GET['cid'];
$tsql = "SELECT * FROM ElectiveVariables WHERE VarId = " . $varid . ";";

$stmt = sqlsrv_query ( $conn, $tsql );

/* Execute the query. */
if ($stmt === false) {
	echo "Error in statement execution.\n";
	die ( print_r ( sqlsrv_errors (), true ) );
} 

else {
	while ( $row = sqlsrv_fetch_array ( $stmt ) ) {
		$id=$row[VarId];
		$tsql3 = "SELECT VarVal FROM InputLists where BasinId=" . $basinid . " and CaseId=" . $caseid . " and AgentId=" . $agentid . " and VarId=" . $id . "; ";
		echo $tsql3;
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
		echo "<tr><td>$row[VarName]</td><td>$row[DefaultValue]</td><td id = '$row[VarId]_varVal'>$currentval</td><td><input type='range' id='$row[VarId]_var' name='$row[VarId]_var' 
			value = '$currentval' min='$row[MinVal]' max ='$row[MaxVal]' onchange = " . '"barOnChange(' . "'$row[VarId]_varVal','$row[VarId]_var'" . ');"/></td></tr>';
	}
}
}
sqlsrv_free_stmt($stmt);
sqlsrv_close($conn);
?>

