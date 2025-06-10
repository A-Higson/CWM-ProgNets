# !/usr/bin/python3
import numpy as np
import matplotlib.pyplot as plt

# parameters to modify
filename="processed_iperf3_1.txt"
label='bandwidth'
xlabel = 'Time (sec)'
ylabel = 'Bandwidth'
title='Bandwidth of iperf3'
fig_name='iperf3_1.png'
bins=10 #adjust the number of bins to your plot


t = np.loadtxt(filename, delimiter=" ", dtype="float")

plt.plot(t[:,0], t[:,1], label=label)  # Plot some data on the (implicit) axes.
#Comment the line above and uncomment the line below to plot a CDF
#plt.hist(t[:,1], bins, density=True, histtype='step', cumulative=True, label=label)
plt.xlabel(xlabel)
plt.ylabel(ylabel)
plt.title(title)
plt.legend()
plt.savefig(fig_name)
plt.show()
