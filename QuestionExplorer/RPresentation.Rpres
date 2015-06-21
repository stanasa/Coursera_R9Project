Question Explorer (Coursera Project)
========================================================
author: Serban Tanasa
date: June 21, 2015

Question Explorer: How does it work?
========================================================

This is a small sample app detailing some sample survey questions.

The data is normally extracted via SQL from a database repo, and placed in a 
cache that is renewed hourly. However, for the purposes of this Coursera 
exercise, I've set the cache durations for 10 days and disabled the SQL, since
it is behind my firewall and not accessible from outside. 

Most of the heavy lifting is done in the helpers.R file, while the
server.r and ui.r files simply call the procedures and define the graphical ui.

Left Panel
========================================================

The main filtering area is the left panel:
- At the moment, there's only one company listed
- There are several types of surveys you can group the listing by either ENG (Engagements)
     or LAT (Standard surveys)
- Choose the 'All' option to browse all surveys.

![Data Table](Sidebar.png)


Technical Details 
========================================================

The selector is elegantly defined and filtered by using a switch command:
```
 switch(survey_desc,
    `Latinum - All` = mainQfam,
    `Latinum - ENG` = mainQfam[substr(survey_cd, 1,3) =="ENG",],
    `Latinum - LAT` = mainQfam[substr(survey_cd, 1,3) =="LAT",],  
     mainQfam[survey_cd==survey_desc])  
```
So that you can return all, two subsets, or individual surveys. See the helpers.R
file for additional information. 

The Data Table
===

The data table lists a survey code, a question type, a question text,
additional row information for multichoice questions in grids, and a listing of
the answer options. There is a count of the total number of items that match 
the filters, pagination and an option to change the number of entries shown.

![Data Table](maintable.png)

Data Table Seach Options
===

The data table has the following features to help you browse the data:

- A general search in the top right-hand side, that filters all columns.
- A columnar search option under the column name in each column, to allow the
user to filter by data in individual columns.
