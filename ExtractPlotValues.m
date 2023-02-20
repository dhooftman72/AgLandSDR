function [Data,list_of_stations] = ExtractPlotValues(outfile)
warning off %#ok<WNOFF>

% collect names
current = pwd;
cd('c:\Temp')
%outfile = 'GEAR_Full_USLE';
LengthHeading = length(outfile);

list = dir;
length_names = length(list);
count = 1;
fprintf('Looping through %i files of %i \n', length_names)
for x = 1:1:length_names
    name_list_temp = cellstr(list(x,1).name);
    if strcmp(name_list_temp, '.') ~= 1 && strcmp(name_list_temp, '..') ~= 1
        b = char(name_list_temp);
        c = {b(length(b)-2:length(b))};
        if length(b) <  (3+(LengthHeading)+2)
            TF2 = 0;
            TF = 0;
        else
            d = {b(1:LengthHeading)};
            TF = strcmp(c,'csv');
            TF2 = strcmp(d,outfile);
            if TF == 1
                if TF2 == 1
                    list_of_stations(count,1) =  name_list_temp; %#ok<*AGROW>
                    count = count + 1;
                end
            end
        end
    end
end
clear x
clear  name_list_temp

display('Extracting data')
total_stations = length(list_of_stations);
Data = dataset(NaN,'Varnames','DH_ID');
for x = 1:1:total_stations
        % show progrees in screen
         if x/10 == floor(x/10)
         clc
         fprintf('number of cells: %i out of %i \n', x, total_stations)
         end
    name = char(list_of_stations(x));
    data = dataset('file',name,'delimiter',',','ReadObsNames',false);
    Naming = [outfile,'_SedExportTotal']; 
    Data.DH_ID(x,1) = data.DH_ID;
        if isempty(data) ~= 1
            Data.Count(x,1) = data.COUNT;
            Data.Area(x,1) = data.AREA;
            Data.Mean(x,1) = data.MEAN;
            Data.Maximum(x,1) = data.MAX;
            Data.Median(x,1) = data.MEDIAN;
            Data.Sum(x,1) = data.SUM;
            Data.SizeWatershed(x,1) = data.Size_ha;
            Data.MeanFlow(x,1) = data.gdf_mean_f; 
            Data.TotalFlow(x,1) = Data.MeanFlow(x,1).*31556926; % from M3 per second to m3 per year
            Data.NFRA_ID(x,1) = data.NEAR_FID;
            Data.SedimentMedian(x,1) = data.F_Median_;
            Data.SedimentUncertainty(x,1) = data.F_Uncertai;
            Data.SedimentSamples(x,1) = data.F_NrSample;
            Data.SedimentYears(x,1) = data.NrYears;                   
            Data.(genvarname(char(Naming)))(x,1) = (Data.Mean(x,1) * Data.SizeWatershed(x,1))*4; % recalculated based on per hectare instead of 50x50 meters
            Data.WimsYear(x,1) = ((Data.TotalFlow(x,1)*1000) * Data.SedimentMedian(x,1))/(10^9); % ((m3 to liter)* mg/l)/to tons from mg (10^9)
        else
            Data.Count(x,1) = NaN;
            Data.Area(x,1) = NaN;
            Data.Mean(x,1) = NaN;
            Data.Maximum(x,1) = NaN;
            Data.Median(x,1) = NaN;
            Data.Sum(x,1) = NaN;
            Data.SizeWatershed(x,1) = NaN;
            Data.MeanFlow(x,1) = NaN;
            Data.TotalFlow(x,1) = NaN;
            Data.NFRA_ID(x,1) = NaN;
            Data.SedimentMedian(x,1) = NaN;
            Data.SedimentUncertainty(x,1) = NaN;
            Data.SedimentSamples(x,1) = NaN;
            Data.SedimentYears(x,1) = NaN;
            Data.(genvarname(char(Naming)))(x,1) = NaN;
            Data.WimsYear(x,1) = NaN;
        end
    clear data
end
cd(current);
Data = sortrows(Data,'DH_ID');
save(outfile,'Data','list_of_stations')