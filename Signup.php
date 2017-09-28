<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- This page is the signup page for the website. Users are required to sign up to start a model. -->

<!-- Title of this webpage. -->
<title>Sign Up for Agent Based Model Web Based Application</title>
<meta name="description" content="Agent Based Model Web Based Application.">
<!-- Bootstrap -->
<link href="./bootstrap/css/bootstrap.min.css" rel="stylesheet">

<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
<script src="http://code.jquery.com/jquery-1.10.2.js"></script>
<script src="./bootstrap/js/bootstrap.min.js"></script>

</head>
<body>
<div class='col-md-12'>
<!-- Following contains the signup sheet for this website. -->
<div class="jumbotron">
<h1>WLE-BASIN TOOL</h1>
</div>
</div>
	<div class="container">
		<div class="row">
			<div class='col-md-4'></div>
			<div class="col-md-4">
			<!-- Check whether this page is returned from a failure of previous trial of signup. -->
					<?php
					if (isset ( $_GET ['emailused'] )) {
						echo "<p><font color='red'><strong>Email have be used. Try another email or <a href = 'Signin.php'>login</a>.<strong></font></p>";
					}
					?>
					 <form role="form" action = 'SignupResult.php' method = 'post'>
					<h2 class="form-signin-heading">Sign up</h2>

					<div class="well well-sm">
						<strong><span class="glyphicon glyphicon-asterisk"></span>Required
							Field</strong>
					</div>
					<div class="form-group">
						<label for="InputName">Enter Name</label>
						<div class="input-group">
							<input type="text" class="form-control" name="InputName"
								id="InputName" placeholder="Enter Name" required> <span
								class="input-group-addon"><span
								class="glyphicon glyphicon-asterisk"></span></span>
						</div>
					</div>
					<div class="form-group">
						<label for="InputEmail">Enter Email</label>
						<div class="input-group">
							<input type="email" class="form-control" id="InputEmailFirst"
								name="InputEmail" placeholder="Enter Email" required> <span
								class="input-group-addon"><span
								class="glyphicon glyphicon-asterisk"></span></span>
						</div>
					</div>
					<div class="form-group">
						<label for="InputEmail">Confirm Email</label>
						<div class="input-group">
							<input type="email" class="form-control" id="InputEmailSecond"
								name="InputEmail" placeholder="Confirm Email" required onChange="CompareEmail();"> <span
								class="input-group-addon"><span
								class="glyphicon glyphicon-asterisk"></span></span>
						</div>
					</div>
					<div class="form-group">
						<label for="InputPwd">Input Password</label>
						<div class="input-group">
							<label for="inputPassword" class="sr-only">Password</label> <input
								type="password" id="inputPassword1" class="form-control"
								name = 'inputPassword' placeholder="Password" required> <span class="input-group-addon"><span
								class="glyphicon glyphicon-asterisk"></span></span>
						</div>
					</div>

					<div class="form-group">
						<label for="InputPwd">Confirm Password</label>
						<div class="input-group">
							<label for="inputPassword" class="sr-only">Confirm Password</label>
							<input type="password" id="inputPassword2" class="form-control" placeholder="Confirm Password" required> 
								<span class="input-group-addon">
								<span class="glyphicon glyphicon-asterisk"></span></span>
						</div>
					</div>
					<input type="submit" name="submit" id="submit" value="Submit"	class="btn btn-info pull-right">
				</form>
			</div>

		</div>
	</div>
	<!-- End of Signup Sheet. -->
</body>
</html>