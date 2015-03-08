function mostrardiv(par) {
div=document.getElementById(par);
div.style.visibility="visible";
}

function ocultardiv(par) {
div=document.getElementById(par);
div.style.visibility="hidden";
}

///// mostrar-ocultar flotante

var cX = 0; var cY = 0; var rX = 0; var rY = 0;
function UpdateCursorPosition(e){ cX = e.pageX; cY = e.pageY;}
function UpdateCursorPositionDocAll(e){ cX = event.clientX; cY = event.clientY;}
if(document.all) { document.onmousemove = UpdateCursorPositionDocAll; }
else { document.onmousemove = UpdateCursorPosition; }
function AssignPosition(d) {
if(self.pageYOffset) {
   rX = self.pageXOffset;
   rY = self.pageYOffset;
   }
else if(document.documentElement && document.documentElement.scrollTop) {
   rX = document.documentElement.scrollLeft;
   rY = document.documentElement.scrollTop;
   }
else if(document.body) {
   rX = document.body.scrollLeft;
   rY = document.body.scrollTop;
   }
if(document.all) {
   cX += rX;
   cY += rY;
   }
d.style.left = (cX-150) + "px";
d.style.top = (cY-220) + "px";
}
function HideContent(d) {
if(d.length < 1) { return; }
document.getElementById(d).style.display = "none";
}
function ShowContent(d) {
if(d.length < 1) { return; }
var dd = document.getElementById(d);
AssignPosition(dd);
dd.style.display = "block";
}
function ReverseContentDisplay(d) {
if(d.length < 1) { return; }
var dd = document.getElementById(d);
AssignPosition(dd);
if(dd.style.display == "none") { dd.style.display = "block"; }
else { dd.style.display = "none"; }
}
//-->

//////// para el formulario flotante

(function( $ ) {
         $.widget( "ui.combobox", {
             _create: function() {
                 var self = this,
                     select = this.element.hide(),
                     selected = select.children( ":selected" ),
                     value = selected.val() ? selected.text() : "";
                 var input = this.input = $( "<input>" )
                     .insertAfter( select )
                     .val( value )
                     .css("background","white")
                     .css("border-radius","0px")
                     .css("font-family","Arial,Verdana,Helvetica,sans-serif")
                     .css("border","1px solid rgb(189, 186, 186)")
                     .css("color","black")
                     .css("font-size","13px")
                     .css("padding","1px 2px 1px 2px")
                     .css("width","360px")
                     .autocomplete({
                         delay: 0,
                         minLength: 0,
                         source: function( request, response ) {
                             var matcher = new RegExp( $.ui.autocomplete.escapeRegex(request.term), "i" );
                             response( select.children( "option" ).map(function() {
                                 var text = $( this ).text();
                                 if ( this.value && ( !request.term || matcher.test(text) ) )
                                     return {
                                         label: text.replace(
                                             new RegExp(
                                                 "(?![^&;]+;)(?!<[^<>]*)(" +
                                                 $.ui.autocomplete.escapeRegex(request.term) +
                                                 ")(?![^<>]*>)(?![^&;]+;)", "gi"
                                             ), "<strong>$1</strong>" ),
                                         value: text,
                                         option: this
                                     };
                             }) );
                         },
                         select: function( event, ui ) {
                             ui.item.option.selected = true;
                             self._trigger( "selected", event, {
                                 item: ui.item.option
                             });
                             select.trigger("change");                             
                         },
                         change: function( event, ui ) {
                             if ( !ui.item ) {
                                 var matcher = new RegExp( "^" + $.ui.autocomplete.escapeRegex( $(this).val() ) + "$", "i" ),
                                     valid = false;
                                 select.children( "option" ).each(function() {
                                     if ( $( this ).text().match( matcher ) ) {
                                         this.selected = valid = true;
                                         return false;
                                     }
                                 });
                                 if ( !valid ) {
                                     // remove invalid value, as it didn't match anything
                                     $( this ).val( "" );
                                     select.val( "" );
                                     input.data( "autocomplete" ).term = "";
                                     return false;
                                 }
                             }
                         }
                     })
                     .addClass( "ui-widget ui-widget-content ui-corner-left" );
 
                 input.data( "ui-autocomplete" )._renderItem = function( ul, item ) {
                     return $( "<li></li>" )
                         .data( "ui-autocomplete", item )
                         .append( "<a>" + item.label + "</a>" )
                         .appendTo( ul );
                 };
 
                 this.button = $( "<button type='button'>&nbsp;</button>" )
                     .attr( "tabIndex", -1 )
                     .attr( "title", "Mostrar todas las titulaciones" )
                     .css("height","20px")
                     .css("width","22px")
                     .css("vertical-align","bottom")
                     .css("background","white")
                     .insertAfter( input )
                     .button({
                         icons: {
                             primary: "ui-icon-triangle-1-s"
                         },
                         text: false
                     })
                     .removeClass( "ui-corner-all" )
                     .addClass( "ui-corner-right ui-button-icon" )
                     .click(function() {
                         // close if already visible
                         if ( input.autocomplete( "widget" ).is( ":visible" ) ) {
                             input.autocomplete( "close" );
                             return;
                         }
 
                         // pass empty string as value to search for, displaying all results
                         input.autocomplete( "search", "" );
                         input.focus();
                     });
             },
 
             destroy: function() {
                 this.input.remove();
                 this.button.remove();
                 this.element.show();
                 $.Widget.prototype.destroy.call( this );
             }
         });
     })( jQuery );

  