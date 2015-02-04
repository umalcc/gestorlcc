###################################### Funciones auxiliares ##############################################

def getResource(recurso)

   familia=Recurso.find_by_identificador(recurso.tipo)
   cad = familia.descripcion+" : "+recurso.tipo  
   return cad

end

################################### Cabecera del documento ################################################

pdf.formatted_text([
    { :text => "Solicitudes de recursos", :size => 14, :styles => [:bold] },
    { :text => "                                                                                                                     "},
    { :text => Date.today.strftime("%d-%m-%Y")}])
pdf.image "app/assets/images/bg_separ.png"
pdf.text "\n"

##################################### Tabla con las solicitudes ############################################

header = [["Fecha reserva", "Usuario","Recurso","Día reservado","Horario","Motivos"]]

items = @solicitudrecursos.map do |item|
 
 [
    item.fechasol.strftime("%d-%m-%Y"),
    item.usuario.nombre + " " + item.usuario.apellidos,
    getResource(item),    
    item.fechareserva.strftime("%d-%m-%Y"),
    item.horaini + "-" + item.horafin,
    item.motivos
 ]

end

table = header + items

t = make_table(table, :header => true, :row_colors => ["F0F0F0", "FFFFCC"], :column_widths => [75, 125, 125,75,75,200], :cell_style => {:align => :center})

t.draw