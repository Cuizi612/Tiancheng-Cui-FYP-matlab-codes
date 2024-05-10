filepaths={};

ptt_array = zeros(1, length(filepaths));

for i = 1:length(filepaths)
    ptt_array(i) = CalculatePTT2(filepaths{i});
end