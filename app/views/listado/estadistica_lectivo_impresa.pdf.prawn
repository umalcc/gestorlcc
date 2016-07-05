###################################### Funciones auxiliares ##############################################
def calculateItemsLabs(titulaciones, labs, estadisticas, horas, dias)
rows =[]
	for tit in titulaciones do # las titulaciones son las filas
		row = [tit.abrevia]

		tot_as = 0
		for lab in labs do
			if @todos
				@asigna = estadisticas.select{|r| r.nombre_tit ==tit.nombre and r.nombre_lab == lab.nombre_lab}
			else 
				@asigna = estadisticas.select{|r| r.nombre_tit ==tit.nombre and r.nombre_lab == lab.nombre_lab and r.periodo == p}
			end
			as = @asigna.size

			tot_as+= as
			if as != 0
				row << as.to_s.concat("hs /").concat((horas.size*@dias.size).to_s).concat("hs\n").concat(number_with_precision(Float(as*100)/(horas.size*dias.size),:precision => 2)).concat("%")

			else
				row << '-'
			end

		end # end de @labs

			if tot_as != 0
				row << tot_as.to_s.concat("hs /").concat((horas.size*dias.size*labs.size).to_s).concat("hs\n").concat(number_with_precision(Float(tot_as*100)/(horas.size*dias.size*labs.size),:precision => 2)).concat("%")
			else
				row << '-'
			end
		rows << row
		end # end de @titulaciones

		row = ["Total lab."]
		for lab in labs do 
			if @todos 
				as_porlab = estadisticas.select{|r| r.nombre_lab == lab.nombre_lab}.size
			else 
				as_porlab = estadisticas.select{|r| r.nombre_lab ==lab.nombre_lab and r.periodo == p}.size
			end
			row << as_porlab.to_s.concat("hs /").concat((horas.size*dias.size).to_s).concat("hs\n").concat(number_with_precision(Float(as_porlab*100)/(horas.size*dias.size),:precision => 2)).concat("%")
		end
		rows << row	
	return rows
end

def calculateItems
rows =[]
for hora in @horas do #<!-- las horas son las filas -->
	row = []
	row << (hora.comienzo+'-'+hora.fin)
     
      tot_as=0 
      for dia in @dias do
       #<!-- busco las asignaciones ese dia y hora -->
         if @todos
              @asigna=@estadisticas.select {|r| r.diasem==dia.nombre and r.horaini==hora.comienzo}
         else
              @asigna=@estadisticas.select {|r| r.diasem==dia.nombre and r.horaini==hora.comienzo and r.periodo==p}
         end
         as=@asigna.size
         tot_as+=as
           if as!=0 #<!-- esto es lo que se ve -->
#<!-- ESTO --> 
				row << (as.to_s.concat(" labs / ").concat(@labs.size.to_s).concat(" labs \n").concat(number_with_precision((Float(100*as)/@labs.size),:precision=>2)).concat("%"))
		   else
		   		row<<"-"
           end
      end
          if tot_as!=0 #<!-- esto es lo que se ve -->
			row << tot_as.to_s.concat("asig /").concat((@labs.size*@dias.size).to_s).concat("asig\n").concat(number_with_precision((Float(100*tot_as)/(@labs.size*@dias.size)),:precision=>2)).concat("%")
          else
            row <<'-'
          end  
	rows << row
	end
	rows << calculateTotalDias
	return rows
end
def calculateTotalDias
   row=["Total dias"]
   diasTmp =@dias
      for dia in diasTmp do
       #<!-- busco las asignaciones a ese lab de las asignaturas de esa tit -->
         if @todos
             as_pordia=@estadisticas.select {|r| r.diasem==dia.nombre }.size   
         else
             as_pordia=@estadisticas.select {|r| r.diasem==dia.nombre and r.periodo==p}.size    
         end
          
         #<!-- esto es lo que se ve -->         
           row << as_pordia.to_s.concat(" asig /").concat((@labs.size*@horas.size).to_s).concat(" asig\n").concat(number_with_precision((Float(100*as_pordia)/(@labs.size*@horas.size)),:precision=>2)).concat("%")         
      end
      return row
end

def crearTablasAsignaturas(labs, titulaciones, estadisticas, horas, dias)
	headerTag= labs.dup
	tmpTag = Laboratorio.new
	tmpTag.nombre_lab = "Asig\ \nLab"
	headerTag.unshift(tmpTag)
	tmpTag = Laboratorio.new
	tmpTag.nombre_lab = "Total"
	headerTag <<tmpTag 
	headers = [headerTag.map{|d| d.nombre_lab}.to_a]

	crearTabla(headers, calculateItemsLabs(titulaciones, labs, estadisticas, horas, dias))
end

def crearTablaDiasHoras(dias)

	headerTag= dias.dup
	tmpTag = Dia.new
	tmpTag.nombre = "Hora\Dia"
	headerTag.unshift(tmpTag)
	tmpTag = Dia.new
	tmpTag.nombre = "Total"
	headerTag <<tmpTag 
	headers = [headerTag.map{|d| d.nombre}.to_a]

	crearTabla(headers, calculateItems)
end

def crearTabla(header, items)
    sizeColumn = header[0].size*75/9
	table = header + items

	t = make_table(table, :header => true, :row_colors => ["F0F0F0", "FFFFCC"], :column_widths => Array.new(header.size, sizeColumn), :cell_style => {:align => :center, :size => 10})

	t.row(0).font_style = :bold
	t.draw
end


def calculateTotalLab
	for lab in @labs do 
       #<!-- busco las asignaciones a ese lab de las asignaturas de esa tit -->
         if @todos
             as_porlab=@estadisticas.select {|r| r.nombre_lab==lab.nombre_lab}.size 
         else
             as_porlab=@estadisticas.select {|r| r.nombre_lab==lab.nombre_lab and r.periodo==p}.size 
         end 
         #<!-- esto es lo que se ve -->          
           as_porlab.to_s.concat("hs / ").concat((@horas.size*@dias.size).to_s).concat(" hs\n").concat( number_with_precision((Float(100*as_porlab)/(@dias.size*@horas.size)),:precision=>2)).concat("%")  
	end
end

################################### Cabecera del documento ################################################

pdf.formatted_text([
          { :text => "Estadísticas de asignaciones de laboratorio para período lectivo", :size => 14, :styles => [:bold] },
          { :text => "                                           "},
          { :text => Date.today.strftime("%d-%m-%Y")}])
pdf.image "app/assets/images/bg_separ.png"
pdf.text "\n"

##################################### Tabla con las solicitudes ############################################

crearTablaDiasHoras(@dias)
crearTablasAsignaturas(@labs, @titulaciones, @estadisticas, @horas, @dias)
