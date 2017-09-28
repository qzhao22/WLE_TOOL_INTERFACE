<!-- Then main menu of the website -->
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- This page is the homepage of the website, users can view different functional modules in this page. -->

<!-- Title of the website -->
<title>Agent Based Model Web Based Application</title>

<meta name="description" content="Agent Based Model Web Based Application.">
<!-- Bootstrap -->
<link href="./bootstrap/css/bootstrap.min.css" rel="stylesheet">

<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
<script src="http://code.jquery.com/jquery-1.10.2.js"></script>
<script src="./bootstrap/js/bootstrap.min.js"></script>
<script src="http://code.jquery.com/ui/1.11.4/jquery-ui.js"></script>

<!-- home.js includes all other js functions for this page. -->
<script src = "home.js"></script>

</head>
<body>


<!-- Title.php includes some common components for all pages. -->
<?php 
include 'Title.php';
?>

<!-- Name and introduction to the website is included here. -->
<div class = "col-md-12"><br/>
<h1>Welcome to WLE TOOL Website</h1>
<br/>
<p>WLE TOOl is a hydrologic modeling tool using agent based model to help stake holders to understand the behaviour of water resources systems under the inference of human beings.</p>


<!-- Following codes give description and buttons to different modules of the website. -->

<!-- Start new input -->
<hr>
<div class='row'>
<div class='col-md-4'>
<h2>Start New Input</h2>
<p>Click the following button to start setting up new input.</p>
<button onclick = "StartAInput();">Start a Input</button>
<br/>
</div>

<!-- Manage previous inputs. -->
<div class='col-md-4'>
<h2>Manage Previous Inputs</h2>
<p>Click the following button to view, manage and further change your previous inputs.</p>
<p>You can also view default input values and inputs cases set by other users which is set visible to public here.</p>
<button onclick = "ManageInputs();">View Inputs</button>
<br/>

<!-- Start Modelling. -->
</div>
<div class='col-md-4'>
<h2>Negotiation Modelling</h2>
<p> Click the following button to start modeling, negotiation means this model could include different input cases from different users.</p>
<button onclick = "StartAModel();">Start a Negotiation</button></div>
</div>
<hr>
<div class='row'>
<div class='col-md-4'>
<h2>Scenario Modelling</h2>
<p> Click the following button to start modeling, scenario means this model include one input case.</p>
<button onclick = "StartASModel();">Start a Scenario</button>
</div>
<!-- View results of finished cases. -->

<div class='col-md-4'>
<h2>View Previous Results</h2>
<p>Click the following button to view previous results.</p>
<button onclick = "ViewPreResults();">View Results</button>
<br/>
</div>

<!-- Compare results from different inputs. -->
<div class='col-md-4'>
<h2>Compare Results</h2>
<p>Click the following button to compare results from different modeling case.</p>
<button onclick = "CompareResults();">Compare Results</button>
<br/>
</div>

</div>
<!-- End of functional module section. -->
<hr>
</div>
</body>
</html>

