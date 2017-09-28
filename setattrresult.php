<!-- This page is a background code.
     Used to insert the basin or agent attributes submitted from setattr.php to the database.
-->
<?php
include "linkdatabase.php";
if ($conn === false) {
	echo "Could not connect.\n";
	die ( print_r ( sqlsrv_errors (), true ) );
}

$tsql = "SELECT * FROM Variables  ; ";
$mul = 1;
$stmt = sqlsrv_query ( $conn, $tsql );
if ($stmt === false) {
	echo "Error in retrieving row.\n";
	die ( print_r ( sqlsrv_errors (), true ) );
}

while ( $row = sqlsrv_fetch_array ( $stmt ) ) {
	$id = $row [VarId];
	$sub = $id . "_var";
	if (fmod ( $row [VarId], 4 ) != 1) {
		if (isset ( $_POST [$sub] )) {
			$mul = $mul * $_POST [$sub];
		}
	}
}
if ($mul != 6) {
	header("Location:setattr.php?agentid=".$_GET ['agentid']."&CaseId=".$_GET ['CaseId']."&basin=".$_GET ['basin']."&fault=1");
} else {
	$stmt = sqlsrv_query ( $conn, $tsql );
	if ($stmt === false) {
		echo "Error in retrieving row.\n";
		die ( print_r ( sqlsrv_errors (), true ) );
	}
	
	while ( $row = sqlsrv_fetch_array ( $stmt ) ) {
		$id = $row [VarId];
		$sub = $id . "_var";
		$defval = $_row ['DefaultValue'];
		if (isset ( $_POST [$sub] )) {
			$userid = $_COOKIE ['WLEUserId'];
			$basinid = $_GET ['basinid'];
			$caseid = $_GET ['CaseId'];
			$agentid = $_GET ['agentid'];
			$varval = $_POST [$sub];
			
			$tsql2 = "SELECT count(*) FROM InputLists where CaseId=" . $caseid . " and AgentId=" . $agentid . " and VarId=" . $id . " and Varval=" . $varval . "; ";
			$stmt2 = sqlsrv_query ( $conn, $tsql2 );
			if (sqlsrv_fetch ( $stmt2 ) === false) {
				echo "Error in retrieving row.\n";
				die ( print_r ( sqlsrv_errors (), true ) );
			}
			$tsql3 = "SELECT count(*) FROM InputLists where CaseId=" . $caseid . " and AgentId=" . $agentid . " and VarId=" . $id . "; ";
			$stmt3 = sqlsrv_query ( $conn, $tsql3 );
			if (sqlsrv_fetch ( $stmt3 ) === false) {
				echo "3Error in retrieving row.\n";
				die ( print_r ( sqlsrv_errors (), true ) );
			}
			
			$num2 = sqlsrv_get_field ( $stmt3, 0 );
			if ($_POST [$sub] == $row [DefaultValue]) {
				if ($num2 > 0) {
					$tsql6 = "DELETE FROM InputLists where CaseId=" . $caseid . " and AgentId=" . $agentid . " and VarId=" . $id . "; ";
					$stmt6 = sqlsrv_query ( $conn, $tsql6 );
				}
			} else {
				$num = sqlsrv_get_field ( $stmt2, 0 );
				if ($num === 0) {
					$tsql3 = "SELECT count(*) FROM InputLists where CaseId=" . $caseid . " and AgentId=" . $agentid . " and VarId=" . $id . "; ";
					$stmt3 = sqlsrv_query ( $conn, $tsql3 );
					if (sqlsrv_fetch ( $stmt3 ) === false) {
						echo "3Error in retrieving row.\n";
						die ( print_r ( sqlsrv_errors (), true ) );
					}
					
					$num2 = sqlsrv_get_field ( $stmt3, 0 );
					if ($num2 === 0) {
						/* Set up the parameterized query. */
						$tsql4 = "INSERT INTO InputLists(CaseId,AgentId,VarId,VarVal) VALUES('" . $caseid . "','" . $agentid . "','" . $id . "','" . $varval . "'); ";
						/* Prepare and execute the query. */
						$stmt4 = sqlsrv_query ( $conn, $tsql4 );
						if ($stmt4) {
							echo $tsql4;
						} 

						else {
							echo "Row insertion failed.\n";
							die ( print_r ( sqlsrv_errors (), true ) );
						}
					} else { /* Set up the parameterized query. */
						$tsql5 = "UPDATE  InputLists SET VarVal=" . $varval . " where CaseId=" . $caseid . " and AgentId=" . $agentid . " and VarId=" . $id . "; ";
						/* Prepare and execute the query. */
						
						$stmt5 = sqlsrv_query ( $conn, $tsql5 );
						if ($stmt5) {
						} 

						else {
							echo "Row Update failed.\n";
							die ( print_r ( sqlsrv_errors (), true ) );
						}
					}
				}
			}
		}
	}
	sqlsrv_free_stmt ( $stmt );
	sqlsrv_free_stmt ( $stmt2 );
	sqlsrv_free_stmt ( $stmt3 );
	sqlsrv_free_stmt ( $stmt4 );
	sqlsrv_free_stmt ( $stmt5 );
	
	/*
	 * $tsql = "SELECT * FROM ElectiveVariables; ";
	 *
	 * $stmt = sqlsrv_query ( $conn, $tsql );
	 * if ($stmt === false) {
	 * echo "1Error in retrieving row.\n";
	 * die ( print_r ( sqlsrv_errors (), true ) );
	 * }
	 * while ( $row = sqlsrv_fetch_array ( $stmt ) ) {
	 * $id = $row [VarId];
	 * $sub = $id . "_var";
	 * echo $id;
	 * if (isset ( $_POST [$sub] )) {
	 * $userid = $_COOKIE ['WLEUserId'];
	 * $basinid = $_GET ['basinid'];
	 * $caseid = $_GET ['CaseId'];
	 * $agentid = $_GET ['agentid'];
	 * $varval = $_POST [$sub];
	 * $tsql2 = "SELECT count(*) FROM InputLists where BasinId=" . $basinid . " and CaseId=" . $caseid . " and AgentId=" . $agentid . " and VarId=" . $id . " and Varval=" . $varval . "; ";
	 * $stmt2 = sqlsrv_query ( $conn, $tsql2 );
	 * if (sqlsrv_fetch ( $stmt2 ) === false) {
	 * echo "2Error in retrieving row.\n";
	 * die ( print_r ( sqlsrv_errors (), true ) );
	 * }
	 *
	 * $num = sqlsrv_get_field ( $stmt2, 0 );
	 * if ($num === 0) {
	 * $tsql3 = "SELECT count(*) FROM InputLists where BasinId=" . $basinid . " and CaseId=" . $caseid . " and AgentId=" . $agentid . " and VarId=" . $id . "; ";
	 * $stmt3 = sqlsrv_query ( $conn, $tsql3 );
	 * if (sqlsrv_fetch ( $stmt3 ) === false) {
	 * echo "3Error in retrieving row.\n";
	 * die ( print_r ( sqlsrv_errors (), true ) );
	 * }
	 *
	 * $num2 = sqlsrv_get_field ( $stmt3, 0 );
	 * // echo $num2;
	 * if ($num2 === 0) {
	 * /* Set up the parameterized query.
	 * $tsql4 = "INSERT INTO InputLists(CaseId,AgentId,VarId,Varval,BasinId) VALUES('" . $caseid . "','" . $agentid . "','" . $id . "','" . $varval . "','" . $basinid . "') ";
	 * /* Prepare and execute the query.
	 * echo $tsql4;
	 * $stmt4 = sqlsrv_query ( $conn, $tsql4 );
	 * if ($stmt) {
	 * }
	 *
	 * else {
	 * echo "4Row insertion failed.\n";
	 * die ( print_r ( sqlsrv_errors (), true ) );
	 * }
	 * } else { /* Set up the parameterized query.
	 * $tsql5 = "UPDATE InputLists SET VarVal=" . $varval . " where BasinId=" . $basinid . " and CaseId=" . $caseid . " and AgentId=" . $agentid . " and VarId=" . $id . "; ";
	 * /* Prepare and execute the query.
	 *
	 * $stmt5 = sqlsrv_query ( $conn, $tsql5 );
	 * if ($stmt) {
	 * }
	 *
	 * else {
	 * echo "5Row Update failed.\n";
	 * die ( print_r ( sqlsrv_errors (), true ) );
	 * }
	 * }
	 * }
	 * }
	 * }
	 *
	 * sqlsrv_free_stmt ( $stmt );
	 * sqlsrv_free_stmt ( $stmt2 );
	 * sqlsrv_free_stmt ( $stmt3 );
	 * sqlsrv_free_stmt ( $stmt4 );
	 * sqlsrv_free_stmt ( $stmt5);
	 */
	
	echo "<script>window.close();</script>";
}
sqlsrv_close ( $conn );
?>