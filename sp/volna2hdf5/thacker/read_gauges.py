#!/usr/bin/env python
import sys
import h5py
import numpy as np
import matplotlib.pyplot as plt 

#By default, open gauges.h5
file = 'gauges.h5'
#But if a filename is passed in the command line, open that
if len(sys.argv)>1:
  file = str(sys.argv[1])
f = h5py.File(file,"r")

#Read the dimensions of the data
#dims[0] is the number of gauges+1 (for timestamps)
#dims[1] is the number of timesteps
dims = f['/dims']

#Read in gauge data
data = f['/gauges']

# Constants for Thacker solution
A = 0.21951
alpha= 1
h0 = 0.1
w = np.sqrt(8 * 9.81*h0)/alpha
t = []
y1 = []
y2 = []
y3 = []

# Read in the datat
for i in range(0,dims[1]):
    t.append(data[i*dims[0]])
    y1.append(data[i*dims[0]+1])
    y2.append(data[i*dims[0]+2])
    y3.append(data[i*dims[0]+3])

t = np.array(t)
y1 = np.array(y1)
y2 = np.array(y2)
y3 = np.array(y3)

# Analytical Solutions
hc= h0*((np.sqrt(1-(A**2))/(1-A*np.cos(w*t)))-1) # Center of the domain (0,0)
h= h0*((np.sqrt(1-(A**2))/(1-A*np.cos(w*t)))-1-((alpha/2)**2)/(alpha**2)*(((1-(A**2))/((1-A*np.cos(w*t))**2))-1)) # Point (0.5, 0)
h_shoreline= h0*((np.sqrt(1-(A)**2)/(1-A*np.cos(w*t)))-1-(((1-(A**2))/((1-A*np.cos(w*t))**2))-1)) # Shoreline Point (1.0, 0)

t = t/3600

plt.figure(1)
plt.plot(t,y1, 'b')
plt.plot(t,hc,'k')


plt.figure(2)
plt.plot(t,y2, 'b')
plt.plot(t,h,'k')


plt.figure(4)
plt.plot(t,y3, 'b')
plt.plot(t,h_shoreline,'k')


f.close()