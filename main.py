import pandas as pd 
import h5py, sys
import re
import numpy as np 
import matplotlib
#matplotlib.use('Agg') # set the backend before importing pyplot
import matplotlib.pyplot as plt

base_dir = '/home/cicioni/'
file_name = 'TCVno64770.h5'
shot = int(re.findall(r'\d+', file_name)[0])  
feature = 'Halpha13'

tmp = h5py.File(base_dir+file_name, 'r') 
sig = tmp['SIG'][feature]['signal'] #sig  un dataset
df = pd.DataFrame()   #crea un dataframe vuoto     
assert isinstance(sig, h5py.Dataset) #this control if sig is an istance of h5py.Dataset
df[feature] = np.asarray(list(sig)[0]) #crea (se non esiste) la colonna feature. asarray converte quello tra parentesi in un array numpy. 
df['time'] = np.asarray(list(tmp['SIG'][feature]['time'])[0])
df['shot'] = np.repeat([int(shot)],len(df['time']))
df['shot'] = df['shot'].astype(int)

plt.plot(df['time'],df[feature],label=feature,color='blue')
plt.xlabel('time (s)')
plt.ylabel(feature)
plt.legend()
#plt.savefig('H5.png')
plt.show()
print('ciao')