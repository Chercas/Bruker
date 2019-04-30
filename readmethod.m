function method = readmethod(pathname)
if(~exist('pathname', 'var'))
    pathname = '.';
end
    
param = fopen([pathname,'/method'],'rb');
if param == -1, error('File Read Error'), end

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
    if(strcmp(hdr{index,1}, 'PVM_EchoTime'))
       method.TE = str2num(hdr{index,2});
    end
    if(strcmp(hdr{index,1}, 'PVM_RepetitionTime'))
       method.TR = str2num(hdr{index,2});
    end
    if(strcmp(hdr{index,1}, 'PVM_EpiPrefixNavSize'))
       method.numNav = str2num(hdr{index,2});
    end
    if(strcmp(hdr{index,1}, 'PVM_Fov'))
       method.FOV = str2num(hdr{index+1,1});
    end
    if(strcmp(hdr{index,1}, 'PVM_Matrix'))
       method.imSize = str2num(hdr{index+1,1});
    end
    if(strcmp(hdr{index,1}, 'PVM_EncMatrix'))
       method.kSize = str2num(hdr{index+1,1});
    end
    if(strcmp(hdr{index,1}, 'PVM_SPackArrNSlices'))
       method.NSlices = str2num(hdr{index+1,1});
    end
    if(strcmp(hdr{index,1}, 'BSoffsetFreq'))
       method.BSoffsetFreq = str2num(hdr{index+1,1});
    end
    if(strcmp(hdr{index,1}, 'B1max'))
       method.B1max = str2num(hdr{index,2});
    end
    if(strcmp(hdr{index,1}, 'PVM_RefPowCh1'))
       method.RefPower = str2num(hdr{index,2});
    end
    if(strcmp(hdr{index,1}, 'BSPulse'))
       method.RefPower = str2num(hdr{index,2});
    end
    if(strcmp(hdr{index,1}, 'PVM_EncPft'))
       method.PFT = str2num(hdr{index+1,1});
    end
    
    if(strcmp(hdr{index,1}, 'PVM_EncSteps1'))
        method.kOrder = [];
        index1 = index+1;
        while(length(method.kOrder) < method.kSize(2))
            method.kOrder = [method.kOrder, str2num(hdr{index1,1})];
            index1 = index1+1;
        end
    end
    if(strcmp(hdr{index,1}, 'MultiRepTime'))
        method.VTR = str2num(hdr{index+1,1});
    end
    if(strcmp(hdr{index,1}, 'PVM_SliceThick'))
       method.sliceThickness = str2num(hdr{index,2});
    end
    if(strcmp(hdr{index,1}, 'PVM_EffSWh'))
       method.EffSWh = str2num(hdr{index,2});
    end
    if(strcmp(hdr{index,1}, 'PVM_EpiAcqDelayTrim'))
        method.epi_trim = str2num(hdr{index,2});
    end
    if(strcmp(hdr{index,1}, 'PVM_EpiBlipAsym'))
        method.epi_asym = str2num(hdr{index,2});
    end
    
    if(strcmp(hdr{index,1}, 'PVM_EpiTrajAdjkx'))
        method.kxLength = str2num(hdr{index,2});
        method.kx = [];
        index1 = index+1;
        while(length(method.kx) < method.kxLength)
            method.kx = [method.kx, str2num(hdr{index1,1})];
            index1 = index1+1;
        end
    end
    
    if(strcmp(hdr{index,1}, 'PVM_EpiPhaseCorrection'))
%         hdr{index,2}
        method.pclength = 2;
        method.pc = [];
        index1 = index+1;
        while(length(method.pc) < method.pclength)
            method.pc = [method.pc, str2num(hdr{index1,1})];
            index1 = index1+1;
        end
    end
    
    if(strcmp(hdr{index,1}, 'PVM_EpiTrajAdjb0'))
        method.b0Length = str2num(hdr{index,2});
        method.b0 = [];
        index1 = index+1;
        while(length(method.b0) < method.b0Length)
            method.b0 = [method.b0, str2num(hdr{index1,1})];
            index1 = index1+1;
        end
    end
    
    if(strcmp(hdr{index,1}, 'PVM_EncValues2'))
        method.EncValues2Size = str2num(hdr{index,2});
        method.EncValues2 = [];
        index1 = index+1;
        while(length(method.EncValues2) < method.EncValues2Size)
            method.EncValues2 = [method.EncValues2, str2num(hdr{index1,1})];
            index1 = index1+1;
        end
    end
    if(strcmp(hdr{index,1},'PVM_SPackArrSliceOrient'))
        method.SliceOrient = hdr{index+1,1};
    end
    if(strcmp(hdr{index,1},'PVM_SPackArrReadOrient'))
        method.ReadOrient = hdr{index+1,1};
    end
    if(strcmp(hdr{index,1}, 'Red_Factor'))
        method.Rfactor = str2num(hdr{index,2});
    end 
    if(strcmp(hdr{index,1},'NSegments'))
        method.NSegments = str2num(hdr{index,2});
    end
    if(strcmp(hdr{index,1},'PVM_NRepetitions'))
        method.NRepetition = str2num(hdr{index,2});
    end
    
    if(strcmp(hdr{index,1}, 'Gradp2'))
        method.Gradp2Size = str2num(hdr{index,2});
        method.Gradp2= [];
        index1 = index+1;
        while(length(method.Gradp2) < method.Gradp2Size)
            method.Gradp2 = [method.Gradp2, str2num(hdr{index1,1})];
            index1 = index1+1;
        end
    end
    
    if(strcmp(hdr{index,1}, 'PVM_TrajKx'))
        method.TrajKxSize = str2num(hdr{index,2});
        method.TrajKx= [];
        index1 = index+1;
        while(length(method.TrajKx) < method.TrajKxSize)
            method.TrajKx = [method.TrajKx, str2num(hdr{index1,1})];
            index1 = index1+1;
        end
    end
    
    if(strcmp(hdr{index,1}, 'PVM_TrajKy'))
        method.TrajKySize = str2num(hdr{index,2});
        method.TrajKy= [];
        index1 = index+1;
        while(length(method.TrajKy) < method.TrajKySize)
            method.TrajKy = [method.TrajKy, str2num(hdr{index1,1})];
            index1 = index1+1;
        end
    end
end