###################################### Funciones auxiliares ##############################################

def calculatePrefs(solicitudlab)

   cad = ""
   if !solicitudlab.preferencias.nil?
      prefs = solicitudlab.preferencias.split(";")
      prefs.each do |pref|
         if pref.split("-").length == 3
           cad += " " + pref.split("-")[1].to_s + " " + pref.split("-")[2].to_s
         end
      end
    end

    return cad
end

################################### Cabecera del documento ################################################

pdf.formatted_text([
          { :text => "Solicitudes de laboratorio para período lectivo", :size => 14, :styles => [:bold] },
          { :text => "                                                                       "},
          { :text => Date.today.strftime("%d-%m-%Y")}])
pdf.image "app/assets/images/bg_separ.png"
pdf.text "\n"

##################################### Tabla con las solicitudes ############################################

header = [["Fecha sol.", "Usuario","Asignatura","Curso","Eq.","F.inicio/F.fin","Petición","Soft./\ncomentarios","Elección equipos"]]

items = @solicitudlabs.map do |item|
 
 [
    item.fechasol.strftime("%d-%m-%Y"),
    item.usuario.nombre + " " + item.usuario.apellidos,
    item.asignatura.abrevia_asig,
    if item.curso.to_s == "sin curso"
       "-"
    else
       item.curso
    end,
    item.npuestos,
    item.fechaini.strftime("%d-%m-%Y") + "/\n" + item.fechafin.strftime("%d-%m-%Y"),
    item.peticionlab.map do |p|
      [p.diasemana[0,2],p.horaini, p.horafin]
    end,
    if item.comentarios != ""
      "Sí"
    end,
    calculatePrefs(item)
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