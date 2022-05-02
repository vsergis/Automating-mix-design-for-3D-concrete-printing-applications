% Code Annotation 
% ************************************************************
% This algorithm is part of a methodology proposed to automate the mix design process for 3D concrete 
% printing applications. Multiobjective Pareto optimization is used with the aim of developing a mix that 
% meets the desired properties and simultaneously reduces the material and time required to be developed. 
% The algorithm can edit up to eight factors, where three of them are qualitative and the remaining five 
% are treated as quantitative factors. These parameters are the water-to-binder ratio, the sand-to-binder 
% ratio, the dosage of the superplasticizer, the dosage of the biopolymer polysaccharide viscosity 
% modifying agent, and the dosage of crystalline calcium silicate hydrate. The user can select the ratio 
% or the dosage range for each factor. The output of the Pareto optimization algorithm is a new set of 
% mixes with properties closer to the desired values by respecting the trade-offs between them. All the 
% Pareto optimal solutions can be considered equally desirable. The user is responsible for selecting the  
% most preferred ones. 
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
clear all; clc;                                             %Initialize code by deleting data from the previous run.
global F5m Cs S90m                                          %Global variables used in the main code and the routines.
F5m=load('.\Nets\Flow_i5.mat', 'snet').('snet');            %Load network for flow test (Workability).
S90m=load('.\Nets\Shear_i5.mat', 'snet').('snet');          %Load network for direct shear test (Buildability).
Cs=load('.\Nets\Compressive.mat', 'snet').('snet');         %Load network for compressive strength test.

%%%%%
Fbd=[65 95];                                                %Set lower and upper boundaries for flow (for displaying purposes).
Sbd=[80 16];                                                %Set lower boundaries for compressive strength and shear stress (for displaying purposes).
%%
%~Prepare parameters of the Pareto algorithm~

%The eight factors are: the cement type (1=GU, 2=HE, 3=GUbSF), the sand type (1=Fine, 2=Coarse, 3=Recycled),  
...the superplasticizer type (1=PCE-1, 1=PCE-2, 3=SNP), the water-to-binder ratio (WB), the sand-to-binder ratio (SB),
...the superplasticizer dosage (%SP), the viscosity modifying agent dosage (B) and the calcium silicate hydrate (CSH-C). 

%%%   Cement Sand WB   SB  SP %SP   %B     %CSH-C     %%%
lb = [1       1   0.3  1.7 1  0.13   0      0      0 0];    % Lower boundaries of the eight factors (hyperparameters). 
ub = [3       3   0.4  2.4 3  0.28   0.018  0.4    0 0];    % Upper boundaries of the eight factors (hyperparameters).
%%%                                                         
nvar = 8+2;                                                 %Number of factors (+2 due to mix combinations from previous study. Their range is set to zero).
options = optimoptions('paretosearch','PlotFcn','psplotparetof'); %Plot options (display purposes).
[x,fval,exitflag,output,residuals] = paretosearch(@multiobjectives_pa,nvar,[],[],[],[],lb,ub,[],options); %Call Pareto function, define the objective function and the parameters.
%%
%~Display new mixes~'

%The non-dominated points provided by the pareto algorithm are post-processed. 
title={'Cement' 'Sand' 'WB' 'SB' 'SP' 'SP_%' 'B' 'CSH_C' 'Ex1' 'Ex2' 'Flow' 'Compressive' 'Shear'};
b_x=[round(x(:,1)) round(x(:,2)) round(x(:,3:4),3) round(x(:,5)) round(x(:,6),2) round(x(:,7:end),3)];
Pr=unique(b_x,'rows');                                      %Only the unique solutions are kept. 
Dr=[Pr F5m(Pr')' Cs(Pr')' S90m(Pr')' Cs(Pr')'+S90m(Pr')'];  %Matrix with new mixes and their predicted properties. 
Pr_t=sortrows(Dr,14,'descend');                             %The mixes are sorted based on the shear stress and compressive strength performance.
Pr_n=Pr_t(:,1:end-1);                                       
h=Pr_n(:,11)>Fbd(1);Pr_t=Pr_n(h,:);                         %The solutions are filtered based on the  
h=Pr_t(:,11)<Fbd(2);                                        ...hyperparameters set by the user (lb, ub)
Pr_n=Pr_t(h,:);
p=(Pr_n(:,12)>Sbd(1));k=(Pr_n(:,13)>Sbd(2));
o=logical((p+k)-1);
Pr_n=Pr_n(o,:);
C = cell(size(Pr_n));                                       %Create a cell to display the new mixes
C(Pr_n(:,1)==1,1)={'GU'};C(Pr_n(:,1)==2,1)={'HE'};C(Pr_n(:,1)==3,1)={'GUbSF'};
C(Pr_n(:,2)==1,2)={'Fine'};C(Pr_n(:,2)==2,2)={'Coarse'};C(Pr_n(:,2)==3,2)={'Recycled'};
C(:,3)=num2cell(Pr_n(:,3));C(:,4)=num2cell(Pr_n(:,4));
C(Pr_n(:,5)==1,5)={'PCE-1'};C(Pr_n(:,5)==2,5)={'PCE-2'};C(Pr_n(:,5)==3,5)={'SNP'};
C(:,6)=num2cell(Pr_n(:,6));C(:,7)=num2cell(Pr_n(:,7));C(:,8)=num2cell(Pr_n(:,8));
C(:,9)=num2cell(Pr_n(:,9));C(:,10)=num2cell(Pr_n(:,10));
C(:,11)=num2cell(Pr_n(:,11));C(:,12)=num2cell(Pr_n(:,12));C(:,13)=num2cell(Pr_n(:,13));
Proposed=[title;C];
disp(Proposed);                                             %Display new mixes and their predicted properties.
