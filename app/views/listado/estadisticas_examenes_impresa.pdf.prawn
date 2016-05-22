###################################### Funciones auxiliares ##############################################



################################### Cabecera del documento ################################################

pdf.formatted_text([
          { :text => "Estadísticas de asignaciones de laboratorio para período de exámenes", :size => 14, :styles => [:bold] },
          { :text => "                                                                       "},
          { :text => Date.today.strftime("%d-%m-%Y")}])
pdf.image "app/assets/images/bg_separ.png"
pdf.text "\n"

##################################### Tabla con las solicitudes ############################################

header = [["Fecha sol.", "Usuario","Asignatura - Tit.","Curso", "Eq.","F.inicio/F.fin","Petición","Soft./\ncomentarios","Elección equipos"]]

items = @estadisticas.map do |item|
 [
   
 ]

end

table = header + items

t = make_table(table, :header => true, :row_colors => ["F0F0F0", "FFFFCC"], :column_widths => [75, 125, 90,55,30,75,110,70,60], :cell_style => {:align => :center, :size => 10})

#elimina los bordes de las subtablas de la columna 6: "Petición" y cambiar tamaño de la fuente
for i in 1..(t.row_length - 1)
   t.cells[i,6].content.cells.borders = [] 
   t.cells[i,6].content.cells.size = 10 
end

t.row(0).font_style = :bold
t.draw