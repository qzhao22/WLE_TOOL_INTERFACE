function SelectAndChange(a,b,c,d,e){
	var varopt = document.getElementById("ChangeVariables");
	var varname = varopt.options[varopt.selectedIndex].value;
	if (varopt.options[varopt.selectedIndex].value!==''){
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange = function() {
			varopt.options[varopt.selectedIndex].disabled = "disabled";
			if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
				$("#AddedVarsList").append(xmlhttp.responseText);
			};
		};
		xmlhttp.open("GET", "GetElectiveVarInfor.php?Name="+varname+"&uid="+a+"&bid="+b+"&aid="+c+"&cid="+d+"&ba="+e, true);
		xmlhttp.send();

	}
	varopt.selectedIndex = 0;
}
function barOnChange(texid,barid){
	var tex = document.getElementById(texid);
	var bar = document.getElementById(barid);
	tex.innerHTML = bar.value;
}
function ratioOnChange(a,b)
{
	var tex = document.getElementById(a);
	var radio = document.getElementsByName(b);
    for (i=0; i<radio.length; i++) {  
        if (radio[i].checked) {  
         	tex.innerHTML = radio[i].value ; 
        }  
    }  
}