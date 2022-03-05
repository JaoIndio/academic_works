#!/usr/bin/python3
# -*- coding: utf-8 -*-

from pymodbus.client.sync import ModbusSerialClient as ModbusClient
from datetime import datetime
import paho.mqtt.client as mqtt
import time

import sys 
sys.path.append('/Configurations/')
from Topics import Topics
from Topics import INV_REGS
from Topics import WRITE_REGS

sys.path.append('/Classes/')
from Parametros_IO import Parametros_IO

PORT_DEVICE1 = '/dev/ttyUSB0'

def main():
  
  """ 
    INV_REGS list structure: 
      | Address | Length | Convertion_name | Scale | REG_Value | Numeric_Value | Signal | Function | Name | write_value | Return_value |   
  """

  Ts = 0.0001 
  Initial_Time = time.time()
 
  Client_MQTT            = mqtt.Client("Solis_SCADA_10kW") # Instanciacao do objeto cliennte MQTT
  Client_MQTT.on_connect = on_connect                      # callback 1
  Client_MQTT.on_message = on_message                      # callback 2

  #Client_MQTT.connect("mqtt.eclipseprojects.io", 1883, 60) # broker alternativo
  #Client_MQTT.connect("mqtt.eclipse.org", 1883, 60)        # broker alternativo
  Client_MQTT.connect("test.mosquitto.org", 1883, 60)
  
  # Criacao dos objetos Parametros_IO e da lista Parameters
  Parameter = []
  for Elements in range(len(INV_REGS)):
    
    newParam = Parametros_IO(INV_REGS[Elements][0], INV_REGS[Elements][1], INV_REGS[Elements][2], INV_REGS[Elements][3],
                             INV_REGS[Elements][4], INV_REGS[Elements][5], INV_REGS[Elements][6], INV_REGS[Elements][7],
                             INV_REGS[Elements][8], INV_REGS[Elements][9], INV_REGS[Elements][10] )
    Parameter.append(newParam)
 
  while True:
    Client_MQTT.loop_start()
    try:
      # Estabelecimento da conexão serial com o inversor
      Solis_Inv = ModbusClient(method='rtu', port=PORT_DEVICE1, timeout=2, baudrate=9600)
      Solis_Inv.connect()
     
# ==  =========      =====================     ========= Leitura ModBus ===========      =====================     ========= 
      
      for element in range(len (INV_REGS)):
        """
          As etapas que envolvem o protocolo Modbus limitam-se a
          realizacao de leituras e escritas de(nos)registradores
          e conversoes dos valores amostrados
          
        """
        # Registradores de 32 bits
        if Parameter[element].Length == 32:
    
          if Parameter[element].Function == 'input_register': 
            Parameter[element].REG_Value = Solis_Inv.read_input_registers(address=Parameter[element].Address, 
                                                                          count=2, 
                                                                          unit=1)
          else:
            Parameter[element].REG_Value = Solis_Inv.read_holding_registers(address=Parameter[element].Address, 
                                                                            count=2, 
                                                                            unit=1)
          
          if Parameter[element].Signal == 'signal': 
            Parameter[element].Numeric_Value = convert_parameters_int_32(Parameter[element].REG_Value.registers[0], 
                                                                         Parameter[element].REG_Value.registers[1])
          else:
            Parameter[element].Numeric_Value = convert_parameters_uint_32(Parameter[element].REG_Value.registers[0], 
                                                                          Parameter[element].REG_Value.registers[1])

        # Registradores de 16 bits
        else:
          
          if Parameter[element].Function == 'input_register': 
            Parameter[element].REG_Value = Solis_Inv.read_input_registers(Parameter[element].Address, 
                                                                          count=1, 
                                                                          unit=1)
          else:
            
            if Parameter[element].Write_value != 'none': # write_value = 'none' indica que nao ha valor para ser escrito
             Parameter[element].Return_value = Solis_Inv.write_register(address=Parameter[element].write_value, 
                                                                        value=Parameter[element].Write_value, 
                                                                        uint=1)
            
            Parameter[element].REG_Value = Solis_Inv.read_holding_registers(address=Parameter[element].Address, 
                                                                            count=1, 
                                                                            unit=1)
          
          if Parameter[element].Signal == 'signal': 
            Parameter[element].REG_Value.registers[0] = convert_parameters_int_16(Parameter[element].REG_Value.registers[0])
          

# ==  =========      =====================     ========= Conversão ModBus ===========      =====================     =========
        if Parameter[element].Convertion_name == 'none':
          Parameter[element].Numeric_Value = Parameter[element].REG_Value.registers[0]
        
        elif Parameter[element].Convertion_name == 'input_to_real':
          
          if Parameter[element].Length== 32:   
            Parameter[element].Numeric_Value = convert_input_register_value_to_real_value(Parameter[element].Numeric_Value, 
                                                                                          Parameter[element].Scale)
          else:
            Parameter[element].Numeric_Value = convert_input_register_value_to_real_value(Parameter[element].REG_Value.registers[0], 
                                                                                          Parameter[element].Scale)
        
        else:
          a = 2


# ==  =========      =====================     ========= Publish ===========      =====================     ========= 
        mqtt_publish(Client_MQTT, Parameter[element].Name, Parameter[element].Numeric_Value ) # Envia mensagem para o broker
        Solis_Inv.close() # Encerra conexao serial
        time.sleep(0.350)
      
      print("have published")
      Load_Value = calculate_load()
      mqtt_publish(Client_MQTT, "Solis_BRAZIL_RS_SantaMaria_UFSM_INRI_09ELoad_W", Load_Value)

    except:
      print("Except")
      print("\n\t* "+str(Parameter[element].Name)+":  "+str(Parameter[element].REG_Value))

    Final_Time = time.time()
    CPU_Process_Time = Final_Time - Initial_Time
    print("Tempo de Processamento:"+ str(CPU_Process_Time))
    if Ts - CPU_Process_Time > 0:
      time.sleep(Ts - CPU_Process_Time)
    Initial_Time = time.time()

def calculate_load():
  ID = "Solis_BRAZIL_RS_SantaMaria_UFSM_INRI_09E"
  
  for var in range((len(INV_REGS))):
    if  Parameter[element].Name == ID+"Active_Power_W":
      active = Parameter[element].Numeric_Value

    if Parameter[element].Name == ID+"Meter_Active_Power_A":
      active_meter = Parameter[element].Numeric_Value

    if Parameter[element].Name == ID+"Meter_Active_PowerA_kW":
      reactive_meter = Parameter[element].Numeric_Value
    
    if Parameter[element].Name == ID+"Battery_Current":
      battery_current = Parameter[element].Numeric_Value
    
    if Parameter[element].Name == ID+"Battery_Voltage":
      battery_voltage = Parameter[element].Numeric_Value

  return active - reactive_meter - active_meter -abs(battery_current*battery_voltage)

def charge_config(inv_ref, start_hour, start_minute, end_hour, end_minute, current_limit):
  """
    Configura horario de carregamento da bateria
  """
  current_limit=current_limit*10
  result = inv_ref.write_register(address=43141, value=current_limit, uint=1)
  #print("\n\n\t\tresultado da corrente =>" +str(result)+ "\n\n")
  
  result = inv_ref.write_register(address=43143, value=start_hour, uint=1)
  #print("\n\n\t\tresultado de start_hour =>" +str(result)+ "\n\n")
  
  result = inv_ref.write_register(address=43144, value=start_minute, uint=1)
  #print("\n\n\t\tresultado de start_minute =>" +str(result)+ "\n\n")
  
  result = inv_ref.write_register(address=43145, value=end_hour, uint=1)
  #print("\n\n\t\tresultado de end_hour =>" +str(result)+ "\n\n")
  
  result = inv_ref.write_register(address=43146, value=end_minute, uint=1)
  #print("\n\n\t\tresultado de end_minute =>" +str(result)+ "\n\n")
  #inv_ref.write_register(address=43110, value=2, uint=1)


def discharge_config(inv_ref, start_hour, start_minute, end_hour, end_minute, current_limit): 
  """
    Configura horario de descarga da bateria
  """
  
  current_limit=current_limit*10
  result = inv_ref.write_register(address=43142, value=current_limit, uint=1)
  #print("\n\n\t\tresultado da corrente =>" +str(result)+ "\n\n")
  
  result = inv_ref.write_register(address=43147, value=start_hour, uint=1)
  #print("\n\n\t\tresultado de start_hour =>" +str(result)+ "\n\n")
  result = inv_ref.write_register(address=43148, value=start_minute, uint=1)
  #print("\n\n\t\tresultado de start_minute =>" +str(result)+ "\n\n")

  result = inv_ref.write_register(address=43149, value=end_hour, uint=1)
  #print("\n\n\t\tresultado de end_hour =>" +str(result)+ "\n\n")
  
  result = inv_ref.write_register(address=43150, value=end_minute, uint=1)
  #print("\n\n\t\tresultado de end_minute =>" +str(result)+ "\n\n")
  #inv_ref.write_register(address=43110, value=8, uint=1)

def convert_parameters_uint_32(Uint_32_Input_Registers_Most_Significant_Bits, Uint_32_Input_Registers_Less_Significant_Bits):
  """
    Recebe os parâmetro lidos do registrador do inversor
      Estradas:
        Uint_32_Input_Registers_Most_Significant_Bits: Conjunto de Bits mais significativos da variável (de 32 a 16)
        Uint_32_Input_Registers_Less_Significant_Bits: Conjunto de Bits menos significativos da variável (de 15 a 0)
        Função: Converter o valor dos registradores do inversor em valores do tipo inteiro
  """
  return Uint_32_Input_Registers_Most_Significant_Bits*65536 + Uint_32_Input_Registers_Less_Significant_Bits
def convert_parameters_int_32(Uint_32_Input_Registers_Most_Significant_Bits, Uint_32_Input_Registers_Less_Significant_Bits):
  """
    Recebe os parâmetro lidos do registrador do inversor
      Estradas:
        Uint_32_Input_Registers_Most_Significant_Bits: Conjunto de Bits mais significativos da variável (de 32 a 16)
        Uint_32_Input_Registers_Less_Significant_Bits: Conjunto de Bits menos significativos da variável (de 15 a 0)
        Função: Converter o valor dos registradores do inversor em valores do tipo inteiro
  """
  if Uint_32_Input_Registers_Most_Significant_Bits > 32767:
      
      bin1 = bin(Uint_32_Input_Registers_Most_Significant_Bits)
      bin1 = bin(Uint_32_Input_Registers_Less_Significant_Bits)
      bin2 = bin(Uint_32_Input_Registers_Most_Significant_Bits*65536)
      
      n0 = int(bin1, 2)
      n1 = int(bin2, 2)

      n2 = bin(n1+n0)
      n3 = '0b'
      for bit in range(2,33,1):
        if n2[bit] == '0':
          n3 += '1'
        else:
          n3 += '0'

      n4 = -(int(n3,2) + 1)
      print("\n\tConversao de numero negativo # "+str(n4))
      return n4
  else:
    return Uint_32_Input_Registers_Most_Significant_Bits * 65536 + Uint_32_Input_Registers_Less_Significant_Bits

def convert_parameters_int_16(Uint_16_Input_Register):
  """
    Recebe os parâmetro lidos do registrador do inversor
      Estradas:
        Uint_16_Input_Register: valor vindo do registrador.
        Função: Converter o valor o registrador do inversor em valor do tipo inteiro com sinal
  """
  if Uint_16_Input_Register > 32767:
      
      bin1 = bin(Uint_16_Input_Register)
      
      n0 = int(bin1, 2)
      n1 = int(bin2, 2)

      n2 = bin(n1+n0)
      n3 = '0b'
      for bit in range(0,15,1):
        if n0[bit] == '0':
          n3 += '1'
        else:
          n3 += '0'

      n4 = -(int(n3,2) + 1)
      print("\n\tConversao de numero negativo # "+str(n4))
      return n4
  else:
    return Uint_16_Input_Register


def convert_input_register_value_to_real_value(Input_Register_Value, Scale_Factor):
  """
    Recebe o parâmetro lido pelo inversor, já convertido de uint32 (se necessário)
    Entradas:
      Input_Register_Value: Valor enviado pelo inversor, sem conversão para valores reais
      Scale_Factor: Fator de escala necessário para converter o número em um número com valor real (Tensão, Corrente, Potência, Energia, etc)
      Função: Dado um número do tipo inteiro, e um fator de escala, essa função realiza a conversão deste número para valores de grandezas reais, como tensão em Volts,
      Corrente em Amperes, etc.
  """
  return Input_Register_Value*Scale_Factor
def on_connect(client, userdata, flags, rc):
  print("Connected with result code "+str(rc))

#Função on_message, responsável por exibir os valores erunnviados
def on_message(client, userdata, msg):
  print(msg.topic+" "+str(msg.payload.decode("utf-8")))

def mqtt_publish(Client_MQTT, Topic, Value):
  mqtt_rst = Client_MQTT.publish(Topic, Value)
  time.sleep(0.3)

if __name__ == "__main__":
  main()      
