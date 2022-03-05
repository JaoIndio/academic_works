# TCL ModelSim compile script
# Pay atention on the compilation order!!!



# Sets the compiler
#set compiler vlog
set compiler vcom


# Creats the work library if it does not exist
if { ![file exist work] } {
    vlib work
}




#########################
### Source files list ###
#########################

# Source files listed in hierarchical order: botton -> top
set sourceFiles {
    ../src/Simon_pkg.vhd
    ../src/FullAdder.vhd
    ../src/RegisterNbits.vhd
    ../src/Adder_nbits.vhd
    ../src/Comparador.vhd
    ../src/DataPath.vhd 
    ../src/ControlPath.vhd
    ../src/Simon.vhd
    memory.vhd
    Simon_tb.vhd
}



set top MIPS_monocycle_tb



###################
### Compilation ###
###################

if { [llength $sourceFiles] > 0 } {
    
    foreach file $sourceFiles {
        if [ catch {$compiler $file} ] {
            puts "\n*** ERROR compiling file $file :( ***" 
            return;
        }
    }
}




################################
### Lists the compiled files ###
################################

if { [llength $sourceFiles] > 0 } {
    
    puts "\n*** Compiled files:"  
    
    foreach file $sourceFiles {
        puts \t$file
    }
}


puts "\n*** Compilation OK ;) ***"

#vsim $top
#set StdArithNoWarnings 1

