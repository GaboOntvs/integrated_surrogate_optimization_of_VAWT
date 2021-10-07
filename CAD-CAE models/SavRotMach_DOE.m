clear all
clc
%v3_1 version for Full Factorial DOE

%Define the entire set of VAWT geometries to evaluate
%The order of the Design parameters is: 'theta', 'Or', 'mayor radius'
DOE = {[43.724, 0.14, 185.875],[77.97, 0.13, 172]};
DOE_code = {'GA1'};
[~,num_exp] = size(DOE);  
CP_DOE = cell(2,num_exp);
%Parametric sweep must match the one defined in Comsol model at 'CFD_LiveLink_RotMach_Savonius_v3_15.mph'
inicio = 0.1;
paso = 0.1;
final = 0.8;
TSR_sweep = [inicio:paso:final];
V = 6;

for j=1:num_exp 
    fprintf('Running study for experiment number: %d\n',j)
    CP_DOE{1,j} = CFD_SavRotMachv31sweep('CFD_LiveLink_RotMach_Savonius_v3_1',inicio,paso,final,V,DOE{j}(1),DOE{j}(2),DOE{j}(3));  
    CP_DOE{2,j} = DOE_code{j};
end


