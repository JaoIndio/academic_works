

# | Address | Length | Convertion_name | Scale | REG_Value | Numeric_Value | Signal | Function | Name | write_value | Return_value |b

class Parametros_IO:
  
  def __init__(self, Address, Length, Convertion_name, Scale, REG_Value, Numeric_Value, Signal, Function, Name, Write_value, Return_value):
    
    self.Address         = Address
    self.Length          = Length 
    self.Convertion_name = Convertion_name
    
    self.Scale         = Scale
    self.REG_Value     = REG_Value
    self.Numeric_Value = Numeric_Value

    self.Signal   = Signal
    self.Function = Function
    self.Name     = Name

    self.Write_value  = Write_value
    self.Return_value = Return_value



