%% read CS FLASH kspace data
function [kdata,m2] = read_CSFlash_data(pathname)

% kspace = read_BrukerFID(pathname);
% kspace = fftshift(kspace,1);

method = readmethod(pathname);
acq = readacqp(pathname);

nr = acq.NR;
nsl = acq.nSlice;
fid=fopen([pathname,'/fid']);
if(strcmp(acq.wordsize,'_32_BIT')) 
    ztmp = fread(fid,inf,'int32',0,'l');
end
if(strcmp(acq.wordsize,'_16_BIT')) 
    ztmp = fread(fid,inf,'int16',0,'l');
end
fclose(fid);

ztmp = ztmp(1:2:end) + sqrt(-1)*ztmp(2:2:end);
% need to debug
readsize = 2^round(log(acq.size(1)/2)/log(2));

%z = reshape(z,acq.size(1)/2,nsl,acq.size(2),nr);
ztmp = reshape(ztmp,readsize,nsl,acq.size(2),nr);
z = ztmp(1:acq.size(1)/2,:,:,:);
z = permute(z,[1 3 4 2]);

[m2, tab] = mask_cs2d(pathname);

kdata = zeros(size(z));
for i=1:nsl
    for j=1:acq.NR
        kdata(:,tab(:,j,i),j,i) = z(:,:,j,i);
    end
end

m2 = shiftdim(m2,-1);
m2 = repmat(m2,[method.imSize(1),1,1]);

% kdata = permute(kdata,[2 1 3 4]); % [y x nr nslice]