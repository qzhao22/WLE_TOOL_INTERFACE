<!--  Used to execute model after an execution request has been submitted. -->

<?php
ini_set ( 'max_execution_time', 36000 );
set_time_limit ( 0 );
$caseid = $_GET ['Cid'];
$modelfolder = "./1023_ABM_SWAT/";
$modeldir = $modelfolder . 'ABM_SWAT_1023.R';
$folderDir = "./Case/" . $caseid;
$folderStatus = mkdir ( $folderDir );
$thisfolder = 0;

/* prepare input files for ABM-SWAT model.*/
if ($folderStatus == TRUE) {
	include "linkdatabase.php";
	header ( "Cache-Control: no-cache, must-revalidate" );
	if ($conn === false) {
		echo "Could not connect.\n";
		die ( print_r ( sqlsrv_errors (), true ) );
	}
	$myfile = fopen ( $folderDir . "/User_ESS.csv", "w" ) or die ( "Unable to open file!" );
	fwrite ( $myfile, 'Agent_ID,LOC,AG,HP,ECO' . chr ( 13 ) . chr ( 10 ) );
	
	$tsql = "SELECT * from Variables ORDER BY VarId;";
	$stmt = sqlsrv_query ( $conn, $tsql );
	if ($stmt === false) {
		echo "Error in executing query.</br>";
		die ( print_r ( sqlsrv_errors (), true ) );
	}
		
		/* Retrieve and display the results of the query. */
	while ( $row [1] = sqlsrv_fetch_array ( $stmt ) ) {
		$row [2] = sqlsrv_fetch_array ( $stmt );
		$row [3] = sqlsrv_fetch_array ( $stmt );
		$row [4] = sqlsrv_fetch_array ( $stmt );
		
		$tsql2 = "SELECT InputId FROM ModelLists where  CaseId=" . $caseid . " ORDER BY ItemId; ";
		$stmt2 = sqlsrv_query ( $conn, $tsql2 );
		if ($stmt2 === false) {
			echo "Error in executing query.</br>";
			die ( print_r ( sqlsrv_errors (), true ) );
		}
		
		$linestr = $row [1] [AgentId];
		$current [1] = $row [1] [DefaultValue];
		$current [2] = $row [2] [DefaultValue];
		$current [3] = $row [3] [DefaultValue];
		$current [4] = $row [4] [DefaultValue];
		$currstr = $linestr . ',' . $current [1] . ',' . $current [2] . ',' . $current [3] . ',' . $current [4];
		
		/* Retrieve and display the results of the query. */
		while ( $row3 = sqlsrv_fetch_array ( $stmt2 ) ) {
			
			$check = 0;
			$linestr = $row [1] [AgentId];
			$current [1] = $row [1] [DefaultValue];
			$current [2] = $row [2] [DefaultValue];
			$current [3] = $row [3] [DefaultValue];
			$current [4] = $row [4] [DefaultValue];
			
			for($vari = 1; $vari < 5; $vari ++) {
				for($i = 1; $i < 5; $i ++) {
					if (fmod ( $row [$i] [VarId], 4 ) == fmod ( $vari, 4 )) {
						$currentval = $row [$i] [DefaultValue];
						$currid = $row [$i] [VarId];
						$agentid = $row [$i] [AgentId];
						$inid = $row3 [InputId];
						$tsql3 = "SELECT VarVal FROM InputLists where  CaseId=" . $inid . " and AgentId=" . $agentid . " and VarId=" . $currid . "; ";
						$stmt3 = sqlsrv_query ( $conn, $tsql3, array (), array (
								"Scrollable" => SQLSRV_CURSOR_KEYSET 
						) );
						if ($stmt3 === false) {
							echo "Error in executing query.</br>";
							die ( print_r ( sqlsrv_errors (), true ) );
						} else {
							if (sqlsrv_num_rows ( $stmt3 ) > 0) {
								while ( $row1 = sqlsrv_fetch_array ( $stmt3 ) ) {
									$current [$i] = $row1 [VarVal];
									$check = 1;
								}
							}
						}
					}
				}
			}
			if ($check == 1) {
				$currstr = $linestr . ',' . $current [1] . ',' . $current [2] . ',' . $current [3] . ',' . $current [4];	
			}
		}
		fwrite ( $myfile, $currstr . chr ( 13 ) . chr ( 10 ) );
	}
	/* Free statement and connection resources. */
	sqlsrv_free_stmt ( $stmt );
	sqlsrv_free_stmt ( $stmt3 );
	sqlsrv_free_stmt ( $stmt2 );
	
	fclose ( $myfile );
	$tsql5 = "SELECT count(*) FROM Status where Status = 1; ";
	$stmt5 = sqlsrv_query ( $conn, $tsql5 );
	if (sqlsrv_fetch ( $stmt5 ) === false) {
		echo "3Error in retrieving row.\n";
		die ( print_r ( sqlsrv_errors (), true ) );
	}
	$tsql4 = "INSERT INTO Status(CaseId,Status) VALUES('" . $caseid . "','0'); ";
	/* Prepare and execute the query. */
	$stmt4 = sqlsrv_query ( $conn, $tsql4 );
	if ($stmt4) {
	} else {
		echo "Row insertion failed.\n";
		die ( print_r ( sqlsrv_errors (), true ) );
	}
	$num5 = sqlsrv_get_field ( $stmt5, 0 );
	if ($num5 == 0) {
		$statu = 0;
		while ( $statu == 0 ) {
			$tsql6 = "SELECT count(*) FROM Status where Status = 1; ";
			$stmt6 = sqlsrv_query ( $conn, $tsql6 );
			if (sqlsrv_fetch ( $stmt6 ) === false) {
				echo "3Error in retrieving row.\n";
				die ( print_r ( sqlsrv_errors (), true ) );
			}
			$num6 = sqlsrv_get_field ( $stmt6, 0 );
			
			if ($num6 > 1) {
				$statu = 1;
			} else {
				sqlsrv_free_stmt ( $stmt6 );
				
				$tsql7 = "UPDATE  Status SET Status = 1 where CaseId = " . $caseid . "; ";
				/* Prepare and execute the query. */
				
				$stmt7 = sqlsrv_query ( $conn, $tsql7 );
				if ($stmt7) {
				} 

				else {
					echo "Row Update failed.\n";
					die ( print_r ( sqlsrv_errors (), true ) );
				}
				
				$tsql6 = "SELECT count(*) FROM Status where Status = 1; ";
				$stmt6 = sqlsrv_query ( $conn, $tsql6 );
				if (sqlsrv_fetch ( $stmt6 ) === false) {
					echo "3Error in retrieving row.\n";
					die ( print_r ( sqlsrv_errors (), true ) );
				}
				$num6 = sqlsrv_get_field ( $stmt6, 0 );
				
				if ($num6 > 1) {
					$tsql8 = "UPDATE  Status SET Status = 0 where CaseId = " . $caseid . "; ";
					/* Prepare and execute the query. */
					
					$stmt8 = sqlsrv_query ( $conn, $tsql8 );
					if ($stmt8) {
					} 

					else {
						echo "Row Update failed.\n";
						die ( print_r ( sqlsrv_errors (), true ) );
					}
				} elseif ($num6 == 1) {
					$statu = 1;
					$currentfolder = $folderDir;
					$thisfolder = 1;
					$currentcase = $caseid;
				}
			}
		}
		/* run the model*/
		if ($thisfolder == 1) {
			$nopending = 0;
			while ( $nopending == 0 ) {
				rename ( $currentfolder . '/User_ESS.csv', $modelfolder . 'User_ESS.csv' );
				$rcommand = 'Rscript ' . $modeldir;
				system("cmd /c r.bat");
				//exec('Rscript ./1010_ABM_SWAT/ABM_SWAT_1010.R',$out);
				copy ( $modelfolder . 'eco_summary.csv', $currentfolder . '/eco_summary.csv' );
				copy ( $modelfolder . 'crop_summary.csv', $currentfolder . '/crop_summary.csv' );
				copy ( $modelfolder . 'hydropower_summary.csv', $currentfolder . '/hydropower_summary.csv' );
				rename ( $modelfolder . 'User_ESS.csv', $currentfolder . '/User_ESS.csv' );
				$tsql8 = "SELECT count(*) FROM Status where Status < 2; ";
				$stmt8 = sqlsrv_query ( $conn, $tsql8 );
				if (sqlsrv_fetch ( $stmt8 ) === false) {
					echo "3Error in retrieving row.\n";
					die ( print_r ( sqlsrv_errors (), true ) );
				}
				
				$num8 = sqlsrv_get_field ( $stmt8, 0 );
				$num8 = $num8 - 1;
				
				if ($num8 == 0) {
					$tsql11 = "UPDATE  Status SET Status = 2 where CaseId = " . $currentcase . "; ";
					/* Prepare and execute the query. */
						
					$stmt11 = sqlsrv_query ( $conn, $tsql11 );
					if ($stmt11) {
					}
					
					else {
						echo "Row Update failed.\n";
						die ( print_r ( sqlsrv_errors (), true ) );
					}
					$nopending = 1;
				} else {
					$tsql9 = "SELECT CaseId FROM Status where Status = 0; ";
					$stmt9 = sqlsrv_query ( $conn, $tsql9 );
					if ($stmt9 === false) {
						echo "Error in executing query.</br>";
						die ( print_r ( sqlsrv_errors (), true ) );
					}
					
					/* Retrieve and display the results of the query. */
					$row9 = sqlsrv_fetch_array ( $stmt9 );
					$currentfolder = "Case/" . $row9 [CaseId];
					$tsql10 = "UPDATE  Status SET Status = 1 where CaseId = " . $row9 [CaseId] . "; ";
					/* Prepare and execute the query. */
					
					$stmt10 = sqlsrv_query ( $conn, $tsql10 );
					if ($stmt10) {
					} 

					else {
						echo "Row Update failed.\n";
						die ( print_r ( sqlsrv_errors (), true ) );
					}
					$tsql11 = "UPDATE  Status SET Status = 2 where CaseId = " . $currentcase . "; ";
					/* Prepare and execute the query. */
					
					$stmt11 = sqlsrv_query ( $conn, $tsql11 );
					if ($stmt11) {
					} 

					else {
						echo "Row Update failed.\n";
						die ( print_r ( sqlsrv_errors (), true ) );
					}
					$currentcase = $row9 [CaseId];
				}
			}
		}
	}
} else {
	echo " Model case could not be generated! Please check existing model case!";
}
sqlsrv_free_stmt ( $stmt4 );
sqlsrv_free_stmt ( $stmt5 );
sqlsrv_free_stmt ( $stmt6 );
sqlsrv_free_stmt ( $stmt7 );
sqlsrv_free_stmt ( $stmt8 );
sqlsrv_free_stmt ( $stmt9 );
sqlsrv_free_stmt ( $stmt10 );
sqlsrv_free_stmt ( $stmt11 );
?>