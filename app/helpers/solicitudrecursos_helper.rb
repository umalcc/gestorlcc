module SolicitudrecursosHelper
	
  def getCurrentYearRange

    mesActual = Date.today.month

      if(mesActual >= 1 and mesActual <= 7)
        minCurrentYear = Date.today.prev_year.year
        maxCurrentYear = Date.today.year
      else
        minCurrentYear = Date.today.year
        maxCurrentYear = Date.today.next_year.year
      end

    return {:minCurrentYear => minCurrentYear, :maxCurrentYear => maxCurrentYear }
  end

  def getAcademicYear

      yearRange = getCurrentYearRange

      #iniciocurso es el inicio del primer período lectivo
      firstTeachingPeriod = Periodo.where("tipo = ? and strftime('%Y',inicio) = ?",'Lectivo', yearRange[:minCurrentYear].to_s).order("inicio").first

      #fincurso es el fin del último período de exámenes
      lastExamPeriod = Periodo.where("tipo = ? and strftime('%Y',fin) = ?",'Examenes', yearRange[:maxCurrentYear].to_s).order("fin DESC").first
      
      return {:iniciocurso => firstTeachingPeriod[:inicio], :fincurso => lastExamPeriod[:fin]}
  end

  def getLastAcademicYear

    yearRange = getCurrentYearRange
    lastMinYear = yearRange.minCurrentYear -1
    lastMaxYear = yearRange.maxCurrentYear -1

    #iniciocurso es el inicio del primer período lectivo
    firstTeachingPeriod = Periodo.where("tipo = ? and strftime('%Y',inicio) = ?",'Lectivo', lastMinYear.to_s).order("inicio").first

    #fincurso es el fin del último período de exámenes
    lastExamPeriod = Periodo.where("tipo = ? and strftime('%Y',fin) = ?",'Examenes', lastMaxYear.to_s).order("fin DESC").first
    
    return {:iniciocurso => firstTeachingPeriod[:inicio], :fincurso => lastExamPeriod[:fin]}
  end

  def getPenultimateAcademicYear

    yearRange = getCurrentYearRange
    lastMinYear = yearRange.minCurrentYear -2
    lastMaxYear = yearRange.maxCurrentYear -2

    #iniciocurso es el inicio del primer período lectivo
    firstTeachingPeriod = Periodo.where("tipo = ? and strftime('%Y',inicio) = ?",'Lectivo', lastMinYear.to_s).order("inicio").first

    #fincurso es el fin del último período de exámenes
    lastExamPeriod = Periodo.where("tipo = ? and strftime('%Y',fin) = ?",'Examenes', lastMaxYear.to_s).order("fin DESC").first
    
    return {:iniciocurso => firstTeachingPeriod[:inicio], :fincurso => lastExamPeriod[:fin]}

  end

  def isValidRequest?(solicitud, inicio, fin)

    return (solicitud.fechasol >= inicio and solicitud.fechasol <= fin)
  
  end

  def isLabRequestCurrent?(solicitud)

      academicYear = getAcademicYear

      return true if isValidRequest?(solicitud, academicYear[:iniciocurso], academicYear[:fincurso])
  end

  def isLabRequestFromLastYear?(solicitud)
      
      lastAcademicYear = getLastAcademicYear
      inicioCursoPasado = lastAcademicYear[:iniciocurso]
      finCursoPasado = lastAcademicYear[:fincurso]
      
      return true if isValidRequest?(solicitud, inicioCursoPasado, finCursoPasado)
  end

  def isLabRequestFromLast2Years?(solicitud)

      penultimateAcademicYear = getPenultimateAcademicYear
      inicioCursoPasado2 = penultimateAcademicYear[:iniciocurso]
      finCursoPasado2 = penultimateAcademicYear[:fincurso]
      
      return true if isValidRequest?(solicitud, inicioCursoPasado2, finCursoPasado2)    
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
