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
% Pareto optimal solutions can be considered equally desirable. The user is responsible to select the most 
% preferred ones. 
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

clear all; clc;
global F5m Cs S90m
F5m=load('C:\Users\vsergis\Desktop\ETS\Flow\Flow5min\net17.mat', 'snet');
F5m = F5m.('snet');
C7d=load('C:\Users\vsergis\Desktop\ETS\Compressive strength\7d\net2.mat', 'snet');
C7d = C7d.('snet');
C28d=load('C:\Users\vsergis\Desktop\ETS\Compressive strength\28d\net19.mat', 'snet');
C28d = C28d.('snet');
S90m=load('C:\Users\vsergis\Desktop\ETS\Shear stress\S90min\net19.mat', 'snet');
S90m= S90m.('snet');

%%%%%
Fbd=[65 95]; % Flow boundaries
Sbd=[80 16]; %Strength and shear boundaries
Cs=C28d; %Choose between 7d or 28d

%     Cement Sand WB   SB  SP %SP   %VMA   %Xseed
lb = [1       1   0.3  1.7 1  0.13   0      0      0 0];  % Lower bound
ub = [3       3   0.4  2.4 3  0.28   0.018  0.4    0 0]; % Upper bound
%%%%%


title={'Cement' 'Sand' 'WB' 'SB' 'SP' 'SP_%' 'VMA' 'Xseed' 'NanoC' 'Acc' 'Flow' 'Compressive' 'Shear'};
nvar = 10;
options = optimoptions('paretosearch','PlotFcn','psplotparetof');
[x,fval,exitflag,output,residuals] = paretosearch(@obj_fun,nvar,[],[],[],[],lb,ub,[],options);

b_x=[round(x(:,1)) round(x(:,2)) round(x(:,3:4),3) round(x(:,5)) round(x(:,6),2) round(x(:,7:end),3)];
Pr=unique(b_x,'rows');
Dr=[Pr F5m(Pr')' Cs(Pr')' S90m(Pr')' Cs(Pr')'+S90m(Pr')'];
Pr_t=sortrows(Dr,14,'descend');
Pr_n=Pr_t(:,1:end-1);
h=Pr_n(:,11)>Fbd(1);Pr_t=Pr_n(h,:);
h=Pr_t(:,11)<Fbd(2);
Pr_n=Pr_t(h,:);
p=(Pr_n(:,12)>Sbd(1));k=(Pr_n(:,13)>Sbd(2));
o=logical((p+k)-1);
Pr_n=Pr_n(o,:);
C = cell(size(Pr_n));
C(Pr_n(:,1)==1,1)={'GU'};C(Pr_n(:,1)==2,1)={'HE'};C(Pr_n(:,1)==3,1)={'GUbSF'};
C(Pr_n(:,2)==1,2)={'Bomix'};C(Pr_n(:,2)==2,2)={'Marco'};C(Pr_n(:,2)==3,2)={'Recycled'};
C(:,3)=num2cell(Pr_n(:,3));C(:,4)=num2cell(Pr_n(:,4));
C(Pr_n(:,5)==1,5)={'MG75'};C(Pr_n(:,5)==2,5)={'MG79'};C(Pr_n(:,5)==3,5)={'MR11'};
C(:,6)=num2cell(Pr_n(:,6));C(:,7)=num2cell(Pr_n(:,7));C(:,8)=num2cell(Pr_n(:,8));
C(:,9)=num2cell(Pr_n(:,9));C(:,10)=num2cell(Pr_n(:,10));
C(:,11)=num2cell(Pr_n(:,11));C(:,12)=num2cell(Pr_n(:,12));C(:,13)=num2cell(Pr_n(:,13));
Proposed=[title;C];
disp(Proposed)
bb=F15in(Pr_n(:,1:end-3)')'+F30in(Pr_n(:,1:end-3)')'+F45in(Pr_n(:,1:end-3)')';
aa=[F5m(Pr_n(:,1:end-3)')' F5m(Pr_n(:,1:end-3)')'-bb];
disp(aa);
