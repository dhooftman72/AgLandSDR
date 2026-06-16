function [Data,list_of_stations] = ExtractPlotValuesInVest(outfile)
warning off %#ok<WNOFF>

% NO hectarefactor anymore. The data are per hectare, so they need to be
% multiplied with the number of hectares. NOT including the factor 4 that
% makes up a hectare from 50 x 50 meter cellls.

% collect names
current = pwd;
cd('C:\DannyData\Temp\Extractions')
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
    %Note the outputs are per pixel of 50 x 50 meters, extracted per 10 x
    %10. 
    % So two calcuation options. Sum dvided by 25 (50/10)^2 or pixels per
    % hectare = 4 [((100/50)^2] times total hectares. Here the second is used
        if isempty(data) ~= 1
            Data.Count(x,1) = data.COUNT;
            Data.Area(x,1) = data.AREA;
            Data.Mean(x,1) = data.MEAN;
            Data.Maximum(x,1) = data.MAX;
            Data.Median(x,1) = data.MEDIAN;
            Data.Sum(x,1) = data.SUM;
            Data.SizeWatershed(x,1) = data.Size_ha;
            Data.NFRA_ID(x,1) = data.NEAR_FID;        
            Data.NrPixels(x,1) = ((100/50)^2).* Data.SizeWatershed(x,1);
            Data.(genvarname(char(Naming)))(x,1) = (Data.Mean(x,1) * Data.NrPixels(x,1)); 
        else
            Data.Count(x,1) = NaN;
            Data.Area(x,1) = NaN;
            Data.Mean(x,1) = NaN;
            Data.Maximum(x,1) = NaN;
            Data.Median(x,1) = NaN;
            Data.Sum(x,1) = NaN;
            Data.SizeWatershed(x,1) = NaN;
            Data.NFRA_ID(x,1) = NaN;
            Data.NrPixels(x,1) = NaN;
            Data.(genvarname(char(Naming)))(x,1) = NaN;
        end
    clear data
end
cd(current);
Data = sortrows(Data,'DH_ID');
save(outfile,'Data','list_of_stations')