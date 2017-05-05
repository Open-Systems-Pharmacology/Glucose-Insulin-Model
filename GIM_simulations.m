function GIM_simulations
% This script performs a series of simulations of the Glucose Insulin Model
% (GIM) and compares simulation results with experimental data.
% Simulated scenarios are:
%1 : IVGTT 0.5 g/kg bw glucose
%2 : IVITT 0.04 IU/kg bw insulin
%3 : CIVII 0.25 mU/kg bw insulin 
%4 : OGTT 100 g glucose dissolved in water
%5 : 250 mg/kg bw glucose in T1DM patients with insulin infusion mimicking physiological insulin response.
%6 : 250 mg/kg bw glucose in T1DM patients with constant basal insulin infusion.
% Description of the model and sources of experimental data can be found at https://github.com/Open-Systems-Pharmacology/Glucose-Insulin-Model

% Open Systems Pharmacology Suite
% Date: 12-Apr-2017

%Path to simulation and data files relative to the path of this script file.
rootPath = [fileparts(which('GIM_simulations.m')) filesep];
%Path to the excel file with custom parameters.
parsFile = [rootPath 'ParSets_OSPS.xls'];
%Path to the model file.
xmlFile = [rootPath 'GIM_Healthy.xml'];

% If 1, applies insulin sensitivity values defined further in the code for
% each simulation. If 0, applies default sensitivity values.
initExact = 1;
% Time for simulating the steady state.
initSimTime = 1000;

%Perform the simulations. Simulated scenarios are indexed as follows:
for m = 1 : 6
    %Define the weight of simulated individum.
    if m == 5 || m == 6
        weight = 73;
    else
        weight = 73;
    end
    %Define diabetic condition.
    if m == 5 || m == 6
        TDM = 'T1DM';
    else
        TDM = 'Healthy';
    end
    %Specify simulation time.
    if m == 4
        simTime = 350;
    elseif m == 5 || m == 6
        simTime = 240;
    else
        simTime = 200;
    end
    %Create the structure for the variable parameters
    initStruct=[];
    %First initialization is necessary in order to get a list of species
    %present in the simulation.
    initSimulation(xmlFile, []);
    %Get a list of available species.
    [~, desc] = existsSpeciesInitialValue('*', 1, 'parametertype', 'readonly');
    %Iterate through available species and initialize only those not
    %defined by a formula. This ensures that stead-state simulation will
    %not destroy any dependencies.
    for i = 2 : length(desc)
        path = desc{i, 2};
        isFormula = desc{i, 6};
        if ~isFormula
            initStruct = initSpeciesInitialValue(initStruct, path, 'withWarning');
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %INIT PARAMETER
    %Initialize parameters from the "Global"-tab of the parameters file.
    [parsGlobalVals, parsGlobalPath, ~] = xlsread(parsFile, 'Global');
    for i = 2:length(parsGlobalPath(:, 1))
        initStruct = initParameter(initStruct, ['*|' parsGlobalPath{i,1} '|' parsGlobalPath{i,2}],'withWarning');
    end
    % Initialize parameters defining the diabetic state from the parameters
    %file.
    [parsGroupVals, parsGroupPath,~] = xlsread(parsFile, TDM);
    for i = 2:length(parsGroupPath(:,1))
        initStruct = initParameter(initStruct, ['*|' parsGroupPath{i,1} '|' parsGroupPath{i,2}], 'withWarning');
    end
    %Initialize input parameters
    initStruct = initSimInputs(initStruct);
    %Initialize the simulation
    initSimulation(xmlFile,initStruct);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %SET VALUES
    %Set parameters from the "Global"-tab of the parameters file.
    for i = 2:length(parsGlobalPath(:,1))
        setParameter(parsGlobalVals(i-1,1), ['*|' parsGlobalPath{i,1} '|' parsGlobalPath{i,2}], 1);
    end
    %Set parameters defining the diabetic state from the parameters file.
    for i = 2:length(parsGroupPath(:,1))
        setParameter(parsGroupVals(i-1, 1), ['*|' parsGroupPath{i,1} '|' parsGroupPath{i,2}], 1);
    end
    
    %Apply insulin sensitivity values if selected.
    if initExact
        switch m
            case 1
                setParameter(1,'*|Organism|S_I',1);
            case 2
                setParameter(0.9,'*|Organism|S_I',1);
            case 3
                setParameter(1.1,'*|Organism|S_I',1);
            case 4
                setParameter(1,'*|Organism|S_I',1);
        end
    end
    tic
    %Simulate steady state.
    %Disable all applications except for the basal insulin infusion for
    %T1DM datasets.
    setSSInputs(weight, m);
    %Set simulation time. The time set should be long enough to bring
    %the system to a steady state.
    setSimulationTime(0 : initSimTime, 1);
    % Run the simulation
    disp('Run Simulation for SS calc')
    success = processSimulation(1);
    %Get a list of available species.
    [~, desc] = existsSpeciesInitialValue('*', 1);
    %Iterate through available species and set their initial values to
    %the last values from the steady state simulation.
    for i = 2 : length(desc)
        path = desc{i, 2};
        isFormula = desc{i, 6};
        %Ignore species which initial values are defined by a formula.
        if ~isFormula
            [~, vals] = getSimulationResult(path, 1);
            val = vals(end);
            setSpeciesInitialValue(val, path ,1);
        end
    end
    t=toc;
    sprintf('Steady State Sim. takes %d sec.',t)
    
    %Enable applications according to the simulated dataset.
    setInputs(weight, m);
    setSimulationTime(0 : simTime, 1);
    %Run the simulation
    disp('Run Full Simulation');
    tic
    success = processSimulation(1);
    t=toc;
    sprintf('Full Simulation takes %d sec.',t)
    % Get simulation results
    if success
        [simtime, sim_values_G] = getSimulationResult('*|Organism|PeripheralVenousBlood|Glucose|Plasma', 1);
        [~, sim_values_I] = getSimulationResult('*|Organism|PeripheralVenousBlood|Insulin|Plasma', 1);
        
        % #########################################################################
        % #########################################################################
        % #########################################################################
        switch m
            case 1
                simTimeM1 = simtime;
                simInsulinM1 = sim_values_I;
                simGlucoseM1 = sim_values_G;
            case 2
                simTimeM2 = simtime;
                simInsulinM2 = sim_values_I;
                simGlucoseM2 = sim_values_G;
            case 3
                simTimeM3 = simtime;
                simInsulinM3 = sim_values_I;
                simGlucoseM3 = sim_values_G;
            case 4
                simTimeM4 = simtime;
                simInsulinM4 = sim_values_I;
                simGlucoseM4 = sim_values_G;
            case 5
                simTimeM5 = simtime;
                simInsulinM5 = sim_values_I;
                simGlucoseM5 = sim_values_G;
            case 6
                simTimeM6 = simtime;
                simInsulinM6 = sim_values_I;
                simGlucoseM6 = sim_values_G;
        end
    else
        disp('Full Simulation was not successfull')
    end
end

%Read experimental data.
expDataGlucoseM1 = xlsread([rootPath 'Data\Sorensen_1985_IVGTT05.xlsx'], 'Glucose');
expTimeGlucoseM1 = expDataGlucoseM1(:, 1);
expGlucoseM1 = expDataGlucoseM1(:, 2);
expDataInsulinM1 = xlsread([rootPath 'Data\Sorensen_1985_IVGTT05.xlsx'], 'Insulin');
expTimeInsulinM1 = expDataInsulinM1(:, 1);
expInsulinM1 = expDataInsulinM1(:, 2);
% #########################################################################
exptDataGlucoseM2 = xlsread([rootPath 'Data\Sorensen_1985_IVITT004.xls'], 'Glucose');
expTimeGlucoseM2 = exptDataGlucoseM2(:, 1);
expGlucoseM2 = exptDataGlucoseM2(:, 2);
expDataInsulinM2 = xlsread([rootPath 'Data\Sorensen_1985_IVITT004.xls'], 'Insulin');
expTimeInsulinM2 = expDataInsulinM2(:, 1);
expInsulinM2 = expDataInsulinM2(:, 2);
% #########################################################################
expDataGlucoseM3 = xlsread([rootPath 'Data\Sorensen_1985_CIVII.xls'], 'Glucose');
expTimeGlucoseM3 = expDataGlucoseM3(:,1);
expGlucoseM3 = expDataGlucoseM3(:,2);
expDataInsulinM3 = xlsread([rootPath 'Data\Sorensen_1985_CIVII.xls'], 'Insulin');
expTimeInsulinM3 = expDataInsulinM3(:,1);
expInsulinM3 = expDataInsulinM3(:,2);
% #########################################################################
expDataGlucoseM4 = xlsread([rootPath 'Data\Sorensen_1985_OGTT.xls'], 'Glucose');
expTimeGlucoseM4 = expDataGlucoseM4(:, 1);
expGlucoseM4 = expDataGlucoseM4(:, 2);
expDataInsulinM4 = xlsread([rootPath 'Data\Sorensen_1985_OGTT.xls'], 'Insulin');
epxTimeInsulinM4 = expDataInsulinM4(:, 1);
expInsulinM4 = expDataInsulinM4(:, 2);
% #########################################################################
[~, sheetname_dat] = xlsfinfo(['Data\Regittnig_1999.xls']);
m_dat=size(sheetname_dat,2);
alldata_dat = cell(1, m_dat);
for i=1:1:4
    Sheet = char(sheetname_dat(1,i)) ;
    alldata_dat{i} = xlsread(['Data\Regittnig_1999.xls'],Sheet);
end
% #########################################################################
% #########################################################################

%Plot simulation results together with experimental data.
figure
subplot(4,3,1)
title('IVGTT');
hold on
grid on
plot(simTimeM1', simGlucoseM1/1000, 'b', 'linewidth', 2);
plot(expTimeGlucoseM1, expGlucoseM1, 's', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'MarkerSize',10);
axis([0 200 0 25]);
legend('Simulation', 'Measurements', 2, 'Location', 'NorthEast');
ylabel('Glucose [mmol/L]');
subplot(4,3,4);
hold on
grid on
plot(simTimeM1', simInsulinM1 * 1e6, 'r', 'linewidth', 2);
plot(expTimeInsulinM1, expInsulinM1, '^', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'MarkerSize', 10)
axis([0 200 0 720])
% Plot legend
legend('Simulation','Measurements',2,'Location','NorthEast');
ylabel('Insulin [pmol/L]');
xlabel('time t [min]');
% #########################################################################
subplot(4,3,7)
title('IVITT');
hold on
grid on
plot(simTimeM2',simGlucoseM2/1000,'b','linewidth',2)
plot(expTimeGlucoseM2,expGlucoseM2,'s','MarkerFaceColor','b','MarkerEdgeColor','k','MarkerSize',10)
axis([0 200 0 7])
ylabel('Glucose [mmol/L]');
subplot(4,3,10)
hold on
grid on
plot(simTimeM2',simInsulinM2 * 1e6,'r','linewidth',2)
plot(expTimeInsulinM2, expInsulinM2,'^','MarkerFaceColor','r','MarkerEdgeColor','k','MarkerSize',10)
axis([0 200 0 3600])
ylabel('Insulin [pmol/L]');
xlabel('time t [min]');
% #########################################################################
subplot(4,3,8)
title('OGTT');
hold on
grid on
plot(simTimeM4',simGlucoseM4/1000,'b','linewidth',2)
plot(expTimeGlucoseM4,expGlucoseM4,'s','MarkerFaceColor','b','MarkerEdgeColor','k','MarkerSize',10)
axis([0 350 0 8])
ylabel('Glucose [mmol/L]');
subplot(4,3,11)
hold on
grid on
plot(simTimeM4',simInsulinM4 * 1e6,'r','linewidth',2)
plot(epxTimeInsulinM4,expInsulinM4,'^','MarkerFaceColor','r','MarkerEdgeColor','k','MarkerSize',10)
axis([0 350 0 720])
ylabel('Insulin [pmol/L]');
xlabel('time t [min]');
% #########################################################################
subplot(4,3,2)
title('CIVII');
hold on
grid on
plot(simTimeM3',simGlucoseM3/1000,'b','linewidth',2)
plot(expTimeGlucoseM3, expGlucoseM3,'s','MarkerFaceColor','b','MarkerEdgeColor','k','MarkerSize',10)
axis([0 200 0 8])
ylabel('Glucose [mmol/L]');
subplot(4,3,5)
hold on
grid on
plot(simTimeM3',simInsulinM3 * 1e6,'r','linewidth',2)
plot(expTimeInsulinM3,expInsulinM3,'^','MarkerFaceColor','r','MarkerEdgeColor','k','MarkerSize',10)
axis([0 200 0 720])
ylabel('Insulin [pmol/L]');
xlabel('time t [min]');
% #########################################################################
MeanData_ins_oR =alldata_dat{1}(:,2);
StdvData_ins_oR =alldata_dat{1}(:,3);
Data_ins_oR_t(:,1)= alldata_dat{1}(:,1);

subplot(4,3,12)
errorbar(Data_ins_oR_t(:,1),MeanData_ins_oR * 1e6, StdvData_ins_oR * 1e6,StdvData_ins_oR * 1e6,'Color',[0 0 0],'linewidth',2,'MarkerSize',10);
hold all
grid on
plot(simTimeM6,simInsulinM6 * 1e6,'--r','linewidth',2);
xlabel('Time [min]');
ylabel('Insulin [pmol/L] ');
axis([0 240 0 8e-4 * 1e6])
%     #################################
MeanData_ins_mR=alldata_dat{2}(:,2);
StdvData_ins_mR=alldata_dat{2}(:,3);
Data_ins_mR_t(:,1)= alldata_dat{2}(:,1);

subplot(4,3,6);
errorbar(Data_ins_mR_t(:,1),MeanData_ins_mR * 1e6, StdvData_ins_mR * 1e6, StdvData_ins_mR * 1e6,'Color',[0 0 0],'linewidth',2,'MarkerSize',10);
hold all
grid on
plot(simTimeM5,simInsulinM5 * 1e6,'--r','linewidth',2);
legend('Measurements (stdv)', 'Simulation');
xlabel('Time [min]');
ylabel('Insulin [pmol/L] ');
axis([0 240 0 8e-4 * 1e6])
%     #################################
MeanData_gluc_oR =alldata_dat{3}(:,2);
StdvData_gluc_oR =alldata_dat{3}(:,3);
Data_gluc_oR_t(:,1)= alldata_dat{3}(:,1);

subplot(4,3,9)
errorbar(Data_gluc_oR_t(:,1),MeanData_gluc_oR/1000,StdvData_gluc_oR/1000,StdvData_gluc_oR/1000,'Color',[0 0 0],'linewidth',2,'MarkerSize',10);
hold all
grid on
plot(simTimeM6,simGlucoseM6/1000,'--b','linewidth',2);
title('T1DM IVGTT without Insulin Response');
ylabel('Glucose [mmol/L] ');
axis([0 240 0 3e4/1000])
%     #################################
MeanData_gluc_mR=alldata_dat{4}(:,2);
StdvData_gluc_mR=alldata_dat{4}(:,3);
Data_gluc_mR_t(:,1)= alldata_dat{4}(:,1);

subplot(4,3,3);
errorbar(Data_gluc_mR_t(:,1),MeanData_gluc_mR/1000,StdvData_gluc_mR/1000,StdvData_gluc_mR/1000,'Color',[0 0 0],'linewidth',2,'MarkerSize',10);
hold all
grid on
plot(simTimeM5,simGlucoseM5/1000,'--b','linewidth',2);
legend('Measurements (stdv)', 'Simulation');
title('T1DM IVGTT with Insulin Response');
ylabel('Glucose [mmol/L] ');
axis([0 240 0 3e4/1000])

function setInputs(bw, index)
%Enable applications according to the simulated scenario. Be aware of that
%all values must be provided in units standard for MoBi (refer to OSPS
%manual).

switch index
    case 1
        %0.5 g/kg bw glucose = 0.5e-3 kg/kg bw.
        setParameter(0.5e-3, '*|IVGTT|Application_1|ProtocolSchemaItem|DosePerBodyWeight',1);
        setParameter(0, '*|IVGTT|Application_1|ProtocolSchemaItem|Start time',1);
        setParameter(3, '*|IVGTT|Application_1|ProtocolSchemaItem|Infusion time',1);
        setParameter(1, '*|IVGTT|Application_1|ProtocolSchemaItem|Active',1);
    case 2
        %0.04 IU / kg bw insulin. Insulin Unit to mol conversion by
        %multiplying by 7e-9. Multuplying by the molecular weight of
        %insulin (5808 g/mol) yields the applied insulin amount in gram.
        %Further multiplied by 1e-3 to convert to kg, as standard MoBi unit
        %for mass is kg.
        setParameter(0.04 * 7e-9 * 5808 * 1e-3, '*|IVITT|Application_1|ProtocolSchemaItem|DosePerBodyWeight',1);
        setParameter(3, '*|IVITT|Application_1|ProtocolSchemaItem|Infusion time',1);
        setParameter(0, '*|IVITT|Application_1|ProtocolSchemaItem|Start time',1);
        setParameter(1, '*|IVITT|Application_1|ProtocolSchemaItem|Active',1);
    case 3
        %0.25 mIU/kg bw/min insulin infusion.
        infTime = 1440;
        setParameter(0.25 * 7e-9 * 5808 * infTime * 1e-6,'*|CIVII|Application_1|ProtocolSchemaItem|DosePerBodyWeight',1);
        setParameter(infTime,'*|CIVII|Application_1|ProtocolSchemaItem|Infusion time',1);
        setParameter(20,'*|CIVII|Application_1|ProtocolSchemaItem|Start time',1);
        setParameter(1,'*|CIVII|Application_1|ProtocolSchemaItem|Active',1);
    case 4
        %100 g oral glucose
        setParameter(100 / bw * 1e-3,'*|OGTT|MealD|Application_1|ProtocolSchemaItem|DosePerBodyWeight',1);
        setParameter(0,'*|OGTT|MealD|Application_1|ProtocolSchemaItem|Start time',1);
        setParameter(1,'*|OGTT|MealD|Application_1|ProtocolSchemaItem|Active',1);
        %Activate the meal effect so the gastric emptying time is adjusted
        %to the caloric content.
        setParameter(0,'*|Events|Meal Effect_1|Meal|Start time',1);
        energy = 100*3.87; %kcal
        energy = energy * 1E3 / 0.239; % J
        energy = energy * 100 * 60 * 60; % kg*dm^2 / min^2
        setParameter(energy,'*|Events|Meal Effect_1|Meal energy content',1);
        setParameter(0,'*|Events|Meal Effect_1|Meal fraction solid',1);
        setParameter(0.25,'*|Events|Meal Effect_1|Meal volume',1);
        setParameter(1,'*|Events|Meal Effect_1|Active',1);
    case 5
        %Exact infusion rates for the T1DM protocols were kindly provided by the
        %Medical University of Graz.
        setParameter(250/1e6,'*|Regittnig_G|Application_1|ProtocolSchemaItem|DosePerBodyWeight',1);
        setParameter(0,'*|Regittnig_G|Application_1|ProtocolSchemaItem|Start time',1);
        setParameter(1,'*|Regittnig_G|Application_1|ProtocolSchemaItem|Active',1);
        
        setParameter(0,'*|Regittnig_I_oR|Application_1|ProtocolSchemaItem|Active',1);
        setParameter(1,'*|Regittnig_I_mR|Infusion Protocol|Application_1|ProtocolSchemaItem|Active',1);
        setParameter(0,'*|Regittnig_I_mR|Infusion Protocol|Application_1|ProtocolSchemaItem|Start time',1);
    case 6
        setParameter(250/1e6,'*|Regittnig_G|Application_1|ProtocolSchemaItem|DosePerBodyWeight',1);
        setParameter(0,'*|Regittnig_G|Application_1|ProtocolSchemaItem|Start time',1);
        setParameter(1,'*|Regittnig_G|Application_1|ProtocolSchemaItem|Active',1);
        
    infTime = 1400;
    setParameter(0.00011062765*5808/1000*infTime/bw/1e6,'*|Regittnig_I_oR|Application_1|ProtocolSchemaItem|DosePerBodyWeight',1);
    setParameter(0,'*|Regittnig_I_oR|Application_1|ProtocolSchemaItem|Start time',1);
    setParameter(infTime,'*|Regittnig_I_oR|Application_1|ProtocolSchemaItem|Infusion time',1);
    setParameter(1,'*|Regittnig_I_oR|Application_1|ProtocolSchemaItem|Active',1);
end

function setSSInputs(bw, index)
setParameter(0,'*|OGTT|MealD|Application_1|ProtocolSchemaItem|Active',1);
setParameter(0, '*|Events|Meal Effect_1|Active', 1);

setParameter(0,'*|IVGTT|Application_1|ProtocolSchemaItem|Active',1);

setParameter(0,'*|IVITT|Application_1|ProtocolSchemaItem|Active',1);

setParameter(0,'*|CIVII|Application_1|ProtocolSchemaItem|Active',1);

setParameter(0,'*|Regittnig_I_oR|Application_1|ProtocolSchemaItem|Active',1);
setParameter(0,'*|Regittnig_G|Application_1|ProtocolSchemaItem|Active',1);
setParameter(0,'*|Regittnig_I_mR|Infusion Protocol|Application_1|ProtocolSchemaItem|Active',1);
%Exact infusion rates for the T1DM protocols were kindly provided by the
%Medical University of Graz.
if index == 5 || index == 6
    infTime = 3000;
    setParameter(0.00011062765*5808/1000*infTime/bw/1e6,'*|Regittnig_I_oR|Application_1|ProtocolSchemaItem|DosePerBodyWeight',1);
    setParameter(0,'*|Regittnig_I_oR|Application_1|ProtocolSchemaItem|Start time',1);
    setParameter(infTime,'*|Regittnig_I_oR|Application_1|ProtocolSchemaItem|Infusion time',1);
    setParameter(1,'*|Regittnig_I_oR|Application_1|ProtocolSchemaItem|Active',1);
end

function initStruct=initSimInputs(initStruct)
% Initialize parameters allowing to control applications.

initStruct = initParameter(initStruct,'*|IVGTT|Application_1|ProtocolSchemaItem|Active','always');
initStruct = initParameter(initStruct,'*|IVGTT|Application_1|ProtocolSchemaItem|Start time','always');
initStruct = initParameter(initStruct,'*|IVGTT|Application_1|ProtocolSchemaItem|Infusion time','always');
initStruct = initParameter(initStruct,'*|IVGTT|Application_1|ProtocolSchemaItem|DosePerBodyWeight','always');

initStruct = initParameter(initStruct,'*|IVITT|Application_1|ProtocolSchemaItem|Active','always');
initStruct = initParameter(initStruct,'*|IVITT|Application_1|ProtocolSchemaItem|Start time','always');
initStruct = initParameter(initStruct,'*|IVITT|Application_1|ProtocolSchemaItem|Infusion time','always');
initStruct = initParameter(initStruct,'*|IVITT|Application_1|ProtocolSchemaItem|DosePerBodyWeight','always');

initStruct = initParameter(initStruct,'*|CIVII|Application_1|ProtocolSchemaItem|Active','always');
initStruct = initParameter(initStruct,'*|CIVII|Application_1|ProtocolSchemaItem|Start time','always');
initStruct = initParameter(initStruct,'*|CIVII|Application_1|ProtocolSchemaItem|Infusion time','always');
initStruct = initParameter(initStruct,'*|CIVII|Application_1|ProtocolSchemaItem|DosePerBodyWeight','always');

initStruct = initParameter(initStruct,'*|OGTT|MealD|Application_1|ProtocolSchemaItem|Active','always');
initStruct = initParameter(initStruct,'*|OGTT|MealD|Application_1|ProtocolSchemaItem|Start time','always');
initStruct = initParameter(initStruct,'*|OGTT|MealD|Application_1|ProtocolSchemaItem|DosePerBodyWeight','always');

initStruct = initParameter(initStruct,'*|Events|Meal Effect_1|Meal|Start time','always');
initStruct = initParameter(initStruct,'*|Events|Meal Effect_1|Meal energy content','always');
initStruct = initParameter(initStruct,'*|Events|Meal Effect_1|Meal fraction solid','always');
initStruct = initParameter(initStruct,'*|Events|Meal Effect_1|Meal volume','always');
initStruct = initParameter(initStruct,'*|Events|Meal Effect_1|Active','always');

initStruct = initParameter(initStruct,'*|Regittnig_G|Application_1|ProtocolSchemaItem|Active','always');
initStruct = initParameter(initStruct,'*|Regittnig_G|Application_1|ProtocolSchemaItem|Start time','always');
initStruct = initParameter(initStruct,'*|Regittnig_G|Application_1|ProtocolSchemaItem|DosePerBodyWeight','always');

initStruct = initParameter(initStruct,'*|Regittnig_I_mR|Infusion Protocol|Application_1|ProtocolSchemaItem|Active','always');
initStruct = initParameter(initStruct,'*|Regittnig_I_mR|Infusion Protocol|Application_1|ProtocolSchemaItem|Start time','always');

initStruct = initParameter(initStruct,'*|Regittnig_I_oR|Application_1|ProtocolSchemaItem|Active','always');
initStruct = initParameter(initStruct,'*|Regittnig_I_oR|Application_1|ProtocolSchemaItem|DosePerBodyWeight','always');
initStruct = initParameter(initStruct,'*|Regittnig_I_oR|Application_1|ProtocolSchemaItem|Infusion time','always');
initStruct = initParameter(initStruct,'*|Regittnig_I_oR|Application_1|ProtocolSchemaItem|Start time','always');