%% Setup
%%%---------------------------------------------------------------------%%%
%
% Created by Hil Steketee for the course ME41125
% Matlab version R2023b
% Made in 2024
%
%%%---------------------------------------------------------------------%%%

close all;
clear all;
clc;

%Creation of loop variables
GA_SWv = [];
NW_SWv = [];
ZT_SWv = [];

%% Full data extraction and analysis loop

% This loop goes over each participant in the static training group
for k=1:1:5
    %for each participant a new folder name is created
    participant_dir = strcat('Participant_',int2str(k),'\');
    %These variables are cleared as they are filled per participant
    clear Data;
    clear SW_var;

    %This loop goes over each day of a single participant
    for j=1:1:5
        %For the first participant the 6th day does not exist, and is
        %skipped
        if k == 1 && j==5
            continue
        end
        %Created the file path for the current day and participant
        % j+1 as the first day is was a pre test and is not taken into
        % account for the analysis

        folder_dir = strcat('validation_Day',int2str(j+1),'\Day',int2str(j+1),'\*.mat');
        current_path = strcat(pwd,'\',participant_dir,folder_dir);
        files = dir(current_path);
        
        %This loop goes over the files within a day of one participant
        for i=1:length(files)
            %The Quiet Standing files are not used in analyis and can thus
            %be skipped
            if strcmp(files(i).name, 'QS.mat')
                continue
            end
            
            filedir = strcat(files(i).folder,"\",files(i).name);
            %Data contains all data from the mat files for each day of a
            %single participant (j for day, i for mat files)
            Data(j,i) = load(filedir);
        
            %% Detecting heel strike peaks in Fz
            %For each foot the vertical reaction force is searched for
            %peaks higher than 500N, and a peak distance of 100.
            %This finds 2 peaks per step, heel strike and toe off, with the
            %first one being heel strike.

            %For the right foot
            [pks,locs] = findpeaks(Data(j,i).RFz,"MinPeakHeight",500,"MinPeakDistance",100);
            pks_RFz = pks(1:2:end);
            locs_RFz = locs(1:2:end);
            %For the left foot
            [pks,locs] = findpeaks(Data(j,i).LFz,"MinPeakHeight",500,"MinPeakDistance",100);
            pks_LFz = pks(1:2:end);
            locs_LFz = locs(1:2:end);
        
            %% Center of pressure calculation
            
            %The COP is calcutated form the corresponding variables in 
            % the mat files of Data, at the location of the peaks.
            x_cop_r = -Data(j,i).RMy(locs_RFz)./Data(j,i).RFz(locs_RFz);
            x_cop_l = -Data(j,i).LMy(locs_LFz)./Data(j,i).LFz(locs_LFz);
            
            y_cop_r = -Data(j,i).RMx(locs_RFz)./Data(j,i).RFz(locs_RFz);
            y_cop_l = -Data(j,i).LMx(locs_LFz)./Data(j,i).LFz(locs_LFz);
            
            
            x_right_corner = -0.0005;
            x_left_corner = 0.5665;
            
            % Storage of the number of steps
            N_steps_l(i) = length(x_cop_l);
            N_steps_r(i) = length(x_cop_r);
            
            % If there is an uneven number of steps between left and right, 
            % they are shortend to the lower of the two
            if length(x_cop_l) ~= length(x_cop_r)
                if length(x_cop_l) > length(x_cop_r)
                    x_cop_l = x_cop_l(1:length(x_cop_r));
                end
                if length(x_cop_l) < length(x_cop_r)
                    x_cop_r = x_cop_r(1:length(x_cop_l));
                end
            end
            dxL = x_cop_l; %x_cop_l - x_right_corner;
            dxR = x_cop_r; %x_left_corner - x_cop_r;
            
            %Step width (SW) calculation and variance storage
            step_width =(-dxL)+dxR;

            SW_var(j,i) = var(step_width);
            
            % Uncomment this to show histograms of the step width
            % figure(i);
            % histogram(step_width)
        
        end

    end
    % Store the current participants step width per walking condition
    GA_SWv = [GA_SWv; SW_var(:,1);SW_var(:,2)];
    NW_SWv = [NW_SWv; SW_var(:,3);SW_var(:,4)];
    ZT_SWv = [ZT_SWv; SW_var(:,6);SW_var(:,7)];
end
%% Statistical analysis

%Combine Step Width values and get characteristics
NW_ZT_GA = [NW_SWv,ZT_SWv,GA_SWv];
SW_means = mean(NW_ZT_GA);
SW_median = median(NW_ZT_GA);

%Normality testing
[h_GA, pn(1)] = kstest(GA_SWv);
[h_NW, pn(2)] = kstest(NW_SWv);
[h_ZT, pn(3)] = kstest(ZT_SWv);

%Uncomment the line below for anova tests
%aov = anova(NW_ZT_GA);

%Kruskal wallis tests and multiple comparison
[p, tbl1, stats] = kruskalwallis(NW_ZT_GA,[],'on')
c = multcompare(stats);
tbl2 = array2table(c,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);

%% Creation of the boxchart
%This section creates the output boxchart
%Please not that the significance bars are manually placed based on the
%output containing in "c"
NW_ZT_GA_mm =NW_ZT_GA * 1000;
figure()
boxchart(NW_ZT_GA_mm,'Notch','on','BoxFaceColor',"#000000",MarkerStyle="o",MarkerColor="#000000")
title('Step width variance in different walking conditions',FontSize=13)
ylabel('Step width variance in mm',FontSize=13)
xlabel('Walking condition',FontSize=13)

set(gca,'XTickLabel',{'Normal Walking','Zero Torque', 'General Assistance'});
yt = get(gca, 'YTick');
xt = double(get(gca, 'XTick'));
hold on
plot(xt([2 3]), [1 1]*max(yt)*1.05, '-k',  mean(xt([2 3])), max(yt)*1.1, '*k','LineWidth',0.8)
plot(xt([1 3]), [1 1]*max(yt)*1.15, '-k',  mean(xt([1 3]))-0.05, max(yt)*1.2, '*k',mean(xt([1 3]))+0.05, max(yt)*1.2, '*k','LineWidth',0.8)
ylim([0,3.2])
set(gca,'fontname','times')
hold off

