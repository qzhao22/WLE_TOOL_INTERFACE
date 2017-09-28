<!-- Login page -->

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
<script src = "home.js"></script>

<style>
#slider {
	margin: 10px;
}
</style>
<script src="http://code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
</head>
<body>
<?php 
include 'Title.html';
?>
<div class = "col-md-12"><br/>

<h1>Welcome to WLE TOOL Website</h1>
<br/>
<p>WLE TOOl is a hydrologic modeling tool using agent based model to help stake holders to understand the behaviour of water resources systems under the inference of human beings.</p>
<br/>
<br/><p>Before starting, please <a href = 'Signin.php'>login</a> to your account. Or <a href = 'Signup.php'>sign up</a> for a new account if you do not have one.</p>
<br/>
<button onclick = "Tosignup();">Sign Up</button>
<button onclick = "Tosignin();">LogIn</button>
</div>


</body>