% Code Annotation 
% ************************************************************
% This routine is part of a methodology proposed to automate the mix design process for 3D concrete 
% printing applications. The objective functions of the multiobjective algorithm are the generated neural 
% networks. The three targets are the improvement of the workability, buildability, and compressive 
% strength. The algorithm is used to simultaneously optimize the values of the three properties and the 
% user can select to minimize, maximize or set a target value for each of the properties.
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

function y = obj_fun(x)
global F5m Cs S90m
n_particle=[round(x(1)) round(x(2)) round(x(3:4),3) round(x(5)) round(x(:,6),2) round(x(:,7:end),3)];
F=F5m(n_particle');
C=Cs(n_particle');
S=S90m(n_particle');

y=[-S -C abs(F-70)];
end
