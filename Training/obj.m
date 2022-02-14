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

function [NRMSE,R_sq]=obj(g)
global ys Mixes num_net bg_temp b_out val
tr_s=floor(size(ys,1)*0.7);layers=g(2); nodes=g(3+(num_net-layers):end);
Doptimal_design=Mixes{:,:};
tr_function={'trainlm', 'trainrp', 'trainscg', 'traincgb', 'traincgf', 'traincgp', 'trainoss', 'traingdx'};
s = RandStream('mt19937ar','Seed',sum(100*clock));
y = datasample(s,1:size(ys,1),tr_s,'Replace',false);
a=setdiff([1:size(ys,1)],y);
valdata=floor(size(ys,1)*0.15);
b = datasample(s,a,valdata,'Replace',false);
validation_t=sort([y,b]);
load('20net.mat')
inputs=Doptimal_design(y,:)'; 
outputs1=ys(y,:)'; 
outputs=ys(y,1)'; 

net=fitnet(nodes);
net = configure(net,inputs,outputs);
net.outputs{end}.exampleOutput = b_out;
net.outputs{end}.ProcessFcns = {'mapminmax'};
net.layers{end}.transferFcn = 'tansig';
net.trainFcn = tr_function{g(1)};
net.divideFcn = 'dividetrain';
net.trainParam.epochs=400;
net = train(net,inputs,outputs);
pp=net(Doptimal_design(validation_t,:)');

unseen=setdiff([1:size(ys,1)],validation_t);
pp_uns=net(Doptimal_design(unseen,:)');

for i=1:size(ys,2)
    NRMSE(i) = sqrt(perform(net, pp(i,:), ys(validation_t,i)'))/abs(mean(ys(validation_t,i)));
    data_cor=[ys(validation_t,i)';pp(i,:)]';
    R_sq(i)=corr2(data_cor(:,1),data_cor(:,2))^2;
end

for i=1:size(ys,2)
    NRMSEun(i) = sqrt(perform(net, pp_uns(i,:), ys(unseen,i)'))/abs(mean(ys(unseen,i)));
    data_cor=[ys(unseen,i)';pp_uns(i,:)]';
    R_squn(i)=corr2(data_cor(:,1),data_cor(:,2))^2;
end

goal=sum(NRMSEun)/sum(R_squn);

if (goal<max(bg_temp(:,1)))
    if size(nodes)<num_net; nodes=[nodes 0*ones(num_net-size(nodes,2),1)]; end
    unseen_=setdiff([1:size(ys,1)],validation_t);
    bg_temp(end,:)=[goal,NRMSEun,R_squn,g(1),layers,nodes,unseen_];
    [bg_temp,r]=sortrows(bg_temp,1);
    val(end,:)=b;val=val(r(:,1),:);
    v(20)={net};v=v(r(:,1));
    save('20net.mat', 'v');
    save All_data
end
