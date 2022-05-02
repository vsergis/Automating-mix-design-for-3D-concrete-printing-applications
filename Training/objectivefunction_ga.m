% Code Annotation 
% ************************************************************
% This routine is part of a methodology proposed to automate the mix design process for 3D concrete 
% printing applications. This is the objective function of the genetic algorithm. The goal is to 
% simultaneously maximize the coefficient of determination and minimize the normalized root mean squared 
% error.
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

function y = objectivefunction_ga(x)    %Objective function that GA minimizes.
[NRMSE,R_sq]=MLP_training(x);           %Calls the routine where the models are trained and returns the 
                                        ...normalized root mean square error and the coefficient of determination.
y=sum(NRMSE)/sum(R_sq);                 %Objective: simultaneously decrease the normalized root mean square error (~0) 
                                        ...and increase the coefficient of determination (~1).
