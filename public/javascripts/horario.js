//	Written by Tan Ling wee
//	on 19 June 2005
//	email :	info@sparrowscripts.com
//    url : www.sparrowscripts.com

	var imagePath='/images/';
	
	var ie=document.all;
	var dom=document.getElementById;
	var ns4=document.layers;
	var bShow=false;
	var textCtl;

	function setTimePicker(t) {
		textCtl.value=t;
		closeTimePicker();
	}

	function refreshTimePicker(mode) {
		
		if (mode==0)
			{ 
				suffix="manana"; 
                                inicio=8;
                                fin=13;
                                desfase=45;
			}
		else
			{ 
				suffix="tarde";
                                inicio=15;
                                fin=20; 
                                desfase=15;
			}

		sHTML = "<table><tr><td><table cellpadding=3 cellspacing=0 bgcolor='#f0f0f0'>";
		for (i=inicio;i<=fin;i++) {
// AQUI DEBE ESTAR EL FALLO, DA COMO SI I==0 Y POR ESO SIEMPRE PONE 8:45
			sHTML+="<tr align=right style='font-family:verdana;font-size:9px;color:#000000;'>";

			if (i==0) {
				hr = 8;
			}
			else {
				hr=i;
			}	

			for (j=0;j<1;j++) {
				sHTML+="<td width=80 style='cursor:hand' onmouseover='this.style.backgroundColor=\"#66CCFF\"' onmouseout='this.style.backgroundColor=\"\"' onclick='setTimePicker(\""+ hr + ":" + padZero(15) + 15+" " + suffix + "\")'><a style='text-decoration:none;color:#000000' href='javascript:setTimePicker(\""+ hr + ":" + padZero(15) + "  " + suffix + "\")'>" + hr + ":"+padZero(15) + "<font color=\"#808080\">" + suffix + "</font></a></td>";
			}

			sHTML+="</tr>";
		}
		sHTML += "</table></td></tr></table>";
		document.getElementById("timePickerContent").innerHTML = sHTML;
	}

	if (dom){
		document.write ("<div id='timepicker' style='z-index:+999;position:absolute;visibility:hidden;'><table style='border-width:3px;border-style:solid;border-color:#0033AA' bgcolor='#ffffff' cellpadding=0><tr bgcolor='#0033AA'><td><table cellpadding=0 cellspacing=0 width='100%' background='" + imagePath + "titleback.gif'><tr valign=bottom height=21><td><img id='iconAM' src='" + imagePath + "am1.gif' onclick='document.getElementById(\"iconAM\").src=\"" + imagePath + "am1.gif\";document.getElementById(\"iconPM\").src=\"" + imagePath + "pm2.gif\";refreshTimePicker(0)' style='cursor:hand'></td><td><img id='iconPM' src='" + imagePath + "pm2.gif' onclick='document.getElementById(\"iconAM\").src=\"" + imagePath + "am2.gif\";document.getElementById(\"iconPM\").src=\"" + imagePath + "pm1.gif\";refreshTimePicker(1)' style='cursor:hand'></td><td align=right valign=center>&nbsp;<img onclick='closeTimePicker()' src='" + imagePath + "close.gif'  STYLE='cursor:hand'>&nbsp;</td></tr></table></td></tr><tr><td colspan=2><span id='timePickerContent'></span></td></tr></table></div>");
		refreshTimePicker(0);
	}

	var crossobj=(dom)?document.getElementById("timepicker").style : ie? document.all.timepicker : document.timepicker;
	var currentCtl

	function selectTime(ctl,ctl2) {
		var leftpos=200
		var toppos=200

		textCtl=ctl2;
		currentCtl = ctl
		currentCtl.src=imagePath + "timepicker2.gif";

	//	aTag = ctl
	//	do {
	//		aTag = aTag.offsetParent;
	//		leftpos	+= aTag.offsetLeft;
	//		toppos += aTag.offsetTop;
	//	} while(aTag.tagName!="BODY");
	//	crossobj.left =	ctl.offsetLeft	+ leftpos 
	//	crossobj.top = ctl.offsetTop +	toppos + ctl.offsetHeight +	2 
                crossobj.left =	 300 
		crossobj.top = 	300
		crossobj.visibility=(dom||ie)? "visible" : "show"
		hideElement( 'SELECT', document.getElementById("calendar") );
		hideElement( 'APPLET', document.getElementById("calendar") );			
		bShow = true;
	}

	// hides <select> and <applet> objects (for IE only)
	function hideElement( elmID, overDiv ){
		if( ie ){
			for( i = 0; i < document.all.tags( elmID ).length; i++ ){
				obj = document.all.tags( elmID )[i];
				if( !obj || !obj.offsetParent ){
						continue;
				}
				  // Find the element's offsetTop and offsetLeft relative to the BODY tag.
				  objLeft   = obj.offsetLeft;
				  objTop    = obj.offsetTop;
				  objParent = obj.offsetParent;
				  while( objParent.tagName.toUpperCase() != "BODY" )
				  {
					objLeft  += objParent.offsetLeft;
					objTop   += objParent.offsetTop;
					objParent = objParent.offsetParent;
				  }
				  objHeight = obj.offsetHeight;
				  objWidth = obj.offsetWidth;
				  if(( overDiv.offsetLeft + overDiv.offsetWidth ) <= objLeft );
				  else if(( overDiv.offsetTop + overDiv.offsetHeight ) <= objTop );
				  else if( overDiv.offsetTop >= ( objTop + objHeight + obj.height ));
				  else if( overDiv.offsetLeft >= ( objLeft + objWidth ));
				  else
				  {
					obj.style.visibility = "hidden";
				  }
			}
		}
	}
		 
	//unhides <select> and <applet> objects (for IE only)
	function showElement( elmID ){
		if( ie ){
			for( i = 0; i < document.all.tags( elmID ).length; i++ ){
				obj = document.all.tags( elmID )[i];
				if( !obj || !obj.offsetParent ){
						continue;
				}
				obj.style.visibility = "";
			}
		}
	}

	function closeTimePicker() {
		crossobj.visibility="hidden"
		showElement( 'SELECT' );
		showElement( 'APPLET' );
		currentCtl.src=imagePath + "timepicker.gif"
	}

	document.onkeypress = function hideTimePicker1 () { 
		if (event.keyCode==27){
			if (!bShow){
				closeTimePicker();
			}
		}
	}

	function isDigit(c) {
		
		return ((c=='0')||(c=='1')||(c=='2')||(c=='3')||(c=='4')||(c=='5')||(c=='6')||(c=='7')||(c=='8')||(c=='9'))
	}

	function isNumeric(n) {
		
		num = parseInt(n,10);

		return !isNaN(num);
	}

	function padZero(n) {
		v="";
		if (n<10){ 
			return ('0'+n);
		}
		else
		{
			return n;
		}
	}
