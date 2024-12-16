import pandas as pd 
import h5py, sys
import re
import numpy as np 
import matplotlib
#matplotlib.use('Agg') # set the backend before importing pyplot
import matplotlib.pyplot as plt
plt.rcParams['lines.linewidth'] = 0.8

machine = 'TCV'
shots_number = np.loadtxt('shots.txt', dtype=str, ndmin=1) #with ndim i can have even only one shot
base_dir = 'C:\\Users\\cicioni\\Documents\\elm_dynamics\\'

elm_trigger=[]
elm_times=[]

def find_peaks (shot_number):
    elm_trigger.clear()
    parquet_path = base_dir+"TCV_{}_apau_labeled.parquet".format(shot_number)
    df_parquet = pd.read_parquet(parquet_path)
    elm_label = df_parquet["ELM_label"].values
    #elm_label = np.array([0, 0, 1, 1, 1, 0, 1, 1, 0, 0, 1])    
    control_variable = False
    for i in elm_label:
        if i == 1 and not control_variable:
            elm_trigger.append(1)
            elm_times.append()
            control_variable = True
        elif i==0:
            elm_trigger.append(0)
            control_variable = False
        else:
            elm_trigger.append(0)
    return elm_trigger

fig, axs = plt.subplots(2,1)

for shot_number in shots_number:
    shot_name=machine + 'no' + shot_number

    #ELMs
    elms_diag = input("ELMs diagnostic for {}: ".format(shot_name))
    tmp = h5py.File(base_dir+shot_name+'.h5', 'r') 
    sig = tmp['SIG'][elms_diag]['signal'] #
    #print(sig)
    df = pd.DataFrame()   #create an empty dataframe     
    assert isinstance(sig, h5py.Dataset) #this control if sig is an istance of h5py.Dataset
    df[elms_diag] = np.asarray(list(sig)[0]) #
    df['time'] = np.asarray(list(tmp['SIG'][elms_diag]['time'])[0])
    axs[0].plot(df['time'],df[elms_diag],label=shot_name)
    axs[0].set_xlabel('time (s)')
    axs[0].set_ylabel(elms_diag)
    axs[0].legend()
    
    #plotto i pallini degli ELMs
    peaks=[]
    times=[]
    print(len(find_peaks(shot_number)))
    print(len(df[elms_diag]))
    print(len(df['time']))
    for i, elm  in enumerate(find_peaks(shot_number)):
        if elm == 1:
            peaks.append(df[elms_diag][i])
            #print(df[elms_diag][i])
            times.append(df['time'][i])
            #print(df['time'][i])
    axs[0].plot(times, peaks, marker='o')
    #print(times)

    #ELMs analysis
    
    

plt.show()

