% Code Annotation 
% ************************************************************
% This algorithm is part of a methodology proposed to automate the mix design process for 3D concrete 
% printing applications. The objective of this algorithm is to discover ideal settings in order to decrease 
% the ANNs' errors and enhance their accuracy. A genetic algorithm is used to find the best possible 
% hyperparameters of the networks. The hyperparameters that are tested are the training method, the number  
% of hidden layers and the neurons of each hidden layer. The maximum number of generations of the genetic 
% algorithm was selected to be 100, the number of candidate solutions of the first generation was 80, and 
% at every new generation, the number was increased by 40. The algorithm returns the best generated ANN’s 
% and the user selects the one that he/she wishes to keep.
% 
% The author of this code is Vasileios Sergis (vasileios.sergis.1@ens.etsmtl.ca) and the code was written 
% as part of the Ph.D. at Ecole de technologie superieure, Universite du Quebec, directed by Professor 
% Claudiane Ouellet-Plamondon (Claudiane.Ouellet-Plamondon@etsmtl.ca). The funding organizations 
% acknowledged are Fonds de recherche du Quebec – Nature et Technologies and the Canada Research Chair 
% Program. 
%
% This code was generated for the article: Sergis, V. and C.M. Ouellet-Plamondon, Automating mix design 
% for 3D printing applications using optimization methods. Digital Discovery 2022 
% Cite the article when using this code. 
% **************************************************************

%%
%~Initialization~
clear all;close all;warning off; clc;           %Initialize code by deleting data from the previous run.
global ys Mixes num_net bg_temp b_out           %Global variables used in the main code and the routines.
direc='.\Data.xlsx';                            %Directory of the dataset.
v={};save('20net.mat', 'v');                    %Initialize matrix where the 20 best models will be saved. 
Mix=readtable(direc,'Range','A4:J270');         %Read mix combinations. For the qualitative factors, the 
                                                ...values represent the available options (e.g., cement type:
                                                ... 1=GU, 2=HE, 3=GUbSF). The 'Range' corresponds to the  
                                                ...available mixes and need to be defined by the user.
%%%%%%%%%%%%%%%%
F5m=readtable(direc,'Range','L4:M270');         %Read test's results. The 'Range' is based on the test (e.g., 
                                                ...flow, shear, compressive and age of specimen) need to 
                                                ...be defined by the user. 
[ys,r]=rmmissing(F5m{:,1});                     %Find empty data (if any) and keep their indices.
b_out=[0 152];                                  %Define range of possible outcome value (depending on the test).
%%%%%%%%%%%%%%%%
%%
%~Prepare parameters of the genetic algorithm~

Mixes=Mix(~r,:);                                %Keep mixes with available data. Remove empty data (if any).
bg_temp=inf*ones(20,7+(size(ys,1)-(floor(size(ys,1)*0.7)+floor(size(ys,1)*0.15)))); %Initialize matrix for display purposes (to compare trained models).

num_net=2;                                      %Max number of hidden layers. 
nvars = num_net+2;                              %Number of hyperparameters that the GA will optimize.
LB = [1 1 1*ones(1,num_net)];                   %Low boundaries for each hyperparameter.
UB = [8 num_net 100*ones(1,num_net)];           %Upper boundaries for each hyperparameter.
options = optimoptions(@ga,'MaxGenerations',100,'PlotFcn',{@gaplotbestf,@gaplotmaxconstr},'Display','iter'); %Set options for GA:Maximum generations and display settings.
[x,fval] = ga(@objectivefunction_ga,nvars,[],[],[],[],LB,UB,[],[1:nvars],options); %Call GA function, define the objective function and the parameters.
%%
%~Compare models~
load('All_data.mat');load('20net.mat');         %Load the 20 best models (saved during the optimization process).
for i=1:20                                      %This loop creates a matrix that summarizes the best models. It is made for displaying purposes to help the user compare the models. 
   NRMSE2 = sqrt(perform(v{i}, v{i}(Mixes{:,:}')', ys(:,1)))/mean(ys(:,1));
   data_cor2=[ys(:,1) v{i}(Mixes{:,:}')'];
   R_sq2=corr2(data_cor2(:,1),data_cor2(:,2))^2; 
   
   ab5=sum(abs(ys(:,1)-v{i}(Mixes{:,:}')')>5);
   ab15=sum(abs(ys(:,1)-v{i}(Mixes{:,:}')')>15);
   ab25=sum(abs(ys(:,1)-v{i}(Mixes{:,:}')')>25);
   ab45=sum(abs(ys(:,1)-v{i}(Mixes{:,:}')')>45);
   allnets(i,:)=[i NRMSE2 R_sq2 ab5 ab15 ab25 ab45]; %The matrix includes: [number of models, normalized root mean square error, coefficient of determination, number of predictions with a difference above 5,15.. of the real value].
end
disp(allnets)
ps = input('Which network to display? (rank 1-20, 0 to skip) : '); %The user can display the real values and the predictions of a model. Break loop with 0 as input value.
while ps~=0
NRMSE2 = sqrt(perform(v{ps}, v{ps}(Mixes{:,:}')', ys(:,1)))/mean(ys(:,1));
data_cor2=[ys(:,1) v{ps}(Mixes{:,:}')'];
R_sq2=corr2(data_cor2(:,1),data_cor2(:,2))^2;

disp([ys(:,1) v{ps}(Mixes{:,:}')' ys(:,1)-v{ps}(Mixes{:,:}')'])
disp(sum(abs(ys(:,1)-v{ps}(Mixes{:,:}')')>5))
disp(sum(abs(ys(:,1)-v{ps}(Mixes{:,:}')')>15))
disp(sum(abs(ys(:,1)-v{ps}(Mixes{:,:}')')>25))
disp(sum(abs(ys(:,1)-v{ps}(Mixes{:,:}')')>45))
disp(bg_temp(ps,:))
disp(NRMSE2)
disp(R_sq2)
ps = input('Which network to display? (rank 1-20, 0 to skip) : ');
end
%%
%~Save model~
net_n=input('Which network do you want to save?: '); %Message to the user to save the network he/she desires.
snet=v{net_n};
snet_par=bg_temp(net_n,:);
save('net and parameters.mat', 'snet', 'snet_par');
