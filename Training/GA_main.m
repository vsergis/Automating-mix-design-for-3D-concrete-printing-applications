% Code Annotation 
% ************************************************************
% This algorithm is part of a methodology proposed to automate the mix design process for 3D concrete 
% printing applications. The objective of this algorithm is to discover ideal settings in order to decrease 
% the ANNs' errors and enhance their accuracy. A genetic algorithm is used to find the best possible 
% parameters of the networks. The parameters that are tested are the training method, the number of 
% hidden layers and the neurons of each hidden layer. The maximum number of generations of the genetic 
% algorithm was selected to be 100, the number of candidate solutions of the first generation was 80, and 
% at every new generation, the number was increased by 40. The algorithm returns the best generated ANN’s 
% and the user selects the one that he wishes to keep.
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

clear all;close all;warning off; clc;
global ys Mixes num_net bg_temp b_out val

v={};save('20net.mat', 'v');
direc='C:\Users\vsergis\Desktop\ETS\Data.xlsx';
Mix=readtable(direc,'Range','A3:J276');

%%%%%%%%%%%%%%%%
F5m=readtable(direc,'Range','L3:L276');
[ys,r]=rmmissing(F5m{:,1});
b_out=[0 152]; 
%%%%%%%%%%%%%%%%

Mixes=Mix(~r,:);
bg_temp=inf*ones(20,7+(size(ys,1)-(floor(size(ys,1)*0.7)+floor(size(ys,1)*0.15))));
val=inf*ones(20,floor(size(ys,1)*0.15));

ObjectiveFunction = @simple_fitness;
num_net=2;
nvars = num_net+2;
LB = [1 1 1*ones(1,num_net)];
UB = [8 num_net 100*ones(1,num_net)];
ConstraintFunction = [];
options = optimoptions(@ga,'MaxGenerations',100,'PlotFcn',{@gaplotbestf,@gaplotmaxconstr},'Display','iter');
[x,fval] = ga(ObjectiveFunction,nvars,[],[],[],[],LB,UB,ConstraintFunction,[1:nvars],options);

load('All_data.mat');load('20net.mat');
for i=1:20
   NRMSE2 = sqrt(perform(v{i}, v{i}(Mixes{:,:}')', ys(:,1)))/mean(ys(:,1));
   data_cor2=[ys(:,1) v{i}(Mixes{:,:}')'];
   R_sq2=corr2(data_cor2(:,1),data_cor2(:,2))^2; 
   
   ab5=sum(abs(ys(:,1)-v{i}(Mixes{:,:}')')>5);
   ab15=sum(abs(ys(:,1)-v{i}(Mixes{:,:}')')>15);
   ab25=sum(abs(ys(:,1)-v{i}(Mixes{:,:}')')>25);
   ab45=sum(abs(ys(:,1)-v{i}(Mixes{:,:}')')>45);
   allnets(i,:)=[i NRMSE2 R_sq2 ab5 ab15 ab25 ab45];
end
disp(allnets)
ps = input('Which network? (rank 1-10) : ');
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
ps = input('Which network? (rank 1-10) : ');
end
net_n=input('Which network do you want to save?: ');
snet=v{net_n};
snet_par=bg_temp(net_n,:);
save('net and parameters.mat', 'snet', 'snet_par');
