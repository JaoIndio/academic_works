onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label clk /testesimon/SIMON1/clk
add wave -noupdate -label rst /testesimon/SIMON1/rst
add wave -noupdate -label start /testesimon/SIMON1/start
add wave -noupdate -label vermelho /testesimon/SIMON1/vermelho
add wave -noupdate -label azul /testesimon/SIMON1/azul
add wave -noupdate -label verde /testesimon/SIMON1/verde
add wave -noupdate -label amarelo /testesimon/SIMON1/amarelo
add wave -noupdate -divider {Simon Estrutural}
add wave -noupdate -label {Game Over 1} -radix binary -radixshowbase 0 /testesimon/SIMON1/gameover
add wave -noupdate -label amareloLuzE -radix binary -radixshowbase 0 /testesimon/SIMON1/amareloluz
add wave -noupdate -label verdeLuzE -radix binary -radixshowbase 0 /testesimon/SIMON1/verdeluz
add wave -noupdate -label vermelhoLuzE -radix binary -radixshowbase 0 /testesimon/SIMON1/vermelholuz
add wave -noupdate -label azulLuzE /testesimon/SIMON1/azulluz
add wave -noupdate -label {Estado Atual} /testesimon/SIMON1/CONTROL/estadoAtual
add wave -noupdate -divider -height 25 {Simon Comport}
add wave -noupdate -label {Game Over 2} -radix binary -radixshowbase 0 /testesimon/SIMON2/gameover
add wave -noupdate -label amareloLuzC -radix binary -radixshowbase 0 /testesimon/SIMON2/amareloluz
add wave -noupdate -label verdeluzC /testesimon/SIMON2/verdeluz
add wave -noupdate -label vermelhoC -radix binary -radixshowbase 0 /testesimon/SIMON2/vermelholuz
add wave -noupdate -label azulLuz -radix binary -radixshowbase 0 /testesimon/SIMON2/azulluz
add wave -noupdate -label {Current State C} /testesimon/SIMON2/currentState
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 209
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {1308 ns}
