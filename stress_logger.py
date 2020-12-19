import sys
import os
import serial
import serial.tools.list_ports as port_list
from datetime import datetime


# copies newest 20 datapoints into csv used to plot data in real time
# (python doesn't allow opening files without locking)
def copy_csv(csv_string, limit):
    tempFile = open(csv_string, "r+")
    livePlotting = open(r'liveplotting.csv', "a")
    readList = []
    for z in range(limit - 20, limit):
        readList.append(z)
    for position, dataPoint in enumerate(tempFile):
        if position in readList:
            livePlotting.write(dataPoint)
    tempFile.close()
    livePlotting.close()
###


port_name = ""  # serial port path
verbose = False  # toggles printing output during acquisition

# command line arguments handling
for arg in sys.argv:
    if arg == "--list":
        print("[I] List of available ports:")
        for p in port_list.comports():
            print(p)
        exit(0)
    elif arg.startswith("--port="):
        port_name = arg.replace("--port=", "")
    elif arg == "--verbose":
        verbose = True
    elif arg == "--help":
        print("[I] Commands:")
        print(" --list            : list available devices")
        print(" --port=<portname> : specify device name")
        print(" --verbose         : prints output to screen")
        exit(0)
###

# creates and opens the output file path inside stress_data folder,
# files' names are chronologically ordered
absolutePath = os.path.abspath("stress_data")
fn = absolutePath + "\\" + datetime.now().strftime("%m%d%Y_%H%M%S") + "_tonic_skin_response.csv"
tsr_file = open(fn, "w+")
tsr_file.close()
print("[I] Output file:")
print(fn)
tsr_file = open(fn, "a")
print()
###

print("[I] Connecting to logging device:")
print(port_name)
print()


# creates a file for liveplotting (needed to bypass windows file locking)
livePlottingFile = open(r'liveplotting.csv', 'w+')
livePlottingFile.close()
###

# connects to the serial port and logs data to output file until the device is disconnected,
# every 20 acquisitions the file is copied for live plotting (needed to bypass windows file locking)
counter = 0
with serial.serial_for_url(port_name, timeout=3) as s:
    try:
        print("[?] Starting acquisition...")
        print()
        while s.isOpen():
            counter += 1
            line = s.readline().decode()
            tsr_file.write(line)
            if counter % 20 == 0:
                tsr_file.close()
                copy_csv(fn, counter)
                tsr_file = open(fn, "a")
            if verbose:
                print(line)
    except:
        os.remove(r'liveplotting.csv')
        print("[X] Logging device was disconnected!")
        print()
###

print("[V] Acquisition ended!")
print()
tsr_file.close()
