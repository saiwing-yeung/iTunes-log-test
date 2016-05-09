# log-tunes

A Menubar application (OS X) that records media that you have played on iTunes.

The log file is a CSV file with these fields:

* date - in the format of yyyy-MM-dd HH:mm:ss
* name - media name
* artist
* album
* tracknum
* genre
* category - Music, iTunes U, etc. This is not a field directly supplied by iTunes. The program determines this simply based on the location of your media file. More specifically, it grabs the directory in the path of the media that comes after ~/Music/iTunes/iTunes Music/. For many media this is empty.
* length 
* rating - we use the value directly given by iTunes. The rating here equals the number of stars in iTunes times 20, i.e., rating of 50 = 2.5 stars, rating of 60 = 3 stars, etc.
* count - Play Count

All fields are quoted in double quotes. Double quotes that exist inside the fields are escaped with a back-slash.

Default location of the log is ~/Documents/iTunes-log.csv. If you select an existing file in the Preferences, the new entries will be appended to the end of the file.

# Utilities

Inside the Utilities folder there is a [Jupyter Notebook](http://jupyter.org) analyze-log.ipynb. It takes the log produced by log-tunes and analyze the data.

Currently it only does very basic analyses:

* Find the 10 artists that are most frequently played
* Find the 10 media files that are most frequently played
* Plot the number of plays by hour (below)
* Plot the proportion of genre played by hour (below; note that the two plots are based on different data sets)

![Frequency by hour](https://raw.githubusercontent.com/saiwing-yeung/log-tunes/master/Utilities/count-by-hour.png)

![Genre by hour](https://raw.githubusercontent.com/saiwing-yeung/log-tunes/master/Utilities/genre-by-hour.png)

More features will be added later.


# Download

https://github.com/saiwing-yeung/log-tunes/releases/latest


# Known issues

If you 1) pause and then un-pause, or 2) modify any attribute of the media (e.g., song name, rating, etc.) then iTunes will send us a new Play notification.

We use the following algorithm to prevent from logging these spurious notifications: We check the PersistentID of the media (a unique ID that iTunes gives every media file) and the Play Count. If the PersistentID is different from the previous one then we will log it. If PersistentID is the same then we will log it only if the play count has been incremented.

This is only a heuristic though and is not 100% correct.


# ToDo

* Include the Python script for processing the log.


# Release history

v0.7 (2016-04-06)

* initial release


# License

log-tunes is available under the GNU GPL license. See the [LICENSE file](https://github.com/saiwing-yeung/log-tunes/blob/master/LICENSE) for more information.

