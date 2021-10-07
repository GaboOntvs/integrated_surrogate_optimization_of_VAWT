function CP = CFD_SavRotMachv31sweep(fileName,inicio,paso,final,V,theta,Or,radioMayor)
    %Comsol Parameters
    TSR_sweep = [inicio:paso:final];
    wind_velocity = V;
    radio_rotor = 0.25;
    num_muestras = 150;
    num_ciclos = 3;
    
    FyH = fix(clock);
    fprintf('Hora local %d:%d:%d\n',FyH(4),FyH(5),FyH(6))
    disp('Loading Comsol model')
    Cmodel = mphopen(fileName,'modelSav'); 
    
    geom = Cmodel.geom('geom1');
    cad = Cmodel.geom('geom1').feature('cad1');
    cad.updateCadParamTable(true,true);
    %Update design parameters
    anguloDeCorte = theta;
    overlapRatio = Or;
    radioMayorElip = radioMayor;
    
    %Set global parameters
    Cmodel.param.set('LL_cut_angle',anguloDeCorte);
    Cmodel.param.set('LL_elip_mayor_radius',radioMayorElip);
    Cmodel.param.set('LL_overlap_ratio',overlapRatio);
    
    Cmodel.param.set('V',wind_velocity);
    Cmodel.param.set('R',radio_rotor);
    Cmodel.param.set('samples',num_muestras);
    Cmodel.param.set('ciclos',num_ciclos);
    disp('Building Geometry')
    geom.run; 
    
    %Build entire mesh
    mesh = Cmodel.mesh('mesh1');
    disp('Building Mesh')
    mesh.run;
    
    estudio = Cmodel.study('std1');
    disp('Running Study')
    estudio.run;
    
    %Create cells to storage solution vectors for Torque and Time  
    [~,num_tsr] = size(TSR_sweep);
    Torque = cell(1,num_tsr);
    Tiempo = cell (1,num_tsr);
    
    %Evaluate global expression for Torque and compute Time vectors
    for i=1:num_tsr
        Torque{i}= mphglobal(Cmodel,'Torque_3_6','dataset','dset5','outersolnum',i); 
        Tiempo{i} = linspace(0,(1/(((TSR_sweep(i)*wind_velocity)/radio_rotor)/(2*pi)))*num_ciclos,num_muestras+1);
    end
    
    %Integrate and compute average torque
    avgTorque = zeros(1,num_tsr);
    angVel = zeros(1,num_tsr);
    for i=1:num_tsr
        avgTorque(i) = (trapz(Tiempo{i}(101:num_muestras+1),Torque{i}(101:num_muestras+1))) / (Tiempo{i}(num_muestras+1) - Tiempo{i}(101));
        angVel(i) = ((TSR_sweep(i)*wind_velocity)/radio_rotor);  
    end
    
    %Compute wind power and VAWT power
    A = 0.5*0.5;
    rho = 1.225; 
    P_wind = 0.5*rho*A*wind_velocity^3;
    P_rot = zeros(1,num_tsr);
    for i=1:num_tsr
        P_rot(i) =   avgTorque(i) * angVel(i);
    end
    
    %Computer Cp for each experiment in DOE and storage it
    CP = P_rot/P_wind;   
end