
function kspace = read_BrukerFID(pathname)


%% Read acqp file
if(~exist('pathname', 'var'))
    pathname = '.';
end
pathname = '/home/kostya/Documents/BCS_matlab_code/BCS_retro/68';
acq = readacqp(pathname);
method = readmethod(pathname);
reco = readreco([pathname,'/pdata/1']);

fid = fopen([pathname,'/fid'], 'r');
if fid == -1, error('File Read Error'), end;
if(strcmp(acq.wordsize,'_32_BIT')) 
    temp_d = fread(fid,inf,'int32',0,'l');
end
if(strcmp(acq.wordsize,'_16_BIT')) 
    temp_d = fread(fid,inf,'int16',0,'l');
end
fclose(fid);

%% Make kspace
% Bruker automatically interleaves real & imaginary channels
temp = temp_d(1:2:end) + sqrt(-1)*temp_d(2:2:end);

if(acq.dim == 2)
    RO = length(temp)/ (acq.NI * acq.size(2) *  acq.NR);
    temp = reshape(temp,RO,acq.phasefactor, acq.NI, acq.size(2)/acq.phasefactor, acq.NR);
    temp(:,:,acq.objorder+1,:,:) = temp;
    %temp = permute(temp,[1 2 4 3 5]);
    temp = squeeze(temp);
    temp = temp(1:acq.size(1)/2*acq.nRX,:,:,:);
    if(isfield(acq, 'spatialphase1'))
        [~, phase1order] = sort(acq.spatialphase1);
        %temp = temp(:,phase1order,:,:);
        temp = reshape(temp,acq.size(1)/2,acq.nRX,size(temp,2),size(temp,3),size(temp,4));
    else
        temp = reshape(temp,acq.size(1)/2,acq.nRX,size(temp,2),size(temp,3),size(temp,4));
    end
    kspace = permute(temp,[1 3 2 4 5]);
%     if(length(temp) == acq.size(1)*acq.nRX*acq.NI * acq.size(2) *  acq.NR)
%         temp = reshape(temp,acq.size(1), acq.nRX, acq.NI, acq.size(2), acq.NR);
%         temp = temp(1:acq.size(1)/2,:,:,:);
%     else
%         temp = reshape(temp,acq.size(1)/2, acq.nRX, acq.NI, acq.size(2), acq.NR);
%     end
%     temp = permute(temp,[1 4 2 3 5]);
%     [m, phase1order] = sort(acq.spatialphase1);
%     kspace = zeros(size(temp));
%     kspace(:,:,:,acq.objorder+1,:) = temp(:,phase1order,:,:,:);
   
    kspace_1 = fftshift(fftshift(kspace,1),2); % move k-space center to origin
    kspace_2 = fftshift(kspace(:,:,:,:));
    %for iRep = 1:size(kspace,5)
    for iNi = 1:size(kspace,4)
        iObject = iNi;% + (iRep-1)*acq.NI;
        for iRX = 1:size(kspace,3)
            for index = 1:size(kspace,1)
                kspace(index,:,iRX, iNi,:) = kspace(index,:,iRX,iNi,:)*exp(-sqrt(-1)*(reco.rotate(iObject,1)-0.5)*2*pi*(index-1));
            end
            for index = 1:size(kspace,2)
                 kspace(:,index,iRX, iNi,:) = kspace(:,index,iRX,iNi,:)*exp(-sqrt(-1)*(reco.rotate(iObject,2)-0.5)*2*pi*(index-1));
            end
        end
    end
    %end    
    im = zeros(size(kspace));
    for iRep = 1:size(kspace,5)
        for iNi = 1:size(kspace,4),
            for iRX = 1:size(kspace,3),
                im(:,:,iRX,iNi,iRep) = fftshift(ifft2(kspace(:,:,iRX,iNi,iRep))); 
            end
        end        
    end

    im = permute(im,[2 1 3 4 5])*size(im,1)*size(im,2);
else
    if(acq.dim == 3)
        temp = reshape(temp,length(temp)/(acq.NI * acq.size(2) *  acq.NR),acq.phasefactor, acq.NI, acq.size(2)/acq.phasefactor, acq.size(3), acq.NR);
        temp(:,:,acq.objorder+1,:,:) = temp;
        temp = permute(temp,[1 2 4 5 3 6]);
        temp = reshape(temp,size(temp,1),size(temp,2)*size(temp,3),size(temp,4),size(temp,5),size(temp,6));
        temp = temp(1:acq.size(1)/2*acq.nRX,:,:,:);
        [m, phase1order] = sort(acq.spatialphase1);
        [m, phase2order] = sort(acq.spatialphase2);
        temp = temp(:,phase1order,phase2order,:,:);
        temp = reshape(temp,acq.size(1)/2,acq.nRX,size(temp,2),size(temp,3),size(temp,4),size(temp,5));
        kspace = permute(temp,[1 4 2 3 5 6]);
%         if(length(temp) == acq.size(1)*acq.nRX * acq.NI * acq.size(2) * acq.size(3) * acq.NR)
%             temp = reshape(temp,acq.size(1), acq.nRX, acq.NI, acq.size(2), acq.size(3), acq.NR);
%             temp = temp(1:acq.size(1)/2,:,:,:);
%         else
%             temp = reshape(temp,acq.size(1)/2, acq.nRX, acq.NI, acq.size(2), acq.size(3), acq.NR);
%         end
%         temp = permute(temp,[1 4 5 2 3 6]);
%         [m, phase1order] = sort(acq.spatialphase1);
%         [m, phase2order] = sort(acq.spatialphase2);
%         kspace = temp;
%         kspace(:,:,:,:,acq.objorder+1,:) = temp(:,phase1order,phase2order,:,:,:);

        kspace = fftshift(fftshift(fftshift(kspace,1),2),3); % move k-space center to origin
        for iRep = 1:size(kspace,6)
            for iNi = 1:size(kspace,5),
                iObject = iNi + (iRep-1)*acq.NI;
                for iRX = 1:size(kspace,4),
                    for index = 1:size(kspace,1),                
                        kspace(index,:,:,iRX,iNi,iRep) = kspace(index,:,:,iRX,iNi,iRep)*exp(-sqrt(-1)*(reco.rotate(iObject,1)-0.5)*2*pi*(index-1));
                    end
                    for index = 1:size(kspace,2),
                         kspace(:,index,:,iRX,iNi,iRep) = kspace(:,index,:,iRX,iNi,iRep)*exp(-sqrt(-1)*(reco.rotate(iObject,2)-0.5)*2*pi*(index-1));
                    end
                    for index = 1:size(kspace,3),
                         kspace(:,:,index,iRX,iNi,iRep) = kspace(:,:,index,iRX,iNi,iRep)*exp(-sqrt(-1)*(reco.rotate(iObject,3)-0.5)*2*pi*(index-1));
                    end
                end
            end
        end    
        im = zeros(size(kspace));
        for iRep = 1:size(kspace,6)
            for iNi = 1:size(kspace,5),
                for iRX = 1:size(kspace,4),
                    im(:,:,:,iRX,iNi,iRep) = fftshift(ifftn(kspace(:,:,:,iRX,iNi,iRep))); 
                end
            end        
        end

        im = permute(im,[2 1 3 4 5 6])*size(im,1)*size(im,2)*size(im,3);
    else
        im = [];
    end
end
