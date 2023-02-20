% Used Types are
%     'ENVIRONMENTAL MONITORING STATUTORY (EU DIRECTIVES)'
%    'IPPC/IPC MONITORING (AGENCY INVESTIGATION)'
%    'IPPC/IPC MONITORING (FORMAL SAMPLE)'
%    'MONITORING  (NATIONAL AGENCY POLICY)'
%    'MONITORING  (UK GOVT POLICY - NOT GQA OR RE)'
% For determinant 135 in RIVERS

warning off
UniqueRiverLocations = unique(WimsDataRiver.SamplingPoint);
for i =1:length(UniqueRiverLocations)
  idx = find(strcmp(WimsDataRiver.SamplingPoint, UniqueRiverLocations(i)));
  AverageRiverPoints(i,1:12) = WimsDataRiver(idx(1),1:12); %#ok<SAGROW>
  AverageRiverPoints.Median(i) = nanmedian(WimsDataRiver.DeterminandValue(idx));
  AverageRiverPoints.Uncertainty(i) = nanstd(WimsDataRiver.DeterminandValue(idx))/(nanmedian(WimsDataRiver.DeterminandValue(idx)));
  AverageRiverPoints.NrSamples(i) = length(idx);
  for j = 1:length(idx)
      Test_Date = char(WimsDataRiver.Date(idx(j)));
      Year_array(j) = str2num(Test_Date(1:4));  %#ok<ST2NM,SAGROW>
  end
  AverageRiverPoints.NrYears(i) = length(unique(Year_array));
  clear idx Year_array
end