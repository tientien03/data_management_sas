/* dataset import code */
%web_drop_table(WORK.students);
FILENAME REFFILE '/home/u64177647/sasuser.v94/Assignment/StudentPerformanceFactors.csv';
PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.students;
	GETNAMES=YES;
RUN;
/* check original dataset content */
PROC CONTENTS DATA=WORK.students; 
RUN;
%web_open_table(WORK.students);

/* IDA */
proc contents data=work.students; 
run;
 
proc print data=work.students; 
run; 

/*mean, median, standard deviation, min, max, range, variance, perventiles*/ 
proc means data=work.students  
mean median std min max range var p25 p50 p75; 
run; 

/*Frequency Table*/ 
proc freq data=work.Students; 
tables _all_; 
run; 

/*Missing Value*/ 
proc means data=work.students n nmiss; 
title"Missing Value for Students Performance Factors"; 
run; 

/*correlation*/ 
proc corr data=work.students; 
var Hours_Studied Attendance Sleep_Hours Previous_Scores  
        Tutoring_Sessions Physical_Activity Exam_Score; 
title "Correlation Analysis of Numerical Attributes"; 
run;

/* DATA CLEANING */ 
/* Missing Value */ 
/* Detect */ 
PROC MEANS DATA=work.students N NMISS; 
RUN; 
PROC FREQ DATA=Work.students; 
	TABLES 	Access_to_Resources Distance_from_Home Extracurricular_Activities 
			Family_Income Gender Motivation_Level Internet_Access 
			Learning_Disabilities 
			Parental_Education_Level 
			Parental_Involvement 
			Peer_Influence 
			School_Type 
			Teacher_Quality / missing; 
RUN; 

/* Replace */ 
DATA Work.students_clean; 
	set Work.students; 
	if Distance_from_Home = '' then Distance_from_Home = 'Unknw'; 
	if Parental_Education_Level = '' then Parental_Education_Level = 'Unknw'; 
	if Teacher_Quality = '' then Teacher_Quality = 'Unknw'; 
RUN;
 
PROC SQL noprint; 
	select mean(Sleep_Hours), mean(Tutoring_Sessions), mean(Exam_Score) 
	into :mean_Sleep_Hours, :mean_Tutoring_Sessions, :mean_Exam_Score 
	from Work.students; 
QUIT;
 
DATA Work.students_clean; 
	set Work.students_clean; 
	if Sleep_Hours = . then Sleep_Hours = &mean_Sleep_Hours; 
	if Tutoring_Sessions = . then Tutoring_Sessions = &mean_Tutoring_Sessions; 
	if Exam_Score = . then Exam_Score = &mean_Exam_Score; 
RUN; 

/* Format Correction */ 
DATA Work.students_clean; 
	set Work.students_clean; 
	if Teacher_Quality in ('High_', 'high', 'HIGH') then Teacher_Quality = 'High'; 
	if Teacher_Quality in ('L_ow', 'Loow', 'low', 'LOW') then Teacher_Quality = 'Low'; 
	if Teacher_Quality in ('Medium', 'medium', 'MEDIUM') then Teacher_Quality = 'Medium'; 
RUN; 

/* Duplicate */ 
/* Detect Duplicate */ 
PROC SORT DATA=Work.students_clean out=cleaned_data nodupkey dupout=duplicates; 
    by _all_; 
RUN; 
 
/* Display Duplicates */ 
PROC PRINT DATA=duplicates; 
    title "List of Duplicate Rows Detected"; 
RUN; 
 
/* Remove Duplicates */ 
DATA Work.students_clean; 
    set cleaned_data; 
RUN; 
 
/* Verify */ 
PROC CONTENTS DATA=Work.students_clean; 
    title "Final Dataset After Removing Duplicates"; 
RUN; 
 
 
/* Outlier */ 
/* Detect Outliers */ 
DATA outliers; 
    set Work.students_clean; 
    if Exam_Score > 100 or Exam_Score < 0; 
RUN; 
 
/* Display */ 
PROC PRINT DATA=outliers; 
    title "List of Outliers Detected in Exam_Score"; 
RUN; 
 
 
/* DATA TRANSFORMATION */ 
/* encode */ 
DATA Work.students_clean; 
    set Work.students_clean; 
 
    if Access_to_Resources = 'Low' then Access_to_Resources_Label = 1; 
    else if Access_to_Resources = 'Medium' then Access_to_Resources_Label = 2; 
    else if Access_to_Resources = 'High' then Access_to_Resources_Label = 3; 
 
    if Extracurricular_Activities = 'No' then Extracurricular_Activities_Label = 0; 
    else if Extracurricular_Activities = 'Yes' then Extracurricular_Activities_Label = 1; 
 
    if Family_Income = 'Low' then Family_Income_Label = 1; 
    else if Family_Income = 'Medium' then Family_Income_Label = 2; 
    else if Family_Income = 'High' then Family_Income_Label = 3; 
 
    if Motivation_Level = 'Low' then Motivation_Level_Label = 1; 
    else if Motivation_Level = 'Medium' then Motivation_Level_Label = 2; 
    else if Motivation_Level = 'High' then Motivation_Level_Label = 3; 
 
    if Parental_Education_Level = 'Unknw' then Parental_Education_Level_Label = 0; 
    else if Parental_Education_Level = 'High School' then Parental_Education_Level_Label = 1; 
    else if Parental_Education_Level = 'College' then Parental_Education_Level_Label = 2; 
    else if Parental_Education_Level = 'Postgraduate' then Parental_Education_Level_Label = 3; 
 
    if Parental_Involvement = 'Low' then Parental_Involvement_Label = 1; 
    else if Parental_Involvement = 'Medium' then Parental_Involvement_Label = 2; 
 	else if Parental_Involvement = 'High' then Parental_Involvement_Label = 3; 
	
	if Peer_Influence = 'Negative' then Peer_Influence_Label = 1; 
	else if Peer_Influence = 'Neutral' then Peer_Influence_Label = 2; 
	else if Peer_Influence = 'Positive' then Peer_Influence_Label = 3; 
	
	if Teacher_Quality = 'Unknw' then Teacher_Quality_Label = 0; 
	else if Teacher_Quality = 'Low' then Teacher_Quality_Label = 1; 
	else if Teacher_Quality = 'Medium' then Teacher_Quality_Label = 2; 
	else if Teacher_Quality = 'High' then Teacher_Quality_Label = 3; 

	if Distance_from_Home = 'Unknw' then Distance_from_Home_Label = 0; 
	else if Distance_from_Home = 'Near' then Distance_from_Home_Label = 1; 
	else if Distance_from_Home = 'Moderate' then Distance_from_Home_Label = 2; 
	else if Distance_from_Home = 'Far' then Distance_from_Home_Label = 3; 
RUN;

/* Arithmetic Transformation */
data work.students_clean;
	set work.students_clean;
	Improvement = Exam_Score - Previous_Scores;
run;
/* Bining (Discretization) */
data work.students_clean;
	set work.students_clean;
	if Exam_Score >= 80 then Grade = "A";
   	else if Exam_Score >= 70 then Grade = "B";
   	else if Exam_Score >= 60 then Grade = "C";
   	else Grade = "D";
run;

/* Categoriacal Derivation */
data work.students_clean;
	set work.students_clean;
	if Exam_Score > Previous_Scores then ImproveStatus = "Improved";
   	else if Exam_Score < Previous_Scores then ImproveStatus = "Declined";
   	else ImproveStatus = "Remained";
run;

/* Print sample output (after transformation) */
proc print data=work.students_clean (obs=10);
	var  Previous_Scores Exam_Score Improvement ImproveStatus;
run;

/* normalization */
proc stdize data=work.students_clean out=work.students_clean_norm method=range;
	var 
	Access_to_Resources_Label Attendance Distance_from_Home_Label 
	Extracurricular_Activities_Label Family_Income_Label Hours_Studied 
	Motivation_Level_Label exam_score Parental_Education_Level_Label 
	Parental_Involvement_Label Peer_Influence_Label Physical_Activity Previous_Scores 
	Sleep_Hours Teacher_Quality_Label Tutoring_Sessions Improvement;
run;

/* print output after normalization */
proc print data=work.students_clean_norm (obs=10);
   var Access_to_Resources_Label exam_score Motivation_Level_Label 
       Attendance Hours_Studied Distance_from_Home_Label Improvement;
run;

/* DATA REDUCTION */
/* correlation analysis */
proc corr data=work.students_clean_norm;
	var 
	Access_to_Resources_Label Attendance Distance_from_Home_Label 
	Extracurricular_Activities_Label Family_Income_Label Hours_Studied 
	Motivation_Level_Label Parental_Education_Level_Label Parental_Involvement_Label 
	Peer_Influence_Label Physical_Activity Previous_Scores 
	Sleep_Hours Teacher_Quality_Label Tutoring_Sessions Improvement;
	with exam_score;
run;

/* data reduction based on feature selection */
data work.students_reduced;
    set work.students_clean;
    drop 
    	/* drop label */
        Distance_from_Home_Label Extracurricular_Activities_Label Family_Income_Label Teacher_Quality_Label Motivation_Level_Label
        /* drop numerical */
        Physical_Activity Sleep_Hours
        /* drop raw versions*/
        Distance_from_Home Extracurricular_Activities Family_Income Teacher_Quality Motivation_Level
		/*drop low variance */
		Internet_Access Learning_Disabilities;
run;

/* check students_reduced content based on variable sequences*/
proc contents data=work.students_reduced varnum;
run;

/* Sample output of student_reduced*/
proc print data=work.students_reduced (obs=10);
run;

/* pca analysis */
proc princomp data=students_clean_norm out=work.students_pca;
    var Attendance Hours_Studied Tutoring_Sessions;
run;

/* correlation pca and exam score */
proc corr data=work.students_pca;
    var Prin1 Prin2 Prin3;
    with Exam_Score;
run;

/* clustering */
proc fastclus data=work.students_pca maxclusters=3 out=work.students_pca;
    var Prin2;
run;

/* summarize key academic performance metrics for each cluster*/
proc means data=work.students_pca;
	class Cluster;
	var Prin2 Hours_Studied Attendance Tutoring_Sessions Exam_Score;
run;

/* Create a new variable to label student engagement level based on clustering results */
data work.students_pca;
    set work.students_pca;
    length Engagement_Label $20;
    if Cluster = 1 then Engagement_Label = "Low Engage";
    else if Cluster = 2 then Engagement_Label = "Moderate Engage";
    else if Cluster = 3 then Engagement_Label = "High Engage";
run;

/* check each labels  */
proc freq data=work.students_pca;
	tables Engagement_Label;
run;


/* add student id for tracking */
data work.students_pca;
    set work.students_pca;
    Row_ID = _N_;
run;

data work.students_reduced;
    set work.students_reduced;
    Row_ID = _N_;
run;

/* merge dataset */
data work.students_merge;
    merge work.students_reduced
          work.students_pca(keep=Row_ID Cluster Engagement_Label Prin2);
    by Row_ID;
run;

/* drop variable make dataset cleared and easier for understanding */
data work.students_final;
    set work.students_merge;
    /* Rename for clarity */
    Student_ID = Row_ID;
    Engage_PC2 = Prin2;
    drop 	Attendance Hours_Studied Tutoring_Sessions 
    		Row_ID Access_to_Resources_Label Parental_Education_Level_Label 
    		Parental_Involvement_Label Peer_Influence_Label Prin2 Cluster;
run;

proc contents data=work.students_final;
run;

/* reorder dataset column */
data work.students_final;
    retain 	Student_ID Gender 
    		School_Type Parental_Involvement 
    		Parental_Education_Level Peer_Influence 
    		Access_to_Resources Engage_PC2 CLUSTER Engagement_Label 
        	Previous_Scores Exam_Score Improvement ImproveStatus Grade ;
    set work.students_final;
run;

/* Sample output of student_final*/
proc print data=work.students_final (obs=10) noobs;
run;

/* check students_final content based on variable sequences*/
proc contents data=work.students_final varnum;
run;

/* EDA (DESCRIPTIVE STATISTIC) */
/* 1:Mean of Overall Exam Performance Comparison and Score Improvement  */
proc means data=work.students_final mean std;
    var Previous_Scores Exam_Score;
    title "Compare Means: Previous Exam Score vs Current Exam Score";
run;

proc means data=work.students_final mean ;
    var  Improvement;
    title "Improvement Score Means";
run;

/* 2: Mean and Standard Deviation of Exam Score by Access to Resources */
proc means data=work.students_final mean std;
   class Access_to_Resources;
   var Exam_Score;
   title "Mean and Standard Deviation of Exam Score by Access to Resources";
run;

/* 3: Percentages of Distribution of Access to Resources by School Type*/
proc freq data=work.students_final;
    tables School_Type*Access_to_Resources /nocol;
    title "Percentage Distribution of Access to Resources by School Type";
run;

/* 4:Frequency of Engagement Label Across Grade */
proc freq data=students_final;
   tables Grade * Engagement_Label / norow nocol nopercent;
   title "Frequency of Engagement Labels Across Grades";
run;

/* 5:Correlation between Engagement Score with Exam Score */
proc corr data=work.students_final;
   var Engage_PC2 Exam_Score;
   title "Correlation Between Engagement Score and Exam Score";
run;

/* 6 :Range of Improvement Score based on Grade Distribution*/
title "Range of Improvement Scores by Grade";
proc sql;
   select 
      Grade,
      min(Improvement) as Min_Improve,
      max(Improvement) as Max_Improve,
      calculated Max_Improve - calculated Min_Improve as Range_Improve
   from work.students_final
   group by Grade;
quit;
title;

/* 7: Median Exam Score by Parental Involvement */
proc means data=work.students_final median;
   class Parental_Involvement;
   var Exam_Score;
   title "Median Exam Score by Parental Involvement";
run;

/* 8:IQR to Detect Inequality in Engagement */
proc means data=work.students_final q1 q3;
   class Engagement_Label;
   var Engage_PC2;
   title "IQR of Engagement Scores by Engagement Label";
run;

/* EDA (GRAPHICAL) */
/* Continuous Data */
/* 1: Histograms (Numerical Distribution-Distriution of Score*/
proc sgplot data=work.students_final;
    histogram Engage_PC2 / fillattrs=(color=purple) transparency=0.4 binwidth=0.3;
    density Engage_PC2 / type=kernel lineattrs=(color=red thickness=2 pattern=solid);
    density Engage_PC2 / type=normal lineattrs=(color=blue thickness=2 pattern=dash);
    xaxis label="Engagement Score (PC2)" grid;
    yaxis label="Percentage (%)" grid;
    title "Distribution of Engagement Scores with Normal and Kernel Density Curves";
    footnote "Note: Purple bars represent actual data. Blue line = normal curve, Red line = smoothed kernel density.";
run;

/* 2: Bar Charts  */
PROC SGPLOT DATA = work.students_final;
	vbar Access_to_Resources / datalabel fillattrs=(color=blue); 
	yaxis grid label="Frequency"; 
    xaxis label="Parent's Education Level";
	title "Bar Chart of Access to Resource Distribution";
RUN;

/* 3: Scatter Plot*/
proc sgplot data=work.students_final;
    reg x=Engage_PC2 y=Exam_Score / lineattrs=(color=purple  thickness=3);
    scatter x=Engage_PC2 y=Exam_Score / group=engagement_Label transparency=0.3;
    xaxis label="Engagement (PC2)";
    yaxis label="Exam Score";
    title "Scatter Plot of Engagement vs Exam Score";
run;

/*Box & Whisker Plot*/
/* 4: The outlier is top perform student lower 59 & higher 75 */
proc sgplot data=work.students_final;
  vbox Exam_Score / category=Access_to_Resources fillattrs=(color=lightyellow) ; 
  yaxis label="Previous Score" grid values=(50 to 100 by 10);
  xaxis label="Access to Resources";
  title "Box Plot of Exam Score by Access to Resources";
run;

/*5: Clustered Bar Charts*/
proc sgplot data=work.students_final;
  vbar Parental_Involvement / response=Exam_Score group=Engagement_Label stat=mean groupdisplay=cluster ;
  yaxis label="Average Exam Score" grid;
  xaxis label="Parental Involment";
  keylegend / title="Engagement Level";
  title "Clustered Bar Chart: Exam Score by Parental Involment and Engagement Label";
run;

/*6: Bar Charts with Error Bars*/
proc sgplot data=work.students_final;
  vbar ImproveStatus / response=Improvement stat=mean limitstat=stddev limits=both datalabel fillattrs=(color=lightblue);
  yaxis label="Improvement" grid;
  xaxis label="Improve Status";
  title "Bar Chart with Error Bars: Improvement by Improve Status";
run;

/*7: Dot Plot*/
proc sgplot data=work.students_final;
  scatter x=Engagement_Label y=Engage_PC2 / jitter transparency=0.3;
  xaxis label="Engagement Label";
  yaxis label="Engagement Score (PC2)" grid;
  title "Dot Plot: Engagement Score by Engagement Label";
run;