#'---
#' title: "Helpers File for Voz Syndicated Question Explorer"
#' author: "Serban Tanasa"
#' date: "June 18, 2015"
#' output: pdf_document
#'---

#'This file contains the basic package loading and helper functions for the Voz  
#'Survey Browser shiny app. It will establish a *LINUX-ONLY* odbc connection to
#'Redshift, will draw data from stored file caches refrehed every hour. It will
#'also perform dynamic pulls for a specific question selected by the user and
#'create a different set of dynamic graphics for each question type.
#'


#' Basic cleanup 
# pkgs = names(sessionInfo()$otherPkgs)
# if(!is.null(pkgs)) {
# pkgs = paste('package:', pkgs, sep = "")
# lapply(pkgs, detach, character.only = TRUE, unload = TRUE)}
rm(list=ls())
gc()
#setwd("/home/ruser/VozSyndicatedQuestionExplorer/")

#' Install or load required packages

#list.of.github <- c("htmlwidgets", "DT")
#devtools::install_github('ramnathv/htmlwidgets')
#devtools::install_github('rstudio/DT')
#devtools::install_github("rstudio/shiny")

 list.of.packages <- c("devtools","data.table", "RODBC", "DT")
# new.packages <- list.of.packages[!(list.of.packages %in% 
#                                               installed.packages()[,"Package"])]
# if(length(new.packages)) install.packages(new.packages)
 lapply(list.of.packages, require, character.only=T)

#' Close ODBC connections and set up a new one (disabled for online app version)
# odbcCloseAll()
# source('setUpRedshiftConnection.R')
# myconn <- setUpRedshiftConnection()

#' Renew Company Name data every 60 minutes if running, otherwise read from SSD
if(file.exists("companyName.RData")&file.info("companyName.RData")$size>0 && 
  file.info("surveyName.RData")$mtime > Sys.time() - 60*60*24*10){
 load("companyName.RData")
 } else {
companyNameQuery <- "select distinct a.* from bi.l_voz_company a
inner join (select distinct left(survey_cd,3) as company_cd, survey_cd 
from bi.v_jose_test) b on a.company_cd  = b.company_cd
where company_desc = 'Latinum Network'
order by company_desc"
companyName <-  as.data.table(sqlQuery(myconn,companyNameQuery, 
                                       stringsAsFactors=FALSE))
write.csv(companyName, file="companyName.csv", row.names=FALSE)
save(companyName, file="companyName.RData")
}

#' Renew Survey Name data every 60 minutes if running, otherwise read from SSD
if(file.exists("surveyName.RData")&file.info("surveyName.RData")$size>0 &&
     file.info("surveyName.RData")$mtime > Sys.time() - 60*60*24*10 )
{
 load("surveyName.RData") 
} else {
surveyNameQuery <- " select 
                    company_cd,
                    survey_cd
                    from
                    (select distinct left(survey_cd,3) as company_cd,
                    survey_cd,
                    3 as sortvar 
                    from bi.v_jose_test 
                    where left(survey_cd,3) in ('ENG','LAT')
                    union all
                    (select
                    'LAT' as company_cd,
                    'Latinum - ENG' as survey_cd,
                    1 as sortvar)
                    union all
                    (select
                    'LAT' as company_cd,
                    'Latinum - LAT' as survey_cd,
                    2 as sortvar)
                    union all
                    (select
                    'LAT' as company_cd,
                    'Latinum - All' as survey_cd,
                    0 as sortvar))
                    order by sortvar, survey_cd, company_cd"
surveyName <- as.data.table(sqlQuery(myconn,surveyNameQuery,
                                     stringsAsFactors=FALSE))
save(surveyName, file="surveyName.RData")
}


#' Some debugging and testing code, commented out
# survey_desc <- "ENG_AmericanDream_2013_09"
# question_desc <- "How much do you agree with the following statement: Living in the United States will allow my children to have better opportunities than the ones they would have if they lived in Latin America."
# question_desc <- "Thinking of when you purchased beer in the past 3 months, please indicate what percentage of the time you planned your purchase ahead of time by making a list or taking inventory at home, decided ahead of time with just a mental note, or decided to purchase while in the store. Planned ahead of time—with just a mental note" #Alloc type
# survey_desc <- "CRO_July4thExploration_2014_07"
# question_desc <- "Which ONE actor, actress, or comedian would you be interested in sharing a beer with?"
# question_desc <- "What is the appropriate age for children to be introduced to technology (smartphones, tablets, etc.)?"
# survey_desc <- "ENG_Toys_2014_12" 


getQfam <- function(survey_desc){
  if(file.exists("Qfam.RData")&file.info("surveyName.RData")$size>0 &&
       file.info("Qfam.RData")$mtime > Sys.time() - 60*60*24*10 )
  {
    #load("Qfam.RData") 
    mainQfam <- fread("Qfam.csv")
  } else {
  # print(survey_desc)
  # print(question_desc)   
  # 
  #  (case when 'Latinum - All' = 'Latinum - All' then 1
  #   --when survey_cd = '", survey_desc,"' then 1
  #   else 0 end) <> 0
  #  survey_desc <-  "Latinum - ENG"
    
  mainQuery <- paste0("select distinct 
                      survey_cd
                      ,question_type_desc
                      ,question_desc
                      ,question_row_desc
                      ,answer_desc
                      from bi.v_jose_test 
                      where 
                      left(survey_cd,3) in ('ENG', 'LAT')
                      order by survey_cd, question_family, answer_id asc")
  mainQfam <- as.data.table(sqlQuery(myconn, mainQuery, 
                                         stringsAsFactors=FALSE)) 
  write.csv(mainQfam, "Qfam.csv", row.names=FALSE)
  #save(mainQfam, file="Qfam.RData")
  }
 
  switch(survey_desc,
    `Latinum - All` = mainQfam,
    `Latinum - ENG` = mainQfam[substr(survey_cd, 1,3) =="ENG",],
    `Latinum - LAT` = mainQfam[substr(survey_cd, 1,3) =="LAT",],  
     mainQfam[survey_cd==survey_desc])  
}