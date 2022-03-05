#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
sys.path.append('/Configurations/')

from Topics import Topics
from DataBaseConfigurations import DataBase, DataBaseHOST, DataBasePORT, UserName, Password 

from datetime import datetime
import paho.mqtt.client as mqtt
import time
from influxdb import InfluxDBClient

def main():
  """
  Nome: main
  Entradas: Sem parâmetros de entrada.
  Função: É a principal função do programa principal. Realiza o manejo de informações
  entre o inversor de frequência, e salva os dados no InfluxDB.
  Objetos:
  Client_ModBus (Objeto responsável pela comunicação ModBus TCP/IP).
  Client_MQTT (Objeto responsável pela comunicação com o Banco de Dados na rede externa, no CPD)
  Variáveis:
		
		Terminal de Potência | Especificação do Terminal |     Tipo de Variável    | Momento de medição | Unidade |              Nome da Variável
------------------------------------------------------------------------------------------------------------------------------------------------------------------
  """

  client = mqtt.Client("solis_scada_10kw")
  client.on_connect = on_connect
  client.on_message = on_message
  client.connect("mqtt.eclipseprojects.io", 1883, 60)
  print("Conectado ao Broker")

  while True:
    client.loop_start()
    time.sleep(10)

#@timeout(5)
def send_data_to_influx_db(Client_InfluxDB, Measurement_Name, Measurement_Value):
  # ???? Measurement_Name = Topic ????
  """
    Recebe o nome da Measurement e o seu valor
    Entradas:
      Measurement_Name: Nome da Medição realizada a ser salva no banco de dados
      Measurement_Value: Valor da Medição realizada a ser salva no banco de dados
      Função: Elaborar um Json com o nome e valor da Measurement, e salvar os dados no InfluxDB
  """
  #  !?!? NAO SEI COMO FUNCIONA Json !?!?
  Json_Body_Message =[
  {
    "measurement" : Measurement_Name,
    "fields" : {
      "value" : float(Measurement_Value),
      }
  }
  ]
  
  Client_InfluxDB.write_points(Json_Body_Message)
  print("Dados Salvos no Banco de Dados")

def on_connect(client, userdata, flag, rc):
  for topic in Topics:
    client.subscribe(topic)


#Função on_message, responsável por exibir os valores enviados
def on_message(client, userdata, msg):
  # CPD enviando dados para o InfluxDB
  # As informacoes de DataBaseConfigurations sao do CPD certo, e nao da Beagle ???
  Client_InfluxDB = InfluxDBClient(DataBaseHOST,DataBasePORT,UserName,Password,DataBase)
  send_data_to_influx_db(Client_InfluxDB, msg.topic, msg.payload.decode("utf-8"))
  print("\t -"+str(msg.topic)+" "+str(msg.payload.decode("utf-8")))
  
if __name__ == "__main__":
  main()
