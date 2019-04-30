
function visupars = readvisu_pars(pathname)

if(~exist('pathname', 'var'))
    pathname = '.';
end

param = fopen([pathname,'/visu_pars'],'rb');
if param == -1, error('define the pathname'), end

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

    if(strcmp(hdr{index,1}, 'VisuCoreFrameCount'))
        visupars.frame = str2double(hdr{index,2});
    end
    if(strcmp(hdr{index,1}, 'VisuCoreDim'))
        visupars.dim = str2double(hdr{index,2});
    end
    if(strcmp(hdr{index,1}, 'VisuCoreSize'))
        visupars.size = str2num(hdr{index+1,1});
    end
    if(strcmp(hdr{index,1}, 'VisuCoreDimDesc'))
        visupars.dimdesc = hdr{index+1,1};
    end
    if(strcmp(hdr{index,1}, 'VisuCoreExtent'))
        visupars.extent = str2num(hdr{index+1,1});
    end
    if(strcmp(hdr{index,1}, 'VisuCoreFrameThickness'))
        visupars.thickness = str2double(hdr{index+1,1});
    end
    if(strcmp(hdr{index,1}, 'VisuCoreUnits'))
        visupars.units = hdr{index+1,1};
    end
%     if(strcmp(hdr{index,1}, 'VisuCoreOrientation'))
%         temp1 = hdr{index,2};
%         temp2 = strfind(temp1,',');
%         visupars.slice = str2double(temp1(2:temp2-1));    
%     end
    if(strcmp(hdr{index,1}, 'VisuCoreOrientation'))
        temp1 = (hdr{index,2});
        temp2 = strfind(temp1,',');
        visupars.slice = str2double(temp1(2:temp2-1)); 
    end
    if(strcmp(hdr{index,1}, 'VisuCoreOrientation'))
        temp1 = (hdr{index,2});
        temp2 = strfind(temp1,',');
        visupars.orientation = str2double(temp1(2:temp2-1)); 
    end    
    if(strcmp(hdr{index,1}, 'VisuCoreWordType'))
        visupars.type = hdr{index,2};
    end
    if(strcmp(hdr{index,1}, 'VisuAcqRepetitionTime'))
        visupars.TR = hdr{index+1,1};
    end
    if(strcmp(hdr{index,1}, 'VisuAcqEchoTime'))
        visupars.Necho = str2num(hdr{index,2});
    end
end

for index = 1:size(hdr,1),
    if(strcmp(hdr{index,1}, 'VisuCoreDataSlope'))
        visupars.dataslope = [];
        index1 = index+1;
        while(length(visupars.dataslope) < visupars.frame)
            visupars.dataslope = [visupars.dataslope, str2num(hdr{index1,1})];
            index1 = index1+1;
        end
    end
end

return;