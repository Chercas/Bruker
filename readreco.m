function reco = readreco(pathname)

if(~exist('pathname', 'var'))
    pathname = '.';
end

param = fopen([pathname,'/reco'],'rb');
if param == -1, error('File Read Error'), end

% read the acqp file line-by-line
tline = fgetl(param);
index = 1;
param_index = [];
while ischar(tline)
    temp = strfind(tline,'=');      % some parameters are written after '='
     
    if isempty(temp) == 1           % if parameter is written below the '=' line
        hdr{index,1} = tline;           % text is stored in column 1 only
        hdr{index,2} = [];
    else
        hdr{index,1} = tline(4:temp-1);     % a cell structure hdr is called to store
        hdr{index,2} = tline(temp+1:end);   % text before '=' in column 1 and after '=' in column 2
        param_index = [param_index,index];
    end
    
    index = index+1;
    tline = fgetl(param);
end
param_index = [param_index,index];
fclose(param);

for index = 1:size(hdr,1),

    if(strcmp(hdr{index,1}, 'RECO_size'))
       reco.size = str2num(hdr{index+1,1});
    end
    if(strcmp(hdr{index,1}, 'RECO_fov'))
        reco.FOV = str2num(hdr{index+1,1});
    end
    if(strcmp(hdr{index,1}, 'RECO_wordtype'))
        reco.type = hdr{index,2};
    end
    if(strcmp(hdr{index,1}, 'RECO_pc_lin'))
        reco.pclin = hdr{index+1,1};
    end
end

for index = 1:size(hdr,1),

    if(strcmp(hdr{index,1}, 'RECO_size'))
       reco.size = str2num(hdr{index+1,1});
    end
    if(strcmp(hdr{index,1}, 'RECO_fov'))
        reco.FOV = str2num(hdr{index+1,1});
    end
    if(strcmp(hdr{index,1}, 'RECO_wordtype'))
        reco.type = hdr{index,2};
    end
    if(strcmp(hdr{index,1}, 'RECO_rotate'))
        eindex = param_index(find(param_index>index,1,'first'));
        reco.rotate = [];
        for index1 = index+1:eindex-1,
            reco.rotate = [reco.rotate, str2num(hdr{index1,1})];
        end
        reco.rotate = reshape(reco.rotate,length(reco.rotate)/length(reco.size),length(reco.size));
    end
    if(strcmp(hdr{index,1}, 'RECO_pc_lin'))
        reco.pclin = hdr{index+1,1};
    end
    if(strcmp(hdr{index,1}, 'RecoNumRepetitions'))
        reco.nr = hdr{index,2};
    end
end