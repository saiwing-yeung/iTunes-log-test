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

import seaborn as sns
sns.set()

logs_hXg = logs.groupby(['play_hour', 'genre']).agg({'genre': 'count'})
logs_hXg_long = logs_hXg.groupby(level=0).apply(lambda x: 100*x/float(x.sum()))
genre_by_count = logs['genre'].value_counts().to_frame()
logs_hXg_wide = logs_hXg_long.unstack('genre').fillna(0).reindex(range(24), fill_value=0).transpose()

genre_by_count = logs['genre'].value_counts()#.to_frame()
genre_count_genresort = genre_by_count.ix[np.sort(genre_by_count.index.values)]

logs_hXg_wide_rank = (genre_count_genresort.values.argsort()[::-1]).argsort()
logs_hXg_wide['rank'] = logs_hXg_wide_rank
logs_hXg_wide.sort_values('rank', inplace=True)
logs_hXg_wide.drop(['rank'], axis=1, inplace=True)

mat_plot = logs_hXg_wide.as_matrix()
idx = np.arange(24)

sns.color_palette("hls", 8)

fig = plt.figure(figsize=(15, 7))

ax = plt.subplot(111)
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.get_xaxis().tick_bottom()
ax.get_yaxis().tick_left()

plt.xticks(range(0, 24), fontsize=14)
plt.yticks(fontsize=14)

plt.title('Distribution of genre by hour of day', fontsize=16)
plt.xlabel("Hour of day", fontsize=16)  
plt.ylabel("Percent (%)", fontsize=16)  

color_scheme = sns.color_palette("cubehelix", mat_plot.shape[0])[::-1]
sp = ax.stackplot(idx, mat_plot, edgecolor='white', colors=color_scheme)
ax.margins(0, 0)

num_in_legend = 5
proxy = [ matplotlib.patches.Rectangle((0,0), 0,0, facecolor=pol.get_facecolor()[0]) for pol in sp ]
ax.legend(proxy[:num_in_legend],
          genre_by_count.index[:num_in_legend],
          title="Top %d genres" % num_in_legend,
          bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.)

plt.show()

