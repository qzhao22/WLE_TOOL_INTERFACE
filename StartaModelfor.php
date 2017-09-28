<!-- This page lists all basins available.
     This page is redirected by choosing the negotiation mode.     
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
<script src="http://code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
<script src = "home.js"></script>

<style>
#slider {
	margin: 10px;
}
</style>
</head>
<body>
<?php
include 'Title.php';

?>
<!-- Ask users to choose a basin to begin their model input. -->
<h1>Start a Modelling Case</h1>
<h2>Click on the following links to start a modelling case for:</h2>
<div class = 'col-md-3'>
</div>
<div class='col-md-4'>
<h2><a href = 'RunAModelByWLETOOL.php?basin=Mekong&w=<?php echo $_GET['w'];?>&h=<?php echo $_GET['h'];?>'>The Mekong Basin</a>
</h2></div>