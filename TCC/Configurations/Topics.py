
ID = "Solis_BRAZIL_RS_SantaMaria_UFSM_INRI_09E"
Topics =  [                                                                                                                                                              
           #str(ID)+"Year",
           #str(ID)+"Month",
           #str(ID)+"Day" ,
           #str(ID)+"Hour",
           #str(ID)+"Minute",

           #str(ID)+"Second",
          # str(ID)+"Inverter_Total_PowerGen_kWh",
          # str(ID)+"Inverter_Month_PowerGen_kWh",
          # str(ID)+"Inverter_Today_PowerGen_kWh",
          # str(ID)+"Inverter_Anual_PowerGen_kWh",
          
          # str(ID)+"Total_DC_Output_Po_W",
          # str(ID)+"PhaseA_Voltage_V", 
          # str(ID)+"PhaseA_Current_A", 
          # str(ID)+"Active_Power_W",                   
           #str(ID)+"Reactive_Power_VAr",
           
           #str(ID)+"Apparent_Power_VA",                              
         #  str(ID)+"Standard_Working_Mode",
         #  str(ID)+"Grid Frequency",
         #  str(ID)+"Current_Inverter_State",
           #str(ID)+"Reactive_Power_Porcentage",
           
           #str(ID)+"Eletricity_Meter_Total_Active_Power_Generation_Wh",
           #str(ID)+"Meter_Voltage",                                                    
          # str(ID)+"Meter_Active_Power_W",                                         
          # str(ID)+"Energy_Storage_Control_Switch_READ",                                  
          # str(ID)+"Battery_Capacity_SOC",                                               
           
          # str(ID)+"Battery_Health_SOH",                                  
          # str(ID)+"House_Load_Power_W",                                              
          # str(ID)+"Bypass_Load_Power_W",                                        
           #str(ID)+"Battery_Power_W",                                              
           #str(ID)+"Total_Battery_Charge",                                            
           
           #str(ID)+"Battery_Discharge_Capacity",                                               
           #str(ID)+"Total_Power_Imported_from_Grid_kWh",                                               
           #str(ID)+"Total_Power_Exported_to_Grid_kWh",                                               
           #str(ID)+"Power_Imported_from_Grid_Today_kWh",                                         
           #str(ID)+"Power_Imported_from_Grid_Yesterday_kWh",                                          
           
           #str(ID)+"Meter_AC_VoltageA_V",                                                       
           #str(ID)+"Meter_AC_Current_A",                                                        
           #str(ID)+"Meter_Active_PowerA_kW",                                                       
           #str(ID)+"Meter_Reactive_PowerA_Var",                                                
           #str(ID)+"Input_LimitedActivePower",                                                         
           
           #str(ID)+"Input_ActualPowerLimit",                                              
           #str(ID)+"Power_On_Off",                                                    
           #str(ID)+"Power_Limit_Setting",                                              
           #str(ID)+"Power_Limit_Switch",                                                                     
           #str(ID)+"Actual_Power_Limit_Value_W",                                        
           
           str(ID)+"Energy_Storage_Control_switch_WRITE",
           str(ID)+"Battery_Current",
           #str(ID)+"Fault_Code3",                                                              
           #str(ID)+"Battery_Voltage",                                                    
           #str(ID)+"LLCBus_Voltage",                                                        
           #str(ID)+"Bypass_AC_Voltage",                                                                 
           
           #str(ID)+"Bypass_AC_Current",                                                      
           #str(ID)+"Battery_BMS_Voltage",                                                     
           #str(ID)+"Battery_Failure_Information_1",                                               
           #str(ID)+"Battery_Failure_Information_2",                                                    
           str(ID)+ "Bypass_Power_enable_setting",                                                           
           
           str(ID)+"Bypass_Power_supply_Voltage_setting",                                               
           str(ID)+"Bypass_Power_supply_Reference_Frequency_Setting",                                         
           str(ID)+"Battery_Charge_and_Discharge_enable_setting",                                             
           str(ID)+"Battery_Direction_Direction_setting",                                        
           str(ID)+"Battery_Charge_and_Discharge_Current_setting",                                  
            
           str(ID)+"Battery_Charge_Current_Maximum",                                       
           str(ID)+"Battery_Charge_Discharge_Maximum",                                        
           str(ID)+"Battery_Undervoltage_Protection",                                               
           str(ID)+"Battery_Float_Voltage",                                                  
           str(ID)+"Battery_Charge_Voltage",                                                           
           
           str(ID)+"Battery_Overvoltage_Protection",                                            
           #str(ID)+"Overload_Buck_setting",                                           
           #str(ID)+"Grid_Level_Undervoltage_Threshold",                                            
           #str(ID)+"Grid_Level_Overvoltage_Threshold",                                                       

           str(ID)+"Load_W"
]

INV_REGS = [                                                                            
            
             #[ 33000, 16, 'none',          1,      0, 0, 0, 4, str(ID)+"Protocol_Version"   ],           
           # | Address | Length | Convertion_name | Scale | REG_Value | Numeric_Value | Signal | Function | Name |
             #[ 33022, 16, 'none',          1,      0, 0, 0, 4, str(ID)+"Year"   ],  
             #[ 33023, 16, 'none',          1,      0, 0, 0, 4, str(ID)+"Month"  ],           
             #[ 33024, 16, 'none',          1,      0, 0, 0, 4, str(ID)+"Day"    ],           
             #[ 33025, 16, 'none',          1,      0, 0, 0, 4, str(ID)+"Hour"   ],           
             #[ 33026, 16, 'none',          1,      0, 0, 0, 4, str(ID)+"Minute" ],

             #[ 33027, 16, 'none',          1,      0, 0, 0, 4, str(ID)+"Second"                      ],     
             #[ 33029, 32, 'input_to_real', 1,      0, 0, 0, 4, str(ID)+"Inverter_Total_PowerGen_kWh" ],
             #[ 33031, 32, 'input_to_real', 1,      0, 0, 0, 4, str(ID)+"Inverter_Month_PowerGen_kWh" ],
             #[ 33035, 16, 'input_to_real', 0.1,    0, 0, 0, 4, str(ID)+"Inverter_Today_PowerGen_kWh" ],
             #[ 33037, 32, 'input_to_real', 1,      0, 0, 0, 4, str(ID)+"Inverter_Anual_PowerGen_kWh" ],

           # | Address | Length | Convertion_name | Scale | REG_Value | Numeric_Value | Signal | Function | Name |
             [ 33057, 32, 'input_to_real', 1,      0, 0, 0, 4, str(ID)+"Total_DC_Output_Po_W",      'none', 0 ],
             [ 33000, 16, 'none',           0 ,    0, 0, 0, 4, str(ID)+"Product_Model",             'none', 0 ],
             [ 33095, 16, 'none',           0 ,    0, 0, 0, 4, str(ID)+"Current_State_of_Inverter", 'none', 0 ],
             [ 33118, 16, 'none',           0 ,    0, 0, 0, 4, str(ID)+"Fault_Status_03",           'none', 0 ],
             [ 33120, 16, 'none',           0 ,    0, 0, 0, 4, str(ID)+"Fault_Status_05",           'none', 0 ],
             [ 33121, 16, 'none',           0 ,    0, 0, 0, 4, str(ID)+"Working_Status",            'none', 0 ],

             #[ 33145, 16, 'none',           0,     0, 0, 0, 4, str(ID)+"BMS_info1"                ],
             #[ 33146, 16, 'none',           0,     0, 0, 0, 4, str(ID)+"BMS_info2"                ],

             [ 33076, 16, 'input_to_real', 0.1,    0, 0, 0, 4, str(ID)+"PhaseA_Current_A", 'none', 0], 
             [ 33073, 16, 'input_to_real', 0.1,    0, 0, 0, 4, str(ID)+"PhaseA_Voltage_V", 'none', 0], 
             [ 33079, 32, 'input_to_real', 1,      0, 0, 1, 4, str(ID)+"Active_Power_W",   'none', 0],  
             #[ 33081, 32, 'input_to_real', 1,      0, 0, 1, 4, str(ID)+"Reactive_Power_VAr"      ], 
             
             #[ 33083, 32, 'input_to_real', 1,      0, 0, 1, 4, str(ID)+"Apparent_Power_VA"         ],
             [ 33091, 16, 'input_to_real', 1,      0, 0, 0, 4, str(ID)+"Standard_Working_Mode",  'none', 0 ],
             #[ 33094, 16, 'input_to_real', 0.01,   0, 0, 0, 4, str(ID)+"Grid Frequency"            ],
             [ 33095, 16, 'input_to_real', 1,      0, 0, 0, 4, str(ID)+"Current_Inverter_State", 'none', 0, 0 ],
             #[ 33106, 16, 'input_to_real', 0.01,   0, 0, 1, 4, str(ID)+"Reactive_Power_Porcentage" ],
             
             #[ 33126, 32, 'input_to_real', 1,      0, 0, 0, 4, str(ID)+"Eletricity_Meter_Total_Active_Power_Generation_Wn" ],
             [ 33128, 16, 'input_to_real', 0.1,    0, 0, 0, 4, str(ID)+"Meter_Voltage",                      'none', 0 ],
             [ 33130, 32, 'input_to_real', 1,      0, 0, 1, 4, str(ID)+"Meter_Active_Power_W",               'none', 0 ],
             [ 33132, 16, 'input_to_real', 1,      0, 0, 0, 4, str(ID)+"Energy_Storage_Control_Switch_READ", 'none', 0 ],
             [ 33133, 16, 'input_to_real', 0.1,      0, 0, 0, 4, str(ID)+"Battery_Voltage",                  'none', 0 ],
             [ 33134, 16, 'input_to_real', 0.1,      0, 0, 1, 4, str(ID)+"Battery_Current",                  'none', 0 ],

             [ 33135, 16, 'input_to_real', 1,      0, 0, 1, 4, str(ID)+"Battery_Current_Direction", 'none', 0 ],
             [ 33139, 16, 'input_to_real', 1,      0, 0, 0, 4, str(ID)+"Battery_Capacity_SOC",      'none', 0 ],

           # | Address | Length | Convertion_name | Scale | REG_Value | Numeric_Value | Signal | Function | Name |
             [ 33140, 16, 'input_to_real', 1,      0, 0, 0, 4, str(ID)+"Battery_Health_SOH", 'none', 0 ],
             #[ 33147, 16, 'input_to_real', 1,      0, 0, 0, 4, str(ID)+"House_Load_Power_W"   ],
             #[ 33148, 16, 'input_to_real', 1,      0, 0, 0, 4, str(ID)+"Bypass_Load_Power_W"  ],
             [ 33149, 32, 'input_to_real', 1,      0, 0, 1, 4, str(ID)+"Battery_Power_W",      'none', 0 ],
             [ 33161, 32, 'input_to_real', 0.001,  0, 0, 0, 4, str(ID)+"Total_Battery_Charge", 'none', 0 ],
             
           # | Address | Length | Convertion_name | Scale | REG_Value | Numeric_Value | Signal | Function |  Name |
             [ 33167, 16, 'input_to_real', 0.01,   0, 0, 0, 4, str(ID)+"Battery_Discharge_Capacity", 'none', 0 ],
             #[ 33169, 32, 'input_to_real', 0.001,  0, 0, 0, 4, str(ID)+"Total_Power_Imported_from_Grid_kWh"     ],
             #[ 33173, 32, 'input_to_real', 0.001,  0, 0, 0, 4, str(ID)+"Total_Power_Exported_to_Grid_kWh"       ],
             #[ 33175, 16, 'input_to_real', 0.01,   0, 0, 0, 4, str(ID)+"Power_Imported_from_Grid_Today_kWh"     ],       
             #[ 33176, 16, 'input_to_real', 0.01,   0, 0, 0, 4, str(ID)+"Power_Imported_from_Grid_Yesterday_kWh" ],   
             
             [ 33251, 16, 'input_to_real', 0.1,    0, 0, 0, 4, str(ID)+"Meter_AC_VoltageA_V",    'none', 0 ],                   
             [ 33252, 16, 'input_to_real', 0.01,   0, 0, 0, 4, str(ID)+"Meter_AC_Current_A",     'none', 0 ],                   
             [ 33257, 32, 'input_to_real', 1,      0, 0, 1, 4, str(ID)+"Meter_Active_PowerA_kW", 'none', 0 ],
             #[ 33265, 32, 'input_to_real', 1,      0, 0, 1, 4, str(ID)+"Meter_Reactive_PowerA_Var" ],
             #[ 33100, 32, 'input_to_real', 1,      0, 0, 1, 4, str(ID)+"Input_LimitedActivePower"  ],

             #[ 33104, 16, 'input_to_real', 0.01,   0, 0, 0, 4, str(ID)+"Input_ActualPowerLimit"     ],
             #[ 43004, 16, 'input_to_real', 1,      0, 0, 0, 6, str(ID)+"Minute"               ],
             [ 43007, 16, 'input_to_real', 1,      0, 0, 0, 6, str(ID)+"Power_On_Off",               'none', 0 ],
             [ 43052, 16, 'input_to_real', 0.01,   0, 0, 0, 6, str(ID)+"Power_Limit_Setting",        'none', 0 ],
             [ 43070, 16, 'input_to_real', 1,      0, 0, 0, 6, str(ID)+"Power_Limit_Switch",         'none', 0 ],
             [ 43081, 16, 'input_to_real', 10,     0, 0, 1, 6, str(ID)+"Actual_Power_Limit_Value_W", 'none', 0 ],


             # BATTEY INFORMATIONS
             
             # | Address | Length | Convertion_name | Scale | REG_Value | Numeric_Value | Signal | Function |  Name |
             [ 33138, 16, 'input_to_real', 0.1,    0, 0, 0, 4, str(ID)+"Bypass_AC_Current", 'none', 0 ],
             [ 33134, 16, 'input_to_real', 0.1,    0, 0, 0, 4, str(ID)+"Battery_Current",   'none', 0 ],
             #[ 33118, 16, 'input_to_real', 1,      0, 0, 0, 4, str(ID)+"Fault_Code3"                        ],
             [ 33133, 16, 'input_to_real', 0.1,    0, 0, 0, 4, str(ID)+"Battery_Voltage", 'none', 0, 0 ],
             #[ 33136, 16, 'input_to_real', 0.1,    0, 0, 0, 4, str(ID)+"LLCBus_Voltage"                     ],
             [ 33137, 16, 'input_to_real', 0.1,     0, 0, 0, 4, str(ID)+"Bypass_AC_Voltage", 'none', 0, 0  ],
             
             [ 43110, 16, 'input_to_real', 1,      0, 0, 0, 6, str(ID)+"Energy_Storage_Control_switch_WRITE", 'none', 0, 0 ],
             [ 33141, 16, 'input_to_real', 0.01,   0, 0, 0, 4, str(ID)+"Battery_BMS_Voltage",                 'none', 0, 0 ],
             [ 33145, 16, 'input_to_real', 1,      0, 0, 0, 4, str(ID)+"Battery_Failure_Information_",        'none', 0, 0 ],
             [ 33146, 16, 'input_to_real', 1,      0, 0, 0, 4, str(ID)+"Battery_Failure_Information_",        'none', 0, 0 ],
             [ 43112, 16, 'input_to_real', 1,      0, 0, 0, 6, str(ID)+"Bypass_Power_enable_setting",         'none', 0, 0 ],
             
             [ 43112, 16, 'input_to_real', 0.1,    0, 0, 0, 6, str(ID)+"Bypass_Power_supply_Voltage_setting",  'none', 0, 0 ],
             #[ 43113, 16, 'input_to_real', 0.01,   0, 0, 0, 6, str(ID)+"Bypass_Power_supply_Reference_Frequency_Setting" ],
             [ 43114, 16, 'input_to_real', 1,      0, 0, 0, 6, str(ID)+"Battery_Charge_and_Discharge_enable_setting",  'none', 0, 0 ],#talvez, efeito 0
             [ 43115, 16, 'input_to_real', 1,      0, 0, 0, 6, str(ID)+"Battery_Direction_Direction_setting",          'none', 0, 0 ],#talvez, efeito 0
             [ 43116, 16, 'input_to_real', 0.1,    0, 0, 0, 6, str(ID)+"Battery_Charge_and_Discharge_Current_setting", 'none', 0, 0 ],#talvez, efeito 0
             
             # | Address | Length | Convertion_name | Scale | REG_Value | Numeric_Value | Signal | Function |  Name |
             [ 43117, 16, 'input_to_real', 0.1,    0, 0, 0, 6, str(ID)+"Battery_Charge_Current_Maximum",   'none', 0, 0 ],
             [ 43118, 16, 'input_to_real', 0.1,    0, 0, 0, 6, str(ID)+"Battery_Charge_Discharge_Maximum", 'none', 0, 0 ],
             [ 43119, 16, 'input_to_real', 0.1,    0, 0, 0, 6, str(ID)+"Battery_Undervoltage_Protection",  'none', 0, 0 ],
             [ 43120, 16, 'input_to_real', 0.1,    0, 0, 0, 6, str(ID)+"Battery_Float_Voltage",            'none', 0, 0 ],
             [ 43121, 16, 'input_to_real', 0.1,    0, 0, 0, 6, str(ID)+"Battery_Charge_Voltage",           'none', 0, 0 ],
            
             [ 43122, 16, 'input_to_real', 0.1,    0, 0, 0, 6, str(ID)+"Battery_Overvoltage_Protection", 'none',0 ],

             #[ 43143, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"Timed_charge_start_hour"    ],
             #[ 43144, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"Timed_charge_start_minute"    ],
             #
             #[ 43145, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"Timed_charge_end_hour"    ],
             #[ 43146, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"Timed_charge_end_minute"    ],
             #
             #[ 43147, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"Timed_discharge_start_hour"      ],
             #[ 43148, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"Timed_discharge_start_minute"   ],
             #
             #[ 43149, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"Timed_discharge_end_hour"     ],
             #[ 43150, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"Timed_discharge_end_minute"   ],
             #
             #[ 43141, 16, 'input_to_real', 0.1,    0, 0, 0, 6, str(ID)+"Timed_current_charge"   ],
             #[ 43142, 16, 'input_to_real', 0.1,    0, 0, 0, 6, str(ID)+"Timed_current_discharge"   ],
             
             [ 43008, 16, 'input_to_real', 1,      0, 0, 0, 6, str(ID)+"initial_startup_setting", 'none', 0, 0 ],  # read
             [ 43009, 16, 'none',          1,      0, 0, 0, 6, str(ID)+"current_battery_model",   'none', 0, 0 ],  # read
             #[ 43010, 16, 'input_to_real', 1,      0, 0, 0, 6, str(ID)+"overcharge_SOC"                 ],  # read
             #[ 43011, 16, 'input_to_real', 1,      0, 0, 0, 6, str(ID)+"overdischarge_SOC"              ],  # read
             #[ 43014, 16, 'input_to_real', 0.1,    0, 0, 0, 6, str(ID)+"charge_overvoltage_threshold_V" ],  # read; write 540 [54V]
             ##                                                                  
             #[ 43015, 16, 'input_to_real', 0.1,    0, 0, 0, 6, str(ID)+"discharge_undervoltage_threshold_V"    ], # read; write 540 [54V]
             [ 43016, 16, 'input_to_real', 0.1,    0, 0, 0, 6, str(ID)+"floating_charge_voltage_threshold_V",   'none', 0, 0 ], # read; write ---
             [ 43017, 16, 'input_to_real', 0.1,    0, 0, 0, 6, str(ID)+"equalizing_charge_voltage_threshold_V", 'none', 0, 0 ], # read; write ---
             [ 43018, 16, 'input_to_real', 1,      0, 0, 0, 6, str(ID)+"force_charge_SOC",                      'none', 0, 0 ], # read; write ---
             [ 43019, 16, 'input_to_real', 1,      0, 0, 0, 6, str(ID)+"rated_capacity_Ah",                     'none', 0, 0 ], # read; write ---
             #                                                                  
             # | Address | Length | Convertion_name | Scale | REG_Value | Numeric_Value | Signal | Function |  Name |
             #[ 43027, 16, 'input_to_real', 10,     0, 0, 0, 6, str(ID)+"battery_force_charge_power_limtation_W"    ], # read; write ---
             [ 43028, 16, 'input_to_real', 1,      0, 0, 0, 6, str(ID)+"battery_force_charge_source", 'none', 0 ], # read; write ---
             #[ 43128, 16, 'input_to_real', 10,     0, 0, 1, 6, str(ID)+"RC_ative_power_on_inverter_AC_grid_port_W" ], # read; write ---
             [ 43129, 16, 'input_to_real', 10,     0, 0, 0, 6, str(ID)+"RC_force_battery_discharge_power_W", 'none', 0, 0 ], # read; write ---
             [ 43130, 16, 'input_to_real', 10,     0, 0, 0, 6, str(ID)+"battery_charge_limit_power_W",       'none', 0, 0 ], # read; write ---
             ##                                                                  
             [ 43131, 16, 'input_to_real', 10,     0, 0, 0, 6, str(ID)+"battery_discharge_limit_power_W",   'none', 0, 0 ], # read; write ---
             [ 43135, 16, 'input_to_real', 1,      0, 0, 0, 6, str(ID)+"RC_force_battery_charge_discharge", 'none', 0, 0 ], # read; write ---
             [ 43136, 16, 'input_to_real', 10,     0, 0, 0, 6, str(ID)+"RC_force_battery_charge_power_W",   'none', 0, 0 ], # read; write ---
             [ 43357, 16, 'input_to_real', 1,      0, 0, 0, 6, str(ID)+"charging_priority",                 'none', 0, 0 ] # read; write ---
             #[ 43132, 16, 'input_to_real', 1,      0, 0, 0, 6, str(ID)+"RC_grid_adjustment"                ],
             ##                                                                  
             #[ 43133, 16, 'input_to_real', 10,     0, 0, 0, 6, str(ID)+"RC_active_power_at_grid"   ],
             #[ 43134, 16, 'input_to_real', 10,     0, 0, 0, 6, str(ID)+"RC_reactive_power_at_grid" ],
             #[ 43012, 16, 'input_to_real', 0.1,    0, 0, 0, 6, str(ID)+"max_charge_current_A"      ],
             #[ 43013, 16, 'input_to_real', 0.1,    0, 0, 0, 6, str(ID)+"max_discharge_current_A"   ]
             #[ 43154, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43154"   ],
             #[ 43155, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43155"   ],
             #[ 43156, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43156"   ],
             #                                                                  
             #[ 43157, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43157"   ],
             #[ 43158, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43158"   ],
             #[ 43159, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43159"   ],
             #[ 43160, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43160"   ],
             #[ 43161, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43161"   ],
             #                                                                  
             #[ 43162, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43162"   ],
             #[ 43163, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43163"   ],
             #[ 43164, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43164"   ],
             #[ 43165, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43165"   ],
             #[ 43166, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43166"   ],
             #                                                                  
             #[ 43167, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43167"   ],
             #[ 43168, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43168"   ],
             #[ 43169, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43169"   ],
             #[ 43170, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43170"   ],
             #[ 43171, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43171"   ],

             #[ 43172, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43172"   ],
             #[ 43173, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43173"   ],
             #[ 43174, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43174"   ],
             #[ 43175, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43175"   ],
             #[ 43176, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43176"   ],
             #
             #[ 43177, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43177"   ],
             #                                                                  
             #[ 43178, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43178"   ],
             #[ 43179, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43179"   ],
             #[ 43180, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43180"   ],
             #[ 43181, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43181"   ],
             #[ 43182, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43182"   ],
             #                                                                  
             #[ 43183, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43183"   ],
             #[ 43184, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43184"   ],
             #[ 43185, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43185"   ],
             #[ 43186, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43186"   ],
             #[ 43187, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43187"   ],
             #                                                                  
             #[ 43188, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43188"   ],
             #[ 43189, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43189"   ],
             #[ 43190, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43190"   ],
             #[ 43191, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43191"   ],
             #[ 43192, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43192"   ],
             #                                                                  
             #[ 43193, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43193"   ],
             #[ 43194, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43194"   ],
             #[ 43195, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43195"   ],
             #[ 43196, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43196"   ],
             #[ 43197, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43197"   ],
             #                                                                  
             #[ 43198, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43198"   ],
             #[ 43199, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43199"   ],
             #[ 43200, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43200"   ],
             #[ 43201, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43201"   ],
             #[ 43202, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43202"   ],
             #                                                                  
             #[ 43203, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43203"   ],
             #[ 43204, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43204"   ],
             #[ 43205, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43205"   ],
             #[ 43206, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43206"   ],
             #[ 43207, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43207"   ],
             #                                                                  
             #[ 43208, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43208"   ],
             #[ 43209, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43209"   ],
             #[ 43210, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43210"   ],
             #[ 43211, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43211"   ],
             #[ 43212, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43212"   ],
             #                                                                  
             #[ 43213, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43213"   ],
             #[ 43214, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43214"   ],
             #[ 43215, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43215"   ],
             #[ 43216, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43216"   ],
             #[ 43217, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43217"   ],
             #                                                                  
             #[ 43218, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43218"   ],
             #[ 43219, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43219"   ],
             #[ 43220, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43220"   ],
             #[ 43221, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43221"   ],
             #[ 43222, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43222"   ],
             #                                                                  
             #[ 43223, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43223"   ],
             #[ 43224, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43224"   ],
             #[ 43225, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43225"   ],
             #[ 43226, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43226"   ],
             #[ 43227, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43227"   ],
             #                                                                  
             #[ 43228, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43228"   ],
             #[ 43229, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43229"   ],
             #[ 43230, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43230"   ],
             #[ 43231, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43231"   ],
             #[ 43232, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43232"   ],
             #                                                                  
             #[ 43233, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43233"   ],
             #[ 43234, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43234"   ],
             #[ 43235, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43235"   ],
             #[ 43236, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43236"   ],
             #[ 43237, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43237"   ],
             #                                                                  
             #[ 43238, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43238"   ],
             #[ 43239, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43239"   ],
             #[ 43240, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43240"   ],
             #[ 43241, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43241"   ],
             #[ 43242, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43242"   ],
             #                                                                  
             #[ 43243, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43243"   ],
             #[ 43244, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43244"   ],
             #[ 43245, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43245"   ],
             #[ 43246, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43246"   ],
             #[ 43247, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43247"   ],
             #                                                                  
             #[ 43248, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43248"   ],
             #[ 43249, 16, 'input_to_real', 1,    0, 0, 0, 6, str(ID)+"reg_43249"   ]
             
              
             
             #[ 43123, 16, 'input_to_real', 1,      0, 0, 0, 6, str(ID)+"Overload_Buck_setting"             ],
             #[ 43094, 16, 'input_to_real', 1,      0, 0, 0, 6, str(ID)+"Grid_Level_Undervoltage_Threshold" ],
             #[ 43090, 16, 'input_to_real', 1,      0, 0, 0, 6, str(ID)+"Grid_Level_Overvoltage_Threshold"  ]



]

#   !!!! PARA O WRITE REGISTER FUNCIONAR  ÃEH FUNDAMENTAL RODAR O CÃODIGO COMO sudo ou root !!!!
WRITE_REGS = [
       
              
              # | Address | Value | RETURN |  Name |
             [ 43007, 'none', 0, str(ID)+"Power_On_Off"                        ],
             [ 43052, 9800,  0, str(ID)+"Power_Limit_Setting"                 ],            
             [ 43070, 170,    0, str(ID)+"Power_Limit_Switch"                  ], #85 desliga, 170 liga, outros nao significam nada
             [ 43081, 500,    0, str(ID)+"Actual_Power_Limit_Value_W"          ],
             [ 43110, 0, 0, str(ID)+"Energy_Storage_Control_switch_WRITE" ],
             
             [ 43111, 0,      0, str(ID)+"Bypass_Power_enable_setting"                     ],
             [ 43112, 2000,   0, str(ID)+"Bypass_Power_supply_Voltage_setting"             ],
             #[ 43113, 5000,   0, str(ID)+"Bypass_Power_supply_Reference_Frequency_Setting" ],
             
            [ 43114, 1, 0, str(ID)+"Battery_Charge_and_Discharge_enable_setting"     ],
            [ 43115, 'none',      0, str(ID)+"Battery_Direction_Direction_setting"             ],
            [ 43116, 'none',    0, str(ID)+"Battery_Charge_and_Discharge_Current_setting"    ],
            [ 43117, 80,   0, str(ID)+"Battery_Charge_Current_Maximum"    ],
            [ 43118, 80,   0, str(ID)+"Battery_Charge_Discharge_Maximum"  ],
            
            #[ 43119, 'none', 0, str(ID)+"Battery_Undervoltage_Protection"   ],
            #[ 43120, 'none', 0, str(ID)+"Battery_Float_Voltage"             ],
            #[ 43121, 'none', 0, str(ID)+"Battery_Charge_Voltage"            ],
            #[ 43122, 'none', 0, str(ID)+"Battery_Overvoltage_Protection"    ],
             
           
            #[ 43115, 0,     0, str(ID)+"Battery_Direction_Direction_setting"             ],
            #[ 43116, 110,   0, str(ID)+"Battery_Charge_and_Discharge_Current_setting"    ],
           # [ 43117, 250,   0, str(ID)+"Battery_Charge_Current_Maximum"    ],
           # [ 43118, 250,   0, str(ID)+"Battery_Charge_Discharge_Maximum"  ],
           ## 
            [ 43119, 405, 0, str(ID)+"Battery_Undervoltage_Protection"   ],
            [ 43120, 525, 0, str(ID)+"Battery_Float_Voltage"             ],
            [ 43121, 550, 0, str(ID)+"Battery_Charge_Voltage"            ],
            [ 43122, 540, 0, str(ID)+"Battery_Overvoltage_Protection"    ],
              
             #[ 43143, 'none', 0, str(ID)+"Timed_charge_start_hour"      ],
             #[ 43144, 'none', 0, str(ID)+"Timed_charge_start_minute"    ],
             #[ 43145, 'none', 0, str(ID)+"Timed_charge_end_hour"        ],
             #[ 43146, 'none', 0, str(ID)+"Timed_charge_end_minute"      ], 
             #[ 43147, 'none', 0, str(ID)+"Timed_discharge_start_hour"   ],   
             #[ 43148, 'none', 0, str(ID)+"Timed_discharge_start_minute" ],   
 
             #[ 43149, 'none', 0, str(ID)+"Timed_discharge_end_hour"     ],
             #[ 43150, 'none', 0, str(ID)+"Timed_discharge_end_minute"   ],

             #
             #[ 43141, 250, 0, str(ID)+"Timed_current_charge"   ],
             #[ 43142, 250, 0, str(ID)+"Timed_current_discharge"   ],

              
             [ 43008, 0,      0, str(ID)+"initial_startup_setting"        ],  # read
             [ 43009, 2,      0, str(ID)+"current_battery_model"          ],  # read; write 2
             #[ 43010, 'none', 0, str(ID)+"overcharge_SOC"                 ],  # read; write 90
             #[ 43011, 10,     0, str(ID)+"overdischarge_SOC"              ],  # read; write 10
             #[ 43014, 540,    0, str(ID)+"charge_overvoltage_threshold_V" ],  # read; write 540
             ##                            
             #[ 43015, 405,    0, str(ID)+"discharge_undervoltage_threshold_V"    ], # read; write 405
             [ 43016, 525,    0, str(ID)+"floating_charge_voltage_threshold_V"   ], # read; write 525
             [ 43017, 550,    0, str(ID)+"equalizing_charge_voltage_threshold_V" ], # read; write 550
             [ 43018, 10,     0, str(ID)+"force_charge_SOC"                      ], # read; write 10
             [ 43019, 100,    0, str(ID)+"rated_capacity_Ah"                     ], # read; write 100
             ##                            
             #[ 43027, 100,    0, str(ID)+"battery_force_charge_power_limtation_W"    ], # read; write 100
             [ 43028, 3,      0, str(ID)+"battery_force_charge_source"               ], # read; write ---
             #[ 43128, 250,    0, str(ID)+"RC_ative_power_on_inverter_AC_grid_port_W" ], # read; write 250
             [ 43129, 150,    0, str(ID)+"RC_force_battery_discharge_power_W"        ], # read; write 100
             [ 43130, 250,    0, str(ID)+"battery_charge_limit_power_W"              ], # read; write 150
             ##                            
             [ 43131, 250,    0, str(ID)+"battery_discharge_limit_power_W"   ], # read; write 150
             [ 43135, 2,      0, str(ID)+"RC_force_battery_charge_discharge" ], # read; write 1
             [ 43136, 150,    0, str(ID)+"RC_force_battery_charge_power_W"   ], # read; write 500
             [ 43357, 0,      0, str(ID)+"charging_priority"                 ]  # read; write 0
             #[ 43132, 1,      0, str(ID)+"RC_grid_adjustment"],
             ##
             #[ 43094, 'none', 0, str(ID)+"Grid_Level_Undervoltage_Threshold" ],
             #[ 43090, 'none', 0, str(ID)+"Grid_Level_Overvoltage_Threshold"  ],

             #[ 43133, 150,    0, str(ID)+"RC_active_power_at_grid"   ],
             #[ 43134, 20,     0, str(ID)+"RC_reactive_power_at_grid" ],
             #[ 43012, 90,    0, str(ID)+"max_charge_current_A"      ],
             #[ 43013, 90,    0, str(ID)+"max_discharge_current_A"   ],
             #[ 43108, 'none', 0,  str(ID)+"reg_43108"   ],
             #[ 43109, 'none', 0,  str(ID)+"reg_43109"   ],
             #[ 43124, 'none', 0,  str(ID)+"reg_43124"   ],
             #[ 43125, 'none', 0,  str(ID)+"reg_43125"   ],
             #[ 43126, 'none', 0,  str(ID)+"reg_43126"   ],
             #                                 
             #[ 43127, 'none', 0,  str(ID)+"reg_43127"   ],
             #[ 43128, 'none', 0,  str(ID)+"reg_43128"   ],
             #[ 43129, 'none', 0,  str(ID)+"reg_43129"   ],
             #[ 43130, 'none', 0,  str(ID)+"reg_43130"   ],
             #[ 43131, 'none', 0,  str(ID)+"reg_43131"   ],
             #                                 
             #[ 43132, 'none', 0,  str(ID)+"reg_43132"   ],
             #[ 43133, 'none', 0,  str(ID)+"reg_43133"   ],
             #[ 43134, 'none', 0,  str(ID)+"reg_43134"   ],
             #[ 43135, 'none', 0,  str(ID)+"reg_43135"   ],
             #[ 43136, 'none', 0,  str(ID)+"reg_43136"   ],
             #                               
             #[ 43137, 'none', 0,  str(ID)+"reg_43137"   ],
             #[ 43138, 'none', 0,  str(ID)+"reg_43138"   ],
             #[ 43139, 'none', 0,  str(ID)+"reg_43139"   ],
             #[ 43140, 'none', 0,  str(ID)+"reg_43140"   ],
             #[ 43151, 'none', 0,  str(ID)+"reg_43151"   ],
             #                               
             #[ 43152, 'none', 0,  str(ID)+"reg_43152"   ],
             #[ 43153, 'none', 0,  str(ID)+"reg_43153"   ],
             #[ 43154, 'none', 0,  str(ID)+"reg_43154"   ],
             #[ 43155, 'none', 0,  str(ID)+"reg_43155"   ],
             #[ 43156, 'none', 0,  str(ID)+"reg_43156"   ],
             #                              
             #[ 43157, 'none', 0,  str(ID)+"reg_43157"   ],
             #[ 43158, 'none', 0,  str(ID)+"reg_43158"   ],
             #[ 43159, 'none', 0,  str(ID)+"reg_43159"   ],
             #[ 43160, 'none', 0,  str(ID)+"reg_43160"   ],
             #[ 43161, 'none', 0,  str(ID)+"reg_43161"   ],
             #                               
             #[ 43162, 'none', 0,  str(ID)+"reg_43162"   ],
             #[ 43163, 'none', 0,  str(ID)+"reg_43163"   ],
             #[ 43164, 'none', 0,  str(ID)+"reg_43164"   ],
             #[ 43165, 'none', 0,  str(ID)+"reg_43165"   ],
             #[ 43166, 'none', 0,  str(ID)+"reg_43166"   ],
             #                               
             #[ 43167, 'none', 0,  str(ID)+"reg_43167"   ],
             #[ 43168, 'none', 0,  str(ID)+"reg_43168"   ],
             #[ 43169, 'none', 0,  str(ID)+"reg_43169"   ],
             #[ 43170, 'none', 0,  str(ID)+"reg_43170"   ],
             #[ 43171, 'none', 0,  str(ID)+"reg_43171"   ],

             #[ 43172, 'none', 0,  str(ID)+"reg_43172"   ],
             #[ 43173, 'none', 0,  str(ID)+"reg_43173"   ],
             #[ 43174, 'none', 0,  str(ID)+"reg_43174"   ],
             #[ 43175, 'none', 0,  str(ID)+"reg_43175"   ],
             #[ 43176, 'none', 0,  str(ID)+"reg_43176"   ],
             #
             #[ 43177, 'none', 0,  str(ID)+"reg_43177"   ],
             #                              
             #[ 43178, 'none', 0,  str(ID)+"reg_43178"   ],
             #[ 43179, 'none', 0,  str(ID)+"reg_43179"   ],
             #[ 43180, 'none', 0,  str(ID)+"reg_43180"   ],
             #[ 43181, 'none', 0,  str(ID)+"reg_43181"   ],
             #[ 43182, 'none', 0,  str(ID)+"reg_43182"   ],
             #                              
             #[ 43183, 'none', 0,  str(ID)+"reg_43183"   ],
             #[ 43184, 'none', 0,  str(ID)+"reg_43184"   ],
             #[ 43185, 'none', 0,  str(ID)+"reg_43185"   ],
             #[ 43186, 'none', 0,  str(ID)+"reg_43186"   ],
             #[ 43187, 'none', 0,  str(ID)+"reg_43187"   ],
             #                                 
             #[ 43188, 'none', 0,  str(ID)+"reg_43188"   ],
             #[ 43189, 'none', 0,  str(ID)+"reg_43189"   ],
             #[ 43190, 'none', 0,  str(ID)+"reg_43190"   ],
             #[ 43191, 'none', 0,  str(ID)+"reg_43191"   ],
             #[ 43192, 'none', 0,  str(ID)+"reg_43192"   ],
             #                                
             #[ 43193, 'none', 0,  str(ID)+"reg_43193"   ],
             #[ 43194, 'none', 0,  str(ID)+"reg_43194"   ],
             #[ 43195, 'none', 0,  str(ID)+"reg_43195"   ],
             #[ 43196, 'none', 0,  str(ID)+"reg_43196"   ],
             #[ 43197, 'none', 0,  str(ID)+"reg_43197"   ],
             #                             
             #[ 43198, 'none', 0,  str(ID)+"reg_43198"   ],
             #[ 43199, 'none', 0,  str(ID)+"reg_43199"   ],
             #[ 43200, 'none', 0,  str(ID)+"reg_43200"   ],
             #[ 43201, 'none', 0,  str(ID)+"reg_43201"   ],
             #[ 43202, 'none', 0,  str(ID)+"reg_43202"   ],
             #                           
             #[ 43203, 'none', 0,  str(ID)+"reg_43203"   ],
             #[ 43204, 'none', 0,  str(ID)+"reg_43204"   ],
             #[ 43205, 'none', 0,  str(ID)+"reg_43205"   ],
             #[ 43206, 'none', 0,  str(ID)+"reg_43206"   ],
             #[ 43207, 'none', 0,  str(ID)+"reg_43207"   ],
             #                                
             #[ 43208, 'none', 0,  str(ID)+"reg_43208"   ],
             #[ 43209, 'none', 0,  str(ID)+"reg_43209"   ],
             #[ 43210, 'none', 0,  str(ID)+"reg_43210"   ],
             #[ 43211, 'none', 0,  str(ID)+"reg_43211"   ],
             #[ 43212, 'none', 0,  str(ID)+"reg_43212"   ],
             #                            
             #[ 43213, 'none', 0,  str(ID)+"reg_43213"   ],
             #[ 43214, 'none', 0,  str(ID)+"reg_43214"   ],
             #[ 43215, 'none', 0,  str(ID)+"reg_43215"   ],
             #[ 43216, 'none', 0,  str(ID)+"reg_43216"   ],
             #[ 43217, 'none', 0,  str(ID)+"reg_43217"   ],
             #                               
             #[ 43218, 'none', 0,  str(ID)+"reg_43218"   ],
             #[ 43219, 'none', 0,  str(ID)+"reg_43219"   ],
             #[ 43220, 'none', 0,  str(ID)+"reg_43220"   ],
             #[ 43221, 'none', 0,  str(ID)+"reg_43221"   ],
             #[ 43222, 'none', 0,  str(ID)+"reg_43222"   ],
             #                                 
             #[ 43223, 'none', 0,  str(ID)+"reg_43223"   ],
             #[ 43224, 'none', 0,  str(ID)+"reg_43224"   ],
             #[ 43225, 'none', 0,  str(ID)+"reg_43225"   ],
             #[ 43226, 'none', 0,  str(ID)+"reg_43226"   ],
             #[ 43227, 'none', 0,  str(ID)+"reg_43227"   ],
             #                                 
             #[ 43228, 'none', 0,  str(ID)+"reg_43228"   ],
             #[ 43229, 'none', 0,  str(ID)+"reg_43229"   ],
             #[ 43230, 'none', 0,  str(ID)+"reg_43230"   ],
             #[ 43231, 'none', 0,  str(ID)+"reg_43231"   ],
             #[ 43232, 'none', 0,  str(ID)+"reg_43232"   ],
             #                                 
             #[ 43233, 'none', 0,  str(ID)+"reg_43233"   ],
             #[ 43234, 'none', 0,  str(ID)+"reg_43234"   ],
             #[ 43235, 'none', 0,  str(ID)+"reg_43235"   ],
             #[ 43236, 'none', 0,  str(ID)+"reg_43236"   ],
             #[ 43237, 'none', 0,  str(ID)+"reg_43237"   ],
             #                                 
             #[ 43238, 'none', 0,  str(ID)+"reg_43238"   ],
             #[ 43239, 'none', 0,  str(ID)+"reg_43239"   ],
             #[ 43240, 'none', 0,  str(ID)+"reg_43240"   ],
             #[ 43241, 'none', 0,  str(ID)+"reg_43241"   ],
             #[ 43242, 'none', 0,  str(ID)+"reg_43242"   ],
             #                                 
             #[ 43243, 'none', 0,  str(ID)+"reg_43243"   ],
             #[ 43244, 'none', 0,  str(ID)+"reg_43244"   ],
             #[ 43245, 'none', 0,  str(ID)+"reg_43245"   ],
             #[ 43246, 'none', 0,  str(ID)+"reg_43246"   ],
             #[ 43247, 'none', 0,  str(ID)+"reg_43247"   ],
             #                                 
             #[ 43248, 'none', 0,  str(ID)+"reg_43248"   ],
             #[ 43249, 'none', 0,  str(ID)+"reg_43249"   ]
             



]
