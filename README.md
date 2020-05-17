# Projet-Oz-groupe-BI

**Goal**

This project's main goal is to create an automic entry depending on 1 or 2 words that the user writes by assessing tweets.


**Authors**

*LINFO1104-BI group:*

`Jadoul Nicolas`

`Nimbona Davy`


**Compilation**

Usable commands:

* ``make run`` : compile the program
* ``make clean``
* ``make all``


**Structure**

-> You can find information of the functions of the program in these files:

* ``main.oz``: synchronization of the threads and launches the program with the GUI interface
* ``Reader.oz``: read the tweets
* ``Parse.oz``: parse the tweets
* ``Dict.oz``: create the dictionaries containing the words and their prediction

<-

* ``Makefile``: contains the command to run the program
* ``tweets``: folder containing the tweets to assess
