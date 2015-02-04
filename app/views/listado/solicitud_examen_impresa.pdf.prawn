###################################### Funciones auxiliares ##############################################

def calculatePrefs(solicitudlabexa)

   cad = ""
   if !solicitudlabexa.preferencias.nil?
      prefs = solicitudlabexa.preferencias.split(";")
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
          { :text => "Solicitudes de laboratorio para período de éxamenes", :size => 14, :styles => [:bold] },
          { :text => "                                                          "},
          { :text => Date.today.strftime("%d-%m-%Y")}])
pdf.image "app/assets/images/bg_separ.png"
pdf.text "\n"

##################################### Tabla con las solicitudes ############################################

header = [["Fecha sol.", "Usuario","Asignatura","Curso","Eq.","Fecha","Horario","Soft.","Elección equipos"]]

items = @solicitudlabexas.map do |item|
 
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
    item.fecha.strftime("%d-%m-%Y"),
    item.horaini + "-" + item.horafin,
    if item.comentarios != ""
      "Sí"
    end,
    calculatePrefs(item)
 ]

end

table = header + items

t = make_table(table, :header => true, :row_colors => ["F0F0F0", "FFFFCC"], :column_widths => [75, 125, 90,60,30,75,120,35,70], :cell_style => {:align => :center})

t.draw