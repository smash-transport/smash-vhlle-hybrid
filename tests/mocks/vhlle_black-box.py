#!/usr/bin/env python3

import argparse
import os
import sys
import random
import time
import datetime

def print_terminal_start():
    # generated with https://patorjk.com/software/taag/#p=display&f=Graffiti&t=Type%20Something%20
    Terminal_Out = """###########################################################################################################\n
      _________   _____      _____    _________ ___ ___                                               
     /   _____/  /     \    /  _  \  /   _____//   |   \ \n                                             
     \_____  \  /  \ /  \  /  /_\  \ \_____  \/    ~    \ \n                                            
     /        \/    Y    \/    |    \/        \    Y    / \n                                            
    /_______  /\____|__  /\____|__  /_______  /\___|_  / \n                                             
            \/         \/         \/        \/       \/  \n                                             
                                   .__           ___.         .__    .___   \n                          
      ____   ______  _  __         |  |__ ___.__.\_ |_________|__| __| _/          ________________  \n 
     /    \_/ __ \ \/ \/ /  ______ |  |  <   |  | | __ \_  __ \  |/ __ |  ______ _/ __ \_  __ \__  \  \n
    |   |  \  ___/\     /  /_____/ |   Y  \___  | | \_\ \  | \/  / /_/ | /_____/ \  ___/|  | \// __ \_  \n
    |___|  /\___  >\/\_/           |___|  / ____| |___  /__|  |__\____ |          \___  >__|  (____  /  \n
         \/     \/                      \/\/          \/              \/              \/           \/ \n
       __         ___ ___ .____    .____     ___________ __    \n                                       
      / / ___  __/   |   \|    |   |    |    \_   _____/ \ \     \n                                     
     / /  \  \/ /    ~    \    |   |    |     |    __)_   \ \    \n                                     
     \ \   \   /\    Y    /    |___|    |___  |        \  / /    \n                                     
      \_\   \_/  \___|_  /|_______ \_______ \/_______  / /_/     \n                                     
                       \/         \/       \/        \/        \n                                   

      \n###########################################################################################################\n"""

    print(Terminal_Out)
    print("running hydro")
    return

def read_parameters(configFile):
    # list of possible parameters
    # parameter name, string to write, default value (0 where none)
    parameters = {
        "freezeoutOnly": ["freezeoutOnly", 0], 
        "eosType": ["eosType", 0], 
        "eosTypeHadron": ["eosTypeHadron", 0], 
        "nx": ["nx", 0], 
        "ny": ["ny", 0], 
        "nz": ["nz", 0], 
        "icModel": ["icModel", 0], 
        "glauberVar": ["glauberVar", 1], 
        "xmin": ["xmin", 0], 
        "xmax": ["xmax", 0], 
        "ymin": ["ymin", 0], 
        "ymax": ["ymax", 0], 
        "etamin": ["etamin", 0], 
        "etamax": ["etamax", 0],
        "tau0": ["tau0", 0], 
        "tauMax": ["tauMax", 0], 
        "tauGridResize": ["tauGridResize", 4.0],
        "dtau": ["dtau", 0],
        "e_crit": ["e_crit", 0], 
        "zetaSparam": ["zeta/s param", 0],
        "etaSparam": ["etaSparam", 0], 
        "etaS": ["eta/s", 0],
        "al": ["al", 0], 
        "ah": ["ah", 0], 
        "aRho": ["aRho", 0],
        "etaSMin": ["etaSMin", 0],
        "T0": ["T0", 0],
        "eEtaSmin": ["eEtaSmin", 0],
        "zetaS": ["zeta/s" , 0],
        "epsilon0": ["epsilon0", 0],
        "Rg": ["Rgt", 0],
        "Rgz": ["Rgz", 0],
        "smoothingType": ["smoothingType", 0],
        "impactPar": ["impactPar", 0],
        "s0ScaleFactor": ["s0ScaleFactor", 0],
        "VTK_output": ["VTK output", 0],
        "VTK_output_values": ["VTK output values", " "],
        "VTK_cartesian": ["VTK cartesian", 0]
    }
    
    if os.path.isfile(configFile):
        for line in open(configFile, "r"):
            line = line.split()
            for key in parameters:
                if key in line: parameters[key][1] = line[1]
    return parameters

def print_parameters():
    print("vhlle: reading parameters from ", args.params)
    print("vhlle: command line parameters are:")
    print("collision system:")  
    print("ini.state input: ", args.ISinput)
    print("output directory: ", args.outputDir)
    parameters = read_parameters(args.params)
    print("====== parameters ======")
    print("outputDir = ", args.outputDir)
    for key, value in parameters.items():
        print(value[0], " = ", value[1])
    print("======= end parameters =======")
    return

def create_folder(outputDirSpecified):
    # create path if needed
    if outputDirSpecified:
        # fix format
        if args.outputDir[-1] != "/":
            args.outputDir += "/"
        if not os.path.exists(args.outputDir):
            os.makedirs(args.outputDir)
            print("mkdir returns: 0")
    else:
        print("mkdir: missing operand")
    return

def check_command_line():
    # check if there are command# check if there is a config file
    if len(sys.argv) < 2:
        print("no CL params - exiting.")
        sys.exit(1)
    # check if config file exists
    if not args.params == "":
        if not os.path.isfile(args.params) or not config_is_valid: 
            print("cannot open parameters file ", args.params)
            sys.exit(1)
    return

def check_eos():
    # no real check at this point we assume the eos folder exists
    # where hlle_visc executable is
    # to be implemented later, override with True now  
    eosPath = ""
    eosExists = os.path.exists(eosPath)
    eosExists = True
    if eosExists:
        print("EoSaux: table eos/chiraleos.dat read, [emin,emax,nmin,nmax] = 0  146  0  6")
        print("EoSaux: table eos/chiralsmall.dat read, [emin,emax,nmin,nmax] = 0  1.46  0  0.3")
        print("EoSSMASH: table eos/hadgas_eos_SMASH.dat read, [emin,emax,nbmin,nbmax,qmin,qmax] = 0  1  0  0.5 -0.1  0.4")
    else: 
        print("I/O error with eos/chiraleos.dat")
        sys.exit(1)
    return

def exit_without_config(outputDirSpecified):
    if args.params == "":
        print("""EoHadron: table eos/eosHadronLog.dat read, [emin,emax,nmin,nmax] = 0.00336897  74.2066  -44.5239  44.5239  -44.5239  44.5239" 
fluid allocation done 
icModel = 0 not implemented 
IC done 
Init time = 6 [sec]""")
        create_folder(outputDirSpecified)
        variableList = ["tau", "E", "Efull", "Nb", "Sfull", "EtotSurf", "elements", "susp.", "%cut"]
        valueList = ["0", "-0", "-0", "0", "-0", "0", "0", "0", "-nan"]
        print("{: >10} {: >10} {: >10} {: >10} {: >10} {: >10} {: >10} {: >10} {: >10}".format(*variableList))
        print("{: >10} {: >10} {: >10} {: >10} {: >10} {: >10} {: >10} {: >10} {: >10}".format(*valueList))
        sys.exit(1)
    return
       
def read_initial_state():
    messageExample = """particle E = 1442.11  Nbar = 367  Ncharge = 148 Ns = 0 
IC SMASH, center: 0  0  4.36586  1.18914 
hydrodynamic E = 1442.1  Pz = 36.5687  Nbar = 367  Ncharge = 148.001 Ns = 0 
Px = -0.463514  Py = 0.556379 
initial_entropy S_ini = 7880.36 
IC done 
Init time = 9 [sec]"""
    
    print("fluid allocation done")
    if os.path.exists(args.ISinput) and input_is_valid:
        print(messageExample)
    else:
        print("I/O error with",args.ISinput)
        sys.exit(1)

def print_timestep(timestep):
    randomList = []
    for i in range(1, 10):
        number = round(random.random(), 2)
        randomList.append(str(number))
    if timestep > 10 and not crash:
        randomList[8] = "-nan"
    print("{: >10} {: >10} {: >10} {: >10} {: >10} {: >10} {: >10} {: >10} {: >10}".format(*randomList))
    return
        
 
def run_hydro(outputDirSpecified):
    # create freezout hypersurface file
    # only if output directory is specified
    if outputDirSpecified: freezeout = open(args.outputDir+"freezeout.dat", "w")
    variableList = ["tau", "E", "Efull", "Nb", "Sfull", "EtotSurf", "elements", "susp.", "%cut"]
    # run the black box
    print("{: >10} {: >10} {: >10} {: >10} {: >10} {: >10} {: >10} {: >10} {: >10}".format(*variableList))
    if crash:
        sys.exit(1)
    for ts in range(1,13):
        print_timestep(ts)
        time.sleep(0.1)
    if outputDirSpecified:
        freezeout.write("This is a random line written at {}".format(datetime.datetime.now()))
        freezeout.close()
    return


if __name__ == '__main__': 
    parser = argparse.ArgumentParser()
    parser.add_argument("-params", required=False,
                        help="Path to vhlle_config",
                        default="")
    parser.add_argument("-ISinput", required=False,
                        help="Path to initial state file",
                        default="")
    parser.add_argument("-outputDir", required=False,
                        help="Path to the output folder",
                        default="")

    input_is_valid = os.environ.get('BLACK_BOX_FAIL') != "invalid_input"
    config_is_valid = os.environ.get('BLACK_BOX_FAIL') != "invalid_config"
    crash = os.environ.get('BLACK_BOX_FAIL') == "crash"
    args = parser.parse_args()
    outputDirGiven = not args.outputDir == ""
    
    print_terminal_start()
    check_command_line()
    print_parameters()
    exit_without_config(outputDirGiven)
    check_eos()
    read_initial_state()
    create_folder(outputDirGiven)
    run_hydro(outputDirGiven)