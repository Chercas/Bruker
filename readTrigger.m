function [trigger, triggerPattern] = readTrigger(pathname)
if(~exist('pathname','var'))
    pathname = '.';
end

param = fopen([pathname,'/method'],'rb');
if(param == -1), error('File Read Error'), end;

tline = fgetl(param);

% read the acqp file line-by-line
tline = fgetl(param);
i = 1;

while ischar(tline)
    temp = strfind(tline,'=');      % some parameters are written after '='
    hdr{i,1} = tline(4:temp-1);     % a cell structure hdr is called to store
    hdr{i,2} = tline(temp+1:end);   % text before '=' in column 1 and after '=' in column 2
    
    if isempty(temp) == 1           % if parameter is written below the '=' line
        hdr{i,1} = tline;           % text is stored in column 1 only
        hdr{i,2} = [];
    end
    
    i = i+1;
    tline = fgetl(param);
end
fclose(param);

for index = 1:size(hdr,1),
    if(strcmp(hdr{index,1}, 'MyTrigSegments'))
        triggerPattern = hdr{index+1,:};
    end
end

if(~exist('triggerPattern'))
    triggerPattern=0;
else
    triggerPattern = str2num(triggerPattern);
end

trigger = [];
for index = 1:length(triggerPattern),
    trigger = [trigger;mod(index-1,2)*ones(triggerPattern(index),1)];
end