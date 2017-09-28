function ChangeScenarios(x) {
// Used in StartAInPutByWLETOOL.php
	var Map = document.getElementById('BasinMapId');
	var selectItem = document.getElementById(x);
	var width=window.screen.height;
	var height=window.screen.width;
	
	if(selectItem.options[selectItem.selectedIndex].value==="")
		Map.removeAttribute("src");
	else{
		$(".inputinformation").show();
		var myDate = new Date();
		var time = myDate.toLocaleDateString();
		document.getElementById("creatingtime").innerHTML = time;
		document.getElementById("Basinname").innerHTML=selectItem.options[selectItem.selectedIndex].value;
		Map.src = "./BasinMaps/"+selectItem.options[selectItem.selectedIndex].value+'.jpg';
		Map.useMap = "#"+selectItem.options[selectItem.selectedIndex].value+"MapArea";
		selectItem.disabled = "disabled";
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
				document.getElementById('inputId').innerHTML = xmlhttp.responseText;
			};
		};
		xmlhttp.open("GET", "GetNewInputCaseId.php?basinname="+selectItem.options[selectItem.selectedIndex].value, true);
		xmlhttp.send();
	}

}
function ChangeScenario(x) {
	var selectItem = document.getElementById(x);
    selectItem.disabled = "disabled";

}

// Used to change the visibility of a given case 
function ChangeVisibility(){
	var xmlhttp = new XMLHttpRequest();
	xmlhttp.onreadystatechange = function() {
		if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
			alert("Change Submitted!");
		};
	};
	xmlhttp.open("GET", "VisibilityChange.php?caseid="+document.getElementById('inputId').innerHTML+"&status="+document.getElementById('visi').checked, true);
	xmlhttp.send();
}

// Used to add new notes to a given input case
function submitnotes(){
	var xmlhttp = new XMLHttpRequest();
	xmlhttp.onreadystatechange = function() {
		if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
			alert("Change Submitted!");
		};
	};
	xmlhttp.open("GET", "NotesChange.php?caseid="+document.getElementById('inputId').innerHTML+"&status="+document.getElementById('notes').value, true);
	xmlhttp.send();
}

// To open the sign up page.
function Tosignup(){
	var myWindow = window.open("Signup.php",'_self');
}

// To open the signin page.
function Tosignin(){
	var myWindow = window.open("Signin.php",'_self');
}

// Used in StartAInputByWLETOOL.php to clear exsting case and start a new case
function ClearSettings(){
	var selectItem = document.getElementById("Scenarios");
	selectItem.removeAttribute("disabled");
	var Map = document.getElementById('BasinMapId');
	Map.removeAttribute('src');
	Map.removeAttribute('useMap');
	selectItem.selectedIndex=0;
	$(".inputinformation").hide();
	}

// Used to get a previous input list
function ManageInputs(){
	var width = window.screen.height;
	var height=window.screen.width;
	var myWindow = window.open("Preinputlist.php?w="+width+"&h="+height,'_self','');
}

// Used to get the information of a given input case id
function inputcaseinfor(x){
	var selectItem = document.getElementById(x);
	var width=window.screen.height;
	var height=window.screen.width;
	var infortable = document.getElementById('inputcaseinfor');
	if(selectItem.options[selectItem.selectedIndex].value==="")
		infortable.innerHTML='';
	else{
		
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
				infortable.innerHTML = "<tr> <th> Input Case Id</th><th>Basin</th><th>Set-up User</th><th>Set-up Date</th><th>Visibility to Public</th><th>Description</th></tr>"+xmlhttp.responseText;
			};
		};
		xmlhttp.open("GET", "Getinputcaseinfor.php?caseid="+selectItem.options[selectItem.selectedIndex].value, true);
		xmlhttp.send();
	}
}
// Used to link a input case to a model case.
function AddInputCase(caseid){
	var selectItem = document.getElementById('InputCase');
	if(selectItem.options[selectItem.selectedIndex].value===""){
		
	}
	else{
		selectItem.options[selectItem.selectedIndex].disabled = "disabled";
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
				$('#addedinputcase').append(xmlhttp.responseText);
			};   
		};
		xmlhttp.open("GET", "Addinputcasetomodelcase.php?modelcaseid="+caseid+"&caseid="+selectItem.options[selectItem.selectedIndex].value, true);
		xmlhttp.send();
		selectItem.selectedIndex=0;
		inputcaseinfor('InputCase');
	}	
}

// Used to start a model in the homepage
function StartAModel(){
	var width=window.screen.height;
	var height=window.screen.width;
	var myWindow = window.open("StartaModelfor.php?w="+width+"&h="+height,'_self','');
}

function StartASModel(){
	var width=window.screen.height;
	var height=window.screen.width;
	var myWindow = window.open("StartaSModelfor.php?w="+width+"&h="+height,'_self','');
}

// Used to start a input case in the homepage
function StartAInput(){
	var width=window.screen.height;
	var height=window.screen.width;
	var myWindow = window.open("StartAInputByWLETOOL.php?w="+width+"&h="+height,'_self','');
}

// Used to view previous results in the homepage
function ViewPreResults(){
	var width=window.screen.height;
	var height=window.screen.width;
	var myWindow = window.open("ViewPreResults.php?w="+width+"&h="+height,'_self','');
}

// Used to compare the results from different case in the homepage
function CompareResults(){
	var width=window.screen.height;
	var height=window.screen.width;
	var myWindow = window.open("ViewPreResults.php?C=0&w="+width+"&h="+height,'_self','');
}


function SettingAttr3(Aid,Bid,Caseid){
	var selectItem = document.getElementById("Scenarios");
	if(selectItem.options[selectItem.selectedIndex].value==="")
		alert("Please select a basin!");
	
	else{
//		var settattrframe= document.getElementById('setattrframe');
		var myWindow = window.open("setattr.php?CaseId="+Caseid+"&agentid="+Aid+'&basin='+selectItem.options[selectItem.selectedIndex].value,'_blank','width=800, height=1000');
	}
}

function ShowVarVals3(Aid,Bid,Caseid){
	var xmlhttp = new XMLHttpRequest();
	xmlhttp.onreadystatechange = function() {
		if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
			document.getElementById('varvalues').innerHTML=xmlhttp.responseText;
		};
	};
	xmlhttp.open("GET", "GetChangedVars.php?CaseId="+Caseid+"&agentid="+Aid, true);
	xmlhttp.send();
}

function ViewResults(Aid,Caseid){
	var myWindow = window.open("ResultsVisual.php?Aid="+Aid+"&Cid="+Caseid,'_blank','width=1200, height=1000')

}
function CpResults(Aid,Caseid,Caseid2){
	var myWindow = window.open("ResultsVisual.php?Cid2="+Caseid2+"&Aid="+Aid+"&Cid="+Caseid,'_blank','width=1200, height=1000')

}
function SettingAttr(Aid,Bid){
	var selectItem = document.getElementById("Scenarios");
	if(selectItem.options[selectItem.selectedIndex].value==="")
		alert("Please select a basin!");
	
	else{
//		var settattrframe= document.getElementById('setattrframe');
		var myWindow = window.open("setattr.php?agentid="+Aid+'&basin='+selectItem.options[selectItem.selectedIndex].value,'_blank','width=800, height=1000');
	}
}
function ViewPreInputs(){
	var myWindow = window.open('Preinputlist.php','_self','');
}

function getMousePoint(ev) {
	var point = {
		x:0,
		y:0
	};
	if(typeof window.pageYOffset != 'undefined') {
		point.x = window.pageXOffset;
		point.y = window.pageYOffset;
	}
	else if(typeof document.compatMode != 'undefined' && document.compatMode != 'BackCompat') {
		point.x = document.documentElement.scrollLeft;
		point.y = document.documentElement.scrollTop;
	}
	else if(typeof document.body != 'undefined') {
		point.x = document.body.scrollLeft;
		point.y = document.body.scrollTop;
	}
 	point.x += ev.clientX;
	point.y += ev.clientY;
 
	return point;
}

function ExecuteModelSingle(modelid,id){
	var xmlhttp = new XMLHttpRequest();
	xmlhttp.onreadystatechange = function() {
		if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {

		};   
	};
	xmlhttp.open("GET", "Addinputcasetomodelcase.php?modelcaseid="+modelid+"&caseid="+id, true);
	xmlhttp.send();
	ExecuteModel(modelid);
}

function ExecuteModel(str) {
	var xmlhttp = new XMLHttpRequest();
	xmlhttp.onreadystatechange = function() {
		if (xmlhttp.readyState == 1 && xmlhttp.status == 0) {
			SuccessfulSubmits();
		}
	
	};
	xmlhttp.open("GET", "ExcuteModel.php?Cid="+str, true);
	xmlhttp.send();
	
	//var myWindow = window.open("ExcuteModel.php?Cid="+str,'_self');
}
function SuccessfulSubmits(){
	var myWindow = window.open("Submitted.php",'_self');
}