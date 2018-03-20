%VARIABLES
startValue = strings;
intStartValue = [];
stopValue = strings;
intStopValue = [];
tdcValue = strings;
intTdcValue = [];

measureDataFilePath = '.\TDC_FIFO_700kHz_10000Measures.txt';
measureDataFile = fopen(measureDataFilePath);

%PASS AND PROCESS DATA FROM FILE TO VARIABLE
delimiterIn = '\n';
headerlinesIn = 0;

data = textscan(measureDataFile, '%s', 'delimiter', delimiterIn);
data = data{1};

strDelimiter = '; ';
aux = strings(1,2);

j=1;
for i = 2:4:size(data,1)
    startValue(j) = data(i);
    aux(j,:) = strsplit(startValue(j), strDelimiter);
    startValue(j) = aux(j,2);
    intStartValue(j) = str2num(char(startValue(j)));
    j = j + 1;
end


j=1;
for i = 3:4:size(data,1)
    stopValue(j) = data(i);
    aux(j,:) = strsplit(stopValue(j), strDelimiter);
    stopValue(j) = aux(j,2);
    intStopValue(j) = str2num(char(stopValue(j)));
    j = j + 1;
end

j=1;
for i = 4:4:size(data,1)
    tdcValue(j) = data(i);
    aux(j,:) = strsplit(tdcValue(j), strDelimiter);
    tdcValue(j) = aux(j,2);
    intTdcValue(j) = str2num(char(tdcValue(j)));
    j = j + 1;
end
%END OF PASS AND PROCESS DATA FROM FILE TO VARIABLE

%DENSITY CODE TEST
startDensityCodeVector = [];
stopDensityCodeVector = [];

for i=1:300 %number of delay line cells
    cnt = 0;
    for j=1:size(intStartValue,2)
        if intStartValue(j) == i-1
            cnt = cnt + 1;
        end
    end
    startDensityCodeVector(i) = cnt;
end

for i=1:300 %number of delay line cells
    cnt = 0;
    for j=1:size(intStopValue,2)
        if intStopValue(j) == i-1
            cnt = cnt + 1;
        end
    end
    stopDensityCodeVector(i) = cnt;
end
%END OF DENSITY CODE TEST


%HISTOGRAM PLOT
x = 0:300-1;
figure('Name', 'Start Bin Size Histogram');
bar(x,startDensityCodeVector);
xlabel('Bin Number');
ylabel('Number of Hits');
xlim([-1 280])

figure ('Name', 'Stop Bin Size Histogram');
bar(x,stopDensityCodeVector);
xlabel('Bin Number');
ylabel('Number of Hits');
xlim([-1 280])
%END OF HISTOGRAM PLOT


%DNL CALCULATION
period = 5000; %system clock period in picoseconds
numberOfSamples = 10000; %number of samples colected
binSize = period/numberOfSamples;
startDNL = [];
stopDNL = [];
startDNLLSB = [];
stopDNLLSB = [];

for i=1:size(startDensityCodeVector,2)
    startDNL(i) = startDensityCodeVector(i)* binSize - 17.9;
    startDNLLSB(i) = startDNL(i)/17.9;
end

for i=1:size(stopDensityCodeVector,2)
    stopDNL(i) = stopDensityCodeVector(i)* binSize - 17.9;
    stopDNLLSB(i) = stopDNL(i)/17.9;
end
%END OF DNL CALCULATION


%INL CALCULATION
startINL = [];
stopINL = [];
startINLLSB = [];
stopINLLSB = [];

accumulatedDNL = 0;
for i=1:size(startDNL,2)
    accumulatedDNL = accumulatedDNL + startDNL(i);
    startINL(i) = 17.9*i - accumulatedDNL;
    startINLLSB(i) = startINL(i)/17.9;
end

accumulatedDNL = 0;
for i=1:size(stopDNL,2)
    accumulatedDNL = accumulatedDNL + stopDNL(i);
    stopINL(i) = 17.9*i - accumulatedDNL;
    stopINLLSB(i) = stopINL(i)/17.9;
end
%END OF INL CALCULATION

%INL FITTING
%linearFit = 1.04*x - 10.2;
residues = [];
for i=1:size(stopINLLSB,2)
    residues(i) = 1.04*i - 10.2 - startINLLSB(i);
end
%END OF INL FITTING

%DNL AND INL PLOTING
figure('Name', 'Start DNL')
bar(x,startDNLLSB)
xlabel('Bin Number')
ylabel('LSB')
xlim([-1 280])

figure('Name', 'Stop DNL')
bar(x,stopDNLLSB)
xlabel('Bin Number')
ylabel('LSB')
xlim([-1 280])

figure('Name', 'Start INL')
bar(x(1:280),startINLLSB(1:280))
xlabel('Bin Number')
ylabel('LSB')
xlim([-1 280])

figure('Name', 'Stop INL')
bar(x(1:280),stopINLLSB(1:280))
xlabel('Bin Number')
ylabel('LSB')
xlim([-1 280])
%END OF DNL AND INL PLOTING


%PLOT TDC VALUES GRAPH
figure('Name', 'TDC Measures')
plot(intTdcValue)
xlabel('Measure')
ylabel('Time (ps)')
%END OF PLOT TDC VALUES GRAPH

%CLOSE FILES AND COMMUNICATIONS
fclose(measureDataFile);
%END OF CLOSE FILES AND COMMUNICATIONS