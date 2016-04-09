module SolicitudesHelper
	def getCurrentTeachingPeriod

	    mesActual = Date.today.month

	    if(mesActual >= 1 and mesActual <= 7)
	    	inicioCurso = Date.today.prev_year.year
	    	finCurso = Date.today.year
	    else
	    	inicioCurso = Date.today.year
	    	finCurso = Date.today.next_year.year
	    end
	    
	    return {:iniciocurso => inicioCurso, :fincurso => finCurso}
	end

  def getCurrentCuatrimester
      mesActual = Date.today.month
      currentDate = Date.today
      if(mesActual >= 1 and mesActual <= 7)
        #segundo cuatrimestre
        inicioCurso = Date.new(currentDate.year,1,22)
        finCurso = Date.new(currentDate.year,7,31)
      else
        #primer cuatrimestre
        inicioCurso = Date.new(currentDate.year,8,1)
        finCurso = Date.new(currentDate.next_year.year,1,21)
      end

      return {:iniciocurso => inicioCurso, :fincurso => finCurso}
  end
	
  def isValidRequest?(solicitud, inicio, fin)

        return true if (solicitud.fechasol.year == inicio and 
      	                solicitud.fechasol.month >= 9 and 
      	                solicitud.fechasol.month <= 12) or
                       (solicitud.fechasol.year == fin and
                        solicitud.fechasol.month >= 1 and
                        solicitud.fechasol.month <= 7)
	end

  def isLabRequestCurrentCuatrimester?(solicitud)
    periodoAcademico = getCurrentCuatrimester
    inicioCurso = periodoAcademico[:iniciocurso]
    fincurso = periodoAcademico[:fincurso]

    return true if(solicitud.fechasol.year >= inicioCurso.year and 
                        solicitud.fechasol.month >= inicioCurso.month and 
                        solicitud.fechasol.month <= fincurso.month and
                       solicitud.fechasol.year <= fincurso.year)
  end

  def isLabRequestCurrent?(solicitud)

      periodoAcademico = getCurrentTeachingPeriod

      return true if isValidRequest?(solicitud, periodoAcademico[:iniciocurso], periodoAcademico[:fincurso])
    end

    def isLabRequestFromLastYear?(solicitud)
      
      periodoAcademicoActual = getCurrentTeachingPeriod
      inicioCursoPasado = periodoAcademicoActual[:iniciocurso] -1
      finCursoPasado = periodoAcademicoActual[:fincurso] -1
      
      return true if isValidRequest?(solicitud, inicioCursoPasado, finCursoPasado)
    end

    def isLabRequestFromLast2Years?(solicitud)

      periodoAcademicoActual = getCurrentTeachingPeriod
      inicioCursoPasado2 = periodoAcademicoActual[:iniciocurso] -2
      finCursoPasado2 = periodoAcademicoActual[:fincurso] -2
      
      return true if isValidRequest?(solicitud, inicioCursoPasado2, finCursoPasado2)    
    end

    def getCurrentCuatrimesterRequests(solicitudlabs)
      solicitudlabs = solicitudlabs.select{|s| isLabRequestCurrentCuatrimester?(s)} 
      return solicitudlabs
    end
    
    def getCurrentRequests(solicitudlabs)
      solicitudlabs = solicitudlabs.select{|s| isLabRequestCurrent?(s)} 
      return solicitudlabs
    end

    def getFromLastYearRequests(solicitudlabs)
      solicitudlabs = solicitudlabs.select {|s| isLabRequestCurrent?(s) || 
      	                                        isLabRequestFromLastYear?(s)}
      return solicitudlabs
    end

    def getFromLast2YearsRequests(solicitudlabs)
      solicitudlabs = solicitudlabs.select {|s| isLabRequestCurrent?(s) || 
    	                                      isLabRequestFromLastYear?(s) || 
    	                                      isLabRequestFromLast2Years?(s)}
      return solicitudlabs
    end

end


