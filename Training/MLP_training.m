% Code Annotation 
% ************************************************************
% This routine is part of a methodology proposed to automate the mix design process for 3D concrete 
% printing applications. The objective of this algorithm is to train neural networks and keep the best 20.
% The data is divided into training, validation, and testing sets. The proportions of splits were 70% for 
% training, 15% for validation and 15% for testing with the unseen data. The number of maximum epochs of 
% each network was selected to be 400. Depending on the cement property being modelled, different 
% parameters were considered to be the best for each individual network. The options between the training 
% methods included the following functions: Levenberg–Marquardt optimization, resilient backpropagation 
% algorithm, scaled conjugate gradient method, conjugate gradient backpropagation with Powell-Beale 
% restarts, conjugate gradient backpropagation with Fletcher-Reeves updates, conjugate gradient 
% backpropagation with Polak-Ribiére updates, one-step secant method, gradient descent momentum and an 
% adaptive learning rate.
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
function [NRMSE,R_sq]=MLP_training(g)
%~Initialization~
global ys Mixes num_net bg_temp b_out                   %Global variables used in this routine and the main code.
tr_s=floor(size(ys,1)*0.7);                             %Number of samples in train set. The data is split into
                                                        ...train|validation|test sets (=70%,15%,15%).
layers=g(2);                                            %The hyperparameters proposed by the GA (number of hidden layers, 
nodes=g(3+(num_net-layers):end);                        ...neurons in each hidden layer).
Doptimal_design=Mixes{:,:};                             %The mix combinations.
tr_function={'trainlm', 'trainrp', 'trainscg', 'traincgb'...
    ,'traincgf', 'traincgp', 'trainoss', 'traingdx'};   %The available training methods.
s = RandStream('mt19937ar','Seed',sum(100*clock));      %Create a random number stream.
train_set = datasample(s,1:size(ys,1),tr_s,'Replace',false);    %Randomly select the samples for the train set.
a=setdiff([1:size(ys,1)],train_set);                    %Keep the remaining data (not included in the train set).
valdata=floor(size(ys,1)*0.15);                         %Number of samples in validation set.
validation_set = datasample(s,a,valdata,'Replace',false); %From the remaining data, randomly select the samples
al_incl=sort([train_set,validation_set]);               ...for the validation set.
load('20net.mat')
inputs=Doptimal_design(train_set,:)';                   %Feed mix combinations of train set as input to the MLP.
outputs=ys(train_set,1)';                               %The real values of the train set as output/target.
%%
%~Define the neural network~ 
net=fitnet(nodes);                                      %Manually constructing the network by defining the  
net=configure(net,inputs,outputs);                      ...model architecture {input, hidden, and output layers,
net.outputs{end}.exampleOutput = b_out;                 ...number of nodes in each hidden layer, range of output
net.outputs{end}.ProcessFcns = {'mapminmax'};           ...values, normalize values between [-1,1], tanh or
net.layers{end}.transferFcn = 'tansig';                 ...hyperbolic tangent as activation function, selected 
net.trainFcn = tr_function{g(1)};                       ...train function (hyperparameter), assign all targets 
net.divideFcn = 'dividetrain';                          ...to the train set (the data is split manually, here
net.trainParam.epochs=400;                              ...the input is the train set), and the number of epochs}. 
net=train(net,inputs,outputs);                          %Train the network.
%%
%~Evaluation~
pp=net(Doptimal_design(validation_set,:)');             %Get predictions for the validation set.
test_set=setdiff([1:size(ys,1)],al_incl);               %Store unseen data as the test set.
pp_uns=net(Doptimal_design(test_set,:)');               %Get predictions in the test set (unseen data).

for i=1:size(ys,2)                                      %Calculate normalized root mean square error and 
                                                        ...coefficient of determination for validation set.
    NRMSE(i) = sqrt(perform(net, pp(i,:), ys(validation_set,i)'))/abs(mean(ys(validation_set,i)));
    data_cor=[ys(validation_set,i)';pp(i,:)]';
    R_sq(i)=corr2(data_cor(:,1),data_cor(:,2))^2;
end
for i=1:size(ys,2)                                      %Calculate normalized root mean square error and 
                                                        ...coefficient of determination for the test set (unseen).
    NRMSEun(i) = sqrt(perform(net, pp_uns(i,:), ys(test_set,i)'))/abs(mean(ys(test_set,i)));
    data_cor=[ys(test_set,i)';pp_uns(i,:)]';
    R_squn(i)=corr2(data_cor(:,1),data_cor(:,2))^2;
end
%%
%~Store data~
goal=sum(NRMSE)/sum(R_sq);                              %Calculate the objective based on the validation set (to optimize it).
if (goal<max(bg_temp(:,1)))                             %Compare value with the previous obtained (the worst among the 20 best). 
    if size(nodes)<num_net                              %Make sure that there is no inconsistency in the matrix
        nodes=[nodes 0*ones(num_net-size(nodes,2),1)];  ...size(happens due to different architectures).
    end                                                                        
    bg_temp(end,:)=[goal,NRMSEun,R_squn,g(1),layers,nodes,test_set]; %Store important data, such as the evaluation of the test set, 
                                                        ...at the last row of the matrix (replacing the previous data). 
    [bg_temp,r]=sortrows(bg_temp,1);                    %Sort the collected data based on the performance.
    v(20)={net};v=v(r(:,1));                            %Store the network and sort it as the collected data.
    save('20net.mat', 'v');                             %Save networks in the same file after updating them.
    save All_data.mat                                   %Save all data in the matrix (useful during debugging)
end
