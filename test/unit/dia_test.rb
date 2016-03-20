require 'test_helper'

class DiaTest < ActiveSupport::TestCase
   test "Crear un nuevo dia'" do
    @dia=Dia.new
    assert  @dia.save
  end
end
