-- LOADING DATA INTO PIG FROM THE RECORDS DIRECTORY IN HDFS

stackdata = LOAD 'hdfs:///Records/*.csv' USING org.apache.pig.piggybank.storage.CSVExcelStorage(',','YES_MULTILINE','NOCHANGE') AS (Id:int, PostTypeId:int, AcceptedAnswerId:int,
ParentId:int, CreationDate:datetime, DeletionDate:datetime, 
Score:int, ViewCount:int, Body:chararray, OwnerUserId:int, OwnerDisplayName:chararray, LastEditorUserId:int, LastEditorDisplayName:chararray, LastEditDate:datetime, LastActivityDate:datetime, Title:chararray, Tags:chararray, 
AnswerCount:int, CommentCount:int, FavoriteCount:int, 
ClosedDate:datetime, CommunityOwnedDate:datetime, 
ContentLicense:chararray);

-- Checking and Removing elements with NULL Id and OwnerUserId

filter_1 = FILTER stackdata BY (Id is not NULL);
filter_2 = FILTER filter_1 BY (OwnerUserId is not NULL);

-- Selecting a small selection of columns to help quick the execution

imp_stackdata = FOREACH filter_2 GENERATE Id,Score,OwnerUserId,ViewCount,Body;

-- Removing the characters which are not required, i.e. - Tags and Line Breaks

filtered_stackdata = FOREACH imp_stackdata GENERATE Id,Score,OwnerUserId,ViewCount,REPLACE(Body, '<.*?.>', '') AS Body;

final_stackdata = FOREACH filtered_stackdata GENERATE Id,Score,OwnerUserId,ViewCount,REPLACE(Body, '\n', ' ') AS Body;

-- Storing the final cleaned data back into Hadoop
-- Data is stored in a directory named fin

STORE final_stackdata INTO 'hdfs:///fin' USING org.apache.pig.piggybank.storage.CSVExcelStorage('|', 'YES_MULTILINE', 'NOCHANGE');

