module SolicitudesHelper
  
  def getStartAndEndYearsTeachingPeriod

    currentYear = Date.today.year
    if Date.today.month >= 1 and Date.today.month <= 8
        startYear = currentYear - 1
        endYear = currentYear
    else
        startYear = currentYear
        endYear = currentYear + 1
    end

    return {:startYear => startYear, :endYear => endYear}
  end


  def getStartAndEndYearsForExamsPeriod

    currentYear = Date.today.year
    if Date.today.month >= 1 and Date.today.month <= 9
        startYear = currentYear - 1
        endYear = currentYear

        periodos=Periodo.where("tipo = ? and cast(strftime('%m', inicio) as int) = ? and cast(strftime('%Y', inicio) as int) = ?","Examenes", 9, endYear).order("inicio desc")
        if periodos.size > 0
           diaFinExamsSept = periodos[0].fin.day
           if Date.today.day > diaFinExamsSept
             startYear = currentYear
             endYear = currentYear + 1
           end
        end
    else
        startYear = currentYear
        endYear = currentYear + 1
    end

    return {:startYear => startYear, :endYear => endYear}
  end

	def getCurrentTeachingPeriod

      startAndEndYears = getStartAndEndYearsTeachingPeriod

      inicioCurso = Date.new(startAndEndYears[:startYear], 9, 1)
      finCurso = Date.new(startAndEndYears[:endYear],7,1)
	    
	    return {:iniciocurso => inicioCurso, :fincurso => finCurso}
	end

  def getCurrentTeachingPeriodForExams
       
      startAndEndYears = getStartAndEndYearsForExamsPeriod
 
      inicioCurso = Date.new(startAndEndYears[:startYear], 10, 1)
      finCurso = Date.new(startAndEndYears[:endYear],10,1)
     
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


