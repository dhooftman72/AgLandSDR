function [Statistics, Points] = SDRUKValidation(CombinedExportData)

Test = get(CombinedExportData);
Names = cellstr(Test.VarNames(7:23));
Statistics = dataset(zeros(17,1),'ObsNames',Names,'varnames',{'InverseDeviance'});
Points.Winsor = dataset(CombinedExportData.DH_ID,'varnames',{'DH_ID'});
Points.Deviance = Points.Winsor;
Points.NonWinsor = Points.Winsor;
Points.NonWinsorNonLog = Points.Winsor;
Points.Order = Points.Winsor;

Winsorprop = 5; % 5% proportion winsorisation

% Validation data
Hectares = double(CombinedExportData(:,2));
InVar = double(CombinedExportData(:,6))./(Hectares/100); %#ok<*NODEF>
Points.NonWinsorNonLog.WimsValidation = InVar;
InVar = log10(InVar+1);
Points.NonWinsor.WimsValidation = InVar;
[TestArray(:,1)] = (WinsorFunction(((InVar)),Winsorprop));
clear InVar
Points.Winsor.WimsValidation = TestArray(:,1);
for i = 1:1:17
    InVar = double(CombinedExportData(:,(i+6)))./(Hectares/100); %#ok<*NODEF>
    Points.NonWinsorNonLog.(genvarname(char(Names(i)))) = InVar;
    InVar = log10(InVar+1);
    Points.NonWinsor.(genvarname(char(Names(i)))) = InVar;
    [TestArray(:,2)] = (WinsorFunction(((InVar)),Winsorprop));
    Points.Winsor.(genvarname(char(Names(i)))) = TestArray(:,2);
    
    [Outputs] = Accuracy_statistics_Validation(TestArray,i,Points);
    Statistics.InverseDeviance(i,1) = Outputs.mean_double_deviation;
    Statistics.Rho(i,1) = Outputs.RHO;
    Statistics.RhoPVal(i,1) = Outputs.PVAL;
    Statistics.CorrtoMain(i,1) = Outputs.PearsonvsMain;
    Points.Deviance.(genvarname(char(Names(i)))) = reshape(Outputs.deviation_point,[],1);
    Points.Order.(genvarname(char(Names(i)))) = Outputs.Order;
    clear InVar
end
display('running randoms')
parfor x = 1:1000
    TestAr = TestArray(:,1); 
    InVar = double(CombinedExportData(:,(7)))./(Hectares/100); %#ok<*PFBNS,*NODEF>
    InVar = log10(InVar+1);
    PermList = randperm(178);
    InVar = InVar(PermList);
    [TestAr(:,2)] = (WinsorFunction(((InVar)),Winsorprop));
    [Outputs] = Accuracy_statistics_Validation(TestAr,18,Points);
    InverseDeviance(x,1) = Outputs.mean_double_deviation; %#ok<*AGROW>
    Rho(x,1) = Outputs.RHO;
    RhoPVal(x,1) = Outputs.PVAL;
end
Statistics.InverseDeviance('Random',1) = nanmean(InverseDeviance);
Statistics.Rho('Random',1) = nanmean(Rho);
Statistics.RhoPVal('Random',1) = nanmean(RhoPVal);
end

function [Outputs] = Accuracy_statistics_Validation(testArray,Nr,Points)
% clean data set to determine true N and where top put NaN;
testArray(isinf(testArray)==1) = NaN;
[testArray]  = CleanOutNaN(testArray);

% Make log if applicable, but not for Ensembles
testVar = testArray;
Outputs = CorrFunc(testVar,Nr,Points);
end

function  Outputs = CorrFunc(testSet,Nr,Points)
    Precision = 1./(0.00001);
    c1=find((isnan(testSet(:,1))==1));
    d=find((isnan(testSet(:,2))==1));
    alL = [c1;d];
    A(:,1) = unique(alL);
    testSet(A,:) = [];  %#ok<*FNDSB>
    Datapoint = size(testSet,1);
    [Outs.RHO,Outs.PVAL] = corr(testSet(:,1),testSet(:,2),'type','Spearman');
    for i = 1:2
        [~,p] = sort(testSet(:,i),'ascend');
        r = 1:length(testSet(:,i));
        r(:,p) = r;
        Outputs.Order(:,i) = r;
    end
    if Nr ~= 1
        Outputs.PearsonvsMain = corr(Points.Order.PeriodicModel(:,2), Outputs.Order(:,2),'type','Pearson');   
    else 
        Outputs.PearsonvsMain = 1;
    end
    Outputs.PVAL = single(Outs.PVAL);
    Outputs.RHO = (round(Outs.RHO.*Precision))./Precision;
    % Inverse deviance against a 1:1 line
    clear x_range y_range
    x_range = testSet(:,1);
    y_range = testSet(:,2);
    Deviation_point = abs(y_range-x_range);
    Outputs.deviation_point= Deviation_point; %% Accuracy per point
    Outputs.mean_double_deviation = 1- (nansum(Deviation_point)/Datapoint); %%Accuracy overall
    Outputs.mean_double_deviation = (round( Outputs.mean_double_deviation.*Precision))./Precision;
end

function [ArrayOut] = CleanOutNaN(ArrayIn)
OutVarOrg = 1:1:length(ArrayIn(:,1));
OutVarOrg = OutVarOrg';
a1=find((isnan(ArrayIn(:,1))==1));
b=find((isnan(ArrayIn(:,2))==1));
all = [a1;b];
a(:,1) = unique(all);
ArrayOut = ArrayIn;
ArrayOut(a,:) = [];  
end

function  [OutVar] = WinsorFunction(InVar,percLow)
InVar = reshape(InVar,((size(InVar,1)).*(size(InVar,2))),1);
InVar(InVar<0) = NaN;
prct =  prctile(InVar,percLow);
if prct < 0
    display('zero Values present; correct this first')
    cccc
end
InVar_norm = InVar - prct;
clear InVar
InVar_norm( InVar_norm<0) = 0;
prct(2) = prctile(InVar_norm,(100-percLow));
if exist('InVar_org') == 1 %#ok<EXIST>
    InVar_norm = InVar_org;
end
OutVar = (InVar_norm./prct(2));
OutVar = OutVar + 0.01;
clear InVar_norm InVar_org testlist testtmp upboud
OutVar(OutVar>1) = 1;
end
