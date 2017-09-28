<!-- A form to submit contact request -->
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="description"
	content="Agent Based Model Web Based Application - Contact Us.">
<!-- Bootstrap -->
<link href="./bootstrap/css/bootstrap.min.css" rel="stylesheet">
<script>
</script>
<title>ABM WEB - Contact Us</title>
</head>
<body>

<?php 
include "Title.php"
?>
<div class="col-md-12">
<h1>
Contact Us
</h1>

<form name="form1" method="get" action="ContactResult.php">
<table class = 'table'>
   <tr><td><b>Your Name</b></td><td>
   <input type="text" name="from" size="35">
   </td></tr>
   <tr><td><b>Your Email</b></td><td>
   <input type="email" name="email" size="35">
   </td></tr>
   <tr><td><b>Subject</b></td>
     <td><input type="text" name="mailsubject" size="35"></td>
   </tr>
   <tr><td><b>Message</b></td>
     <td>
  <textarea name="mailbody" cols="50" rows="7"></textarea>
  </td>
   </tr>
   <tr><td colspan="2">
      <input type="submit" name="Submit" value="Send">
     </td>
   </tr>
  </table>
</form>
</div>

</body>
</html>