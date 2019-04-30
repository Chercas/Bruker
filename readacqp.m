function acq = readacqp(pathname)
if(~exist('pathname', 'var'))
    pathname = '.';
end
    
param = fopen([pathname,'/acqp'],'rb');
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

acq.nRX = 1;
for index = 1:size(hdr,1),
    if(strcmp(hdr{index,1},'ACQ_dim'))
        acq.dim = str2num(hdr{index,2});
    end
    if(strcmp(hdr{index,1},'ACQ_fov'))
        acq.fov = str2num(hdr{index+1,1});
    end
    if(strcmp(hdr{index,1},'NSLICES'))
        acq.nSlice = str2num(hdr{index,2});
    end
    if(strcmp(hdr{index,1},'ACQ_ReceiverSelect'))
        acq.nRX = str2num(hdr{index,2});
    end
    if(strcmp(hdr{index,1},'ACQ_Routing_base'))
        acq.base = str2num(hdr{index,2});
    end
    if(strcmp(hdr{index,1},'ACQ_size'))
        acq.size = str2num(hdr{index+1,1});
    end
    if(strcmp(hdr{index,1},'NI'))
        acq.NI = str2num(hdr{index,2});
    end
    if(strcmp(hdr{index,1},'NR'))
        acq.NR = str2num(hdr{index,2});
    end
    if(strcmp(hdr{index,1},'ACQ_n_echo_images'))
        acq.Necho = str2num(hdr{index,2});
    end
    if(strcmp(hdr{index,1},'BYTORDA'))
        acq.byteordering = hdr{index,2};
    end
    if(strcmp(hdr{index,1},'ACQ_word_size'))
        acq.wordsize = hdr{index,2};
    end
    if(strcmp(hdr{index,1},'ACQ_scan_size'))
        acq.scansize = hdr{index,2};
    end
    if(strcmp(hdr{index,1},'ACQ_scan_shift'))
        acq.scanshift = str2num(hdr{index,2});
    end
    if(strcmp(hdr{index,1},'ACQ_phase_factor'))
        acq.phasefactor = str2num(hdr{index,2});
    end
    
    if(strcmp(hdr{index,1},'ACQ_rare_factor'))
        acq.rarefactor = str2num(hdr{index,2});
    end
    if(strcmp(hdr{index,1},'ACQ_phase_encoding_mode'))
        acq.phaseencodingmode = hdr{index+1,1};
    end
    if(strcmp(hdr{index,1},'ACQ_phase_enc_start'))
        acq.phaseencostart = str2num(hdr{index+1,1});
    end
    if(strcmp(hdr{index,1},'ACQ_spatial_size_1'))
        acq.spatialsize1 = str2num(hdr{index,2});
    end
    if(strcmp(hdr{index,1},'ACQ_spatial_size_2'))
        acq.spatialsize2 = str2num(hdr{index,2});
    end
   
  
    if(strcmp(hdr{index,1},'DSPFIRM'))
        acq.dspfirm = hdr{index,2};
    end
    if(strcmp(hdr{index,1},'DECIM'))
        acq.decim = str2num(hdr{index,2});
    end
    if(strcmp(hdr{index,1},'DSPFVS'))
        acq.dspfvs = str2num(hdr{index,2});
    end
    if(strcmp(hdr{index,1},'SW_h'))
        acq.bandwidth = str2num(hdr{index,2});
    end
    if(strcmp(hdr{index,1},'BF1'))
        acq.LarmorFreq = str2num(hdr{index,2});
    end
    if(strcmp(hdr{index,1},'GRPDLY')==1)
        acq.Dly = str2num(hdr{index,2});      % delay of fid processing
        acq.Dly = round(acq.Dly)+1;     % need to debug
    end
    if(strcmp(hdr{index,1},'GO_block_size')==1)
        acq.GO_block_size = hdr{index,2};
    end
end


for index = 1:size(hdr,1),
    if(strcmp(hdr{index,1},'ACQ_spatial_phase_1'))
        acq.spatialphase1 = [];
        index1 = index+1;
        while(length(acq.spatialphase1) < acq.spatialsize1)
            acq.spatialphase1 = [acq.spatialphase1, str2num(hdr{index1,1})];
            index1 = index1 + 1;
        end
    end
    if(strcmp(hdr{index,1},'ACQ_spatial_phase_2'))
        acq.spatialphase2 = [];
        index1 = index+1;
        while(length(acq.spatialphase2) < acq.spatialsize2)
            acq.spatialphase2 = [acq.spatialphase2, str2num(hdr{index1,1})];
            index1 = index1 + 1;
        end
    end
    if(strcmp(hdr{index,1},'ACQ_obj_order'))
        acq.objorder = [];
        index1 = index+1;
        while(length(acq.objorder) < acq.NI)
            acq.objorder = [acq.objorder,str2num(hdr{index1,1})];
            index1 = index1+1;
        end
    end
%     if(strcmp(hdr{index,1},'ACQ_read_offset'))
%         acq.readoffset = [];
%         index1 = index+1;
%         while(length(acq.readoffset) < acq.NI)
%             acq.readoffset = [acq.readoffset,str2num(hdr{index1,1})];
%             index1 = index1+1;
%         end
%     end
%     if(strcmp(hdr{index,1},'ACQ_phase1_offset'))
%         acq.phase1offset = [];
%         index1 = index+1;
%         while(length(acq.phase1offset) < acq.NI)
%             acq.phase1offset = [acq.phase1offset,str2num(hdr{index1,1})];
%             index1 = index1+1;
%         end
%     end
end