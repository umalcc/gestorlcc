module SolicitudesHelper
	def getCurrentTeachingPeriod

      primerPeriodo = Periodo.order("inicio").where("iniciosol <= ? and fin >= ? and tipo = ? and cast(strftime('%m', inicio) as int) = ?",Date.today,Date.today,'Lectivo', 9).first

      if primerPeriodo != nil
        inicioCurso = primerPeriodo.iniciosol
        finCurso = Date.new(inicioCurso.next_year.year,7,1)
      else
        inicioCurso = nil
        finCurso = nil
      end
	    
	    return {:iniciocurso => inicioCurso, :fincurso => finCurso}
	end

  def getCurrentTeachingPeriodForExams

      primerPeriodoExamenes = Periodo.order("inicio").where("iniciosol <= ? and fin >= ? and tipo = ? and cast(strftime('%m', inicio) as int) = ?",Date.today,Date.today,'Examenes', 12).first
      ultPeriodoExamenes = Periodo.order("inicio DESC").where("iniciosol <= ? and fin >= ? and tipo = ? and cast(strftime('%m', inicio) as int) = ?",Date.today,Date.today,'Examenes', 9).first
      
      if primerPeriodoExamenes.nil? and ultPeriodoExamenes.nil? 
          inicioCurso = nil
          finCurso = nil
      else
          inicioCurso = primerPeriodoLectivo.inicio
          finCurso = ultPeriodoExamenes.fin
      end
      
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

      if periodoAcademico[:iniciocurso].nil? and periodoAcademico[:fincurso].nil?
         return false
      else
         return isValidRequest?(solicitud, periodoAcademico[:iniciocurso], periodoAcademico[:fincurso])
      end
  end

  def isLabRequestFromLastYear?(solicitud, lectivo)
      
      # Nota: las fechas tienen que estar actualizadas para que funcione correctamente
      if lectivo
        periodoAcademico = getCurrentTeachingPeriod
      else
        periodoAcademico = getCurrentTeachingPeriodForExams
      end

      if periodoAcademico[:iniciocurso].nil? and periodoAcademico[:fincurso].nil?
         return false
      else
        inicioCursoPasado = periodoAcademico[:iniciocurso].prev_year.year
        finCursoPasado = periodoAcademico[:fincurso].prev_year.year
        return isValidRequest?(solicitud, inicioCursoPasado, finCursoPasado)
      end
    end

    def isLabRequestFromLast2Years?(solicitud, lectivo)

      # Nota: las fechas tienen que estar actualizadas para que funcione correctamente
      if lectivo
        periodoAcademico = getCurrentTeachingPeriod
      else
        periodoAcademico = getCurrentTeachingPeriodForExams
      end

      if periodoAcademico[:iniciocurso].nil? and periodoAcademico[:fincurso].nil?
         return false
      else
         inicioCursoPasado2 = periodoAcademico[:iniciocurso].prev_year.prev_year.year
         finCursoPasado2 = periodoAcademico[:fincurso].prev_year.prev_year.year
         return isValidRequest?(solicitud, inicioCursoPasado2, finCursoPasado2)   
      end 
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


