module SolicitudesHelper
	def getCurrentTeachingPeriod

      primerPeriodo = Periodo.order("inicio").where("tipo = ? and cast(strftime('%m', inicio) as int) = ?",'Lectivo', 9).first

      inicioCurso = primerPeriodo.iniciosol
      finCurso = Date.new(inicioCurso.next_year.year,7,1)
	    
	    return {:iniciocurso => inicioCurso, :fincurso => finCurso}
	end

  def getCurrentTeachingPeriodForExams

      primerPeriodoLectivo = Periodo.order("inicio").where("tipo = ? and cast(strftime('%m', inicio) as int) = ?",'Lectivo', 9).first
      ultPeriodoExamenes = Periodo.order("inicio DESC").where("tipo = ? and cast(strftime('%m', inicio) as int) = ?",'Examenes', 9).first
      
      inicioCurso = primerPeriodoLectivo.inicio
      finCurso = ultPeriodoExamenes.fin
      
      return {:iniciocurso => inicioCurso, :fincurso => finCurso}
  end

  def getCurrentExamsPeriod
     
      periodos=Periodo.where("iniciosol <= ? and fin >= ? and tipo = ? AND (activo = ? OR admision = ?)",Date.today, Date.today,"Examenes","t","t").order("inicio desc")

      if periodos.size > 0
        return {:iniciocurso => periodos[0].iniciosol, :fincurso => periodos[0].fin}
      
      else
        return {:iniciocurso => nil, :fincurso => nil}

      end      
  end

  def getCurrentCuatrimester

     periodos = Periodo.where("iniciosol <= ? and fin >= ? and tipo = ?", Date.today, Date.today, 'Lectivo')

     if periodos.size > 0

        return {:iniciocurso => periodos[0].iniciosol, :fincurso => periodos[0].fin}
      
      else

        return {:iniciocurso => nil, :fincurso => nil}

      end 
  end
	
  def isValidRequest?(solicitud, inicio, fin)

    return (solicitud.fechasol >= inicio and 
            solicitud.fechasol <= fin)
	end

  def isLabRequestCurrentCuatrimester?(solicitud, lectivo)
    
    if lectivo
      periodoAcademico = getCurrentCuatrimester
    else
      periodoAcademico = getCurrentExamsPeriod
    end
    
    inicioCurso = periodoAcademico[:iniciocurso]
    finCurso = periodoAcademico[:fincurso]

    if inicioCurso.nil? and finCurso.nil?

      return false

    else

      return (solicitud.fechasol >= inicioCurso and 
            solicitud.fechasol <= finCurso)
    end

  end

  def isLabRequestCurrent?(solicitud, lectivo)

      if lectivo
        periodoAcademico = getCurrentTeachingPeriod
      else
        periodoAcademico = getCurrentTeachingPeriodForExams
      end

      return true if isValidRequest?(solicitud, periodoAcademico[:iniciocurso], periodoAcademico[:fincurso])
  end

    def isLabRequestFromLastYear?(solicitud, lectivo)
      
      if lectivo
        periodoAcademico = getCurrentTeachingPeriod
      else
        periodoAcademico = getCurrentTeachingPeriodForExams
      end

      inicioCursoPasado = periodoAcademico[:iniciocurso].prev_year.year
      finCursoPasado = periodoAcademico[:fincurso].prev_year.year
      
      return true if isValidRequest?(solicitud, inicioCursoPasado, finCursoPasado)
    end

    def isLabRequestFromLast2Years?(solicitud, lectivo)

      if lectivo
        periodoAcademico = getCurrentTeachingPeriod
      else
        periodoAcademico = getCurrentTeachingPeriodForExams
      end

      inicioCursoPasado2 = periodoAcademico[:iniciocurso].prev_year.prev_year.year
      finCursoPasado2 = periodoAcademico[:fincurso].prev_year.prev_year.year
      
      return true if isValidRequest?(solicitud, inicioCursoPasado2, finCursoPasado2)    
    end

    def getCurrentCuatrimesterRequests(solicitudlabs, lectivo)
      solicitudlabs = solicitudlabs.select{|s| isLabRequestCurrentCuatrimester?(s, lectivo)} 
      return solicitudlabs
    end
    
    def getCurrentRequests(solicitudlabs, lectivo)
      solicitudlabs = solicitudlabs.select{|s| isLabRequestCurrent?(s, lectivo)} 
      return solicitudlabs
    end

    def getFromLastYearRequests(solicitudlabs, lectivo)
      solicitudlabs = solicitudlabs.select {|s| isLabRequestCurrent?(s, lectivo) || 
      	                                        isLabRequestFromLastYear?(s, lectivo)}
      return solicitudlabs
    end

    def getFromLast2YearsRequests(solicitudlabs, lectivo)
      solicitudlabs = solicitudlabs.select {|s| isLabRequestCurrent?(s, lectivo) || 
    	                                      isLabRequestFromLastYear?(s, lectivo) || 
    	                                      isLabRequestFromLast2Years?(s, lectivo)}
      return solicitudlabs
    end

end


