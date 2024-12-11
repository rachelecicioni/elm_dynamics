import pandas as pd 
import h5py, sys
import re
import numpy as np 
import matplotlib
#matplotlib.use('Agg') # set the backend before importing pyplot
import matplotlib.pyplot as plt
plt.rcParams['lines.linewidth'] = 0.8

def find_peaks (shot, signal_values, signal_times):
    peaks=[]
    count=6
    threshold=4*np.mean(signal_values)
    print("mean={}".format(np.mean(signal_values)))
    for index in range(1, len(signal_values)-1):
        if (signal_values[index] >= threshold and signal_values[index - 1] < signal_values[index] > signal_values[index + 1]):
            peaks.append([signal_times[index], count])
            #count=count+1
    return np.array(peaks)

'''
def frequency_elms (shot, signal):
    frequency=0
    return frequency
'''

machine = 'TCV'
shots_number = np.loadtxt('shots.txt', dtype=str)
shots_names = machine + 'no' + shots_number
base_dir = 'C:\\Users\\cicioni\\Documents\\elm_dynamics\\'

fig, axs = plt.subplots(2,1)

for shot in shots_names:
    #ELMs
    elms_diag = input("ELMs diagnostic for {}: ".format(shot))
    shot_number = int(re.findall(r'\d+', shot)[0]) #[0] to access to the first element in the list re.findall
    tmp = h5py.File(base_dir+shot+'.h5', 'r') 
    sig = tmp['SIG'][elms_diag]['signal'] #
    print(sig)
    df = pd.DataFrame()   #create an empty dataframe     
    assert isinstance(sig, h5py.Dataset) #this control if sig is an istance of h5py.Dataset
    df[elms_diag] = np.asarray(list(sig)[0]) #
    df['time'] = np.asarray(list(tmp['SIG'][elms_diag]['time'])[0])
    axs[0].plot(df['time'],df[elms_diag],label=shot)
    axs[0].set_xlabel('time (s)')
    axs[0].set_ylabel(elms_diag)
    axs[0].legend()

    #analisi ELMs
    peaks=find_peaks(shot, df[elms_diag], df['time'])
    peaks_times=peaks[:,0]
    peaks_counts=peaks[:,1]
    axs[0].plot(peaks_times, peaks_counts, marker='o')

plt.show()

