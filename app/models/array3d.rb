class Array3d

def initialize
  @array=[[[]]]
end

def [](a,b,c)
  if @array[a]==nil || @array[a][b]==nil || @array[a][b][c]==nil
    return nil
  else
    return @array[a][b][c]
  end
end

def []=(a,b,c,valor)
  @array[a]=[[]] if @array[a]== nil
  @array[a][b]=[] if @array[a][b]==nil
  @array[a][b][c]=valor
end

end
 
