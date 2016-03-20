require 'test_helper'

class HistoricoasigexaTest < ActiveSupport::TestCase
   test "Crear un nuevo historico para asignaturas, exámenes'" do
    @historico=Historicoasigexa.new
    assert  @historico.save
  end
end
