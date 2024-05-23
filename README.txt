%%%---------------------------------------------------------------------%%%
%
% Created by Hil Steketee for the course ME41125
% Matlab version R2023b
% Made in 2024
%
%%%---------------------------------------------------------------------%%%

Set-up:
	
	This code uses the data available from the supplementary materials from:
K. L. Poggensee and S. H. Collins, “How adaptation, training, and
customization contribute to benefits from exoskeleton assistance,” Sci
Robot, vol. 6, no. 58, p. eabf1078, 2021.

at:
https://doi.org/10.1126/scirobotics.abf1078

To use the code the 6 zip files for validation days should be downloaded per participant, and placed in to folders following the name convention
"Participant_X", with X being the corresponding participant

These folders should be in the same directory as the Exoskeleton_project.m file
	
Output:
	A single boxplot showing the distribution and significant difference between the three walking conditions: Normal walking, Zero Torque exoskeleton and General assistance Exoskeleton


Important variables:
	Data(j,i): contains the [i]th file of the [j]th day for a participant
	NW_ZT_GA: Step width variance for every time a condition is walked amoung all participants and days