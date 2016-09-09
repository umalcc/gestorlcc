module SolicitudesHelper
	def getCurrentTeachingPeriod

	    mesActual = Date.today.month
      añoActual = Date.today.year

      ultPeriodo = Periodo.order("inicio DESC").where("tipo = ? and cast(strftime('%m', inicio) as int) = ?",'Examenes', 9)

	    if(mesActual >= 1 and Date.today <= ultPeriodo[0].fin)
	    	inicioCurso = Date.today.prev_year.year
	    	finCurso = Date.today.year
	    else
	    	inicioCurso = Date.today.year
	    	finCurso = Date.today.next_year.year
	    end
	    
	    return {:iniciocurso => inicioCurso, :fincurso => finCurso}
	end

  def getCurrentExamsPeriod
      
      periodos=Periodo.where("tipo = ? AND (activo = ? OR admision = ?)","Examenes","t","t").order("inicio desc")

      if periodos.size > 0
        return {:iniciocurso => periodos[0].iniciosol, :fincurso => periodos[0].finsol}
      
      else
        return {:iniciocurso => nil, :fincurso => nil}

      end      
  end

  def getCurrentCuatrimester

     periodos = Periodo.where("iniciosol <= ? and finsol >= ? and tipo = ?", Date.today, Date.today, 'Lectivo')

     if periodos.size > 0

        return {:iniciocurso => periodos[0].iniciosol, :fincurso => periodos[0].finsol}
      
      else

        return {:iniciocurso => nil, :fincurso => nil}

      end 
  end
	
  def isValidRequest?(solicitud, inicio, fin)

    return ((solicitud.fechasol.year == inicio and 
             solicitud.fechasol.month >= 9 and 
             solicitud.fechasol.month <= 12) or
            (solicitud.fechasol.year == fin and
             solicitud.fechasol.month >= 1 and
             solicitud.fechasol.month <= 7))
	end

  def isLabRequestCurrentCuatrimester?(solicitud, lectivo)
    
    if lectivo
      periodoAcademico = getCurrentCuatrimester
    else
      periodoAcademico = getCurrentExamsPeriod
    end
    
    inicioCurso = periodoAcademico[:iniciocurso]
    fincurso = periodoAcademico[:fincurso]

    if inicioCurso.nil? and fincurso.nil?

      return false

    else

      return (solicitud.fechasol.year >= inicioCurso.year and 
            solicitud.fechasol.month >= inicioCurso.month and 
            solicitud.fechasol.month <= fincurso.month and
            solicitud.fechasol.year <= fincurso.year)

    end

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

    def getCurrentCuatrimesterRequests(solicitudlabs, lectivo)
      solicitudlabs = solicitudlabs.select{|s| isLabRequestCurrentCuatrimester?(s, lectivo)} 
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


