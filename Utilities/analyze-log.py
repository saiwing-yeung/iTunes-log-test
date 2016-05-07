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

plt.hist(logs['play_hour'], bins=range(0, 25))
plt.savefig('count-by-hour.png')

import seaborn as sns
sns.set()
sns.color_palette("hls", 8)

# construct a DataFrame that represent the percentage of plays of each genre by hour
logs_hXg = logs.groupby(['play_hour', 'genre']).agg({'genre': 'count'})
logs_hXg_long = logs_hXg.groupby(level=0).apply(lambda x: 100*x/float(x.sum()))

# turn this DataFrame into a wide format
logs_hXg_wide = logs_hXg_long.unstack('genre').fillna(0).reindex(range(24), fill_value=0).transpose()

# sort logs_hXg_wide by the total number of plays per genre
genre_by_count_sorted = logs['genre'].value_counts()
genre_count = genre_by_count_sorted.ix[np.sort(genre_by_count_sorted.index.values)]

# sort logs_hXg_wide so that higher ranked genres appear on top, in the same order as the legend
logs_hXg_wide['rank'] = (genre_count.values.argsort()[::-1]).argsort()
logs_hXg_wide.sort_values('rank', inplace=True, ascending=False)
logs_hXg_wide.drop(['rank'], axis=1, inplace=True)

# create the data to be used for plotting
mat_plot = logs_hXg_wide.as_matrix()
idx = np.arange(24)

# prepare the plot
fig = plt.figure(figsize=(15, 7))
ax = plt.subplot(111)
ax.margins(0, 0)

plt.xticks(range(0, 24), fontsize=14)
plt.yticks(fontsize=14)

plt.title('Distribution of genre by hour of day', fontsize=16)
plt.xlabel("Hour of day", fontsize=16)  
plt.ylabel("Percent (%)", fontsize=16)  

# set up color scheme and plot the figure
color_scheme = sns.color_palette("cubehelix", mat_plot.shape[0])
sp = ax.stackplot(idx, mat_plot, edgecolor='white', colors=color_scheme)

# legend
num_in_legend = 5 # number of genres to show in the legend
proxy = list(reversed( [ matplotlib.patches.Rectangle((0, 0), 0, 0, facecolor=pol.get_facecolor()[0])
                        for pol in sp ] ))
ax.legend(proxy[:num_in_legend], genre_by_count_sorted.index[:num_in_legend],
          title="Top %d genres" % num_in_legend, bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.)

# need to specify bbox otherwise legend would be clipped in the saved figure
plt.savefig('genre-by-hour.png', bbox_inches='tight')
plt.show()

