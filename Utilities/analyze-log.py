import numpy as np
import pandas as pd
import csv

get_ipython().magic('matplotlib inline')
import matplotlib
import matplotlib.pyplot as plt
matplotlib.style.use('ggplot')

input_file = '~/Documents/itunes-log.csv'

logs = pd.read_csv(input_file, quotechar = '"', escapechar = "\\", parse_dates = [0])

print("\nMost frequently played media:")
print(pd.value_counts(logs["name"]).head(10))

print("\nMost frequently played artists:")
print(pd.value_counts(logs["artist"]).head(10))

logs["play_hour"] = pd.DatetimeIndex(logs['date']).hour

plt.figure(figsize=(15, 7))
ax = plt.subplot(111)
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.get_xaxis().tick_bottom()
ax.get_yaxis().tick_left()

plt.xticks(range(0, 24), fontsize=14)
plt.yticks(fontsize=14)

plt.xlabel("Hour", fontsize=16)  
plt.ylabel("Frequency", fontsize=16)  

_ = plt.hist(logs['play_hour'], bins=range(0, 25))
plt.savefig('by-hour.png')

