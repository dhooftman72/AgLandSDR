function [Statistics, Points] = SDRUKValidation(CombinedExportData)

Test = get(CombinedExportData);
Names = cellstr(Test.VarNames(4:23));
Statistics = dataset(zeros(20,1),'ObsNames',Names,'varnames',{'InverseDeviance'});
Points.Winsor = dataset(0,'varnames',{'WimsValidation'});
Points.Deviance = dataset(0,'varnames',{(char(Names(1)))});
Points.NonWinsor = dataset(0,'varnames',{'WimsValidation'});

% Validation data
InVar = double(CombinedExportData(:,3))./double(CombinedExportData(:,2)); %#ok<*NODEF>
Points.NonWinsor.WimsValidation = InVar;
[TestArray(:,1)] = (WinsorFunction(((InVar)),2.5));
Points.Winsor.WimsValidation = TestArray(:,1);
for i = 1:1:20
    InVar = double(CombinedExportData(:,(i+3)))./double(CombinedExportData(:,2)); %#ok<*NODEF>
    [TestArray(:,2)] = (WinsorFunction(((InVar)),2.5));
    [Outputs] = Accuracy_statistics_Validation(TestArray);
    Statistics.InverseDeviance(i,1) = Outputs.mean_double_deviation;
    Statistics.Rho(i,1) = Outputs.RHO;
    Statistics.RhoPVal(i,1) = Outputs.PVAL;
    Points.NonWinsor.(genvarname(char(Names(i)))) = InVar;
    Points.Winsor.(genvarname(char(Names(i)))) = TestArray(:,2);
    Points.Deviance.(genvarname(char(Names(i)))) = reshape(Outputs.deviation_point,[],1);
end


function [Outputs] = Accuracy_statistics_Validation(testArray)
% clean data set to determine true N and where top put NaN;
testArray(isinf(testArray)==1) = NaN;
[testArray]  = CleanOutNaN(testArray);

%% Make log if applicable, but not for Ensembles
testVar = testArray;
Outputs = CorrFunc(testVar);

end

function  Outputs = CorrFunc(testSet)
    Precision = 1./(0.00001);
    c1=find((isnan(testSet(:,1))==1));
    d=find((isnan(testSet(:,2))==1));
    alL = [c1;d];
    A(:,1) = unique(alL);
    testSet(A,:) = [];  %#ok<*FNDSB>
    Datapoint = size(testSet,1);
    [Outs.RHO,Outs.PVAL] = corr(testSet(:,1),testSet(:,2),'type','Spearman');
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
if exist('InVar_org') == 1; %#ok<EXIST>
    InVar_norm = InVar_org;
end
OutVar = (InVar_norm./prct(2));
clear InVar_norm InVar_org testlist testtmp upboud
OutVar(OutVar>1) = 1;
end
end
