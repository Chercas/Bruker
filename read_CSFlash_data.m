%% read CS FLASH kspace data
function [kdata,m2] = read_CSFlash_data(pathname)

% kspace = read_BrukerFID(pathname);
% kspace = fftshift(kspace,1);

%------TEMPORAL
clear all;
close all;
clc;
%---------------
pathname = ['/home/kostya/Documents/BCS_matlab_code/BCS_pros/48'];
method = readmethod(pathname);
acq = readacqp(pathname);

%---Number of Repetitions
NR = acq.NR;
%---Number of Slices
NSlices = acq.NSlices;
%---Number of Phase & RO steps
PE_steps = acq.size(2);
RO_steps = method.kSize(1);

%------Reading FID word_by_word
FID=fopen([pathname,'/fid']);
if(strcmp(acq.wordsize,'_32_BIT'));wSize = 'int32';else wSize = 'int16';end
RawData = fread(FID,inf,wSize,0,'l');
fclose(FID);

%-------Creating complex data from words-----
RawDataComplex = RawData(1:2:end) + sqrt(-1)*RawData(2:2:end);
[TotalPoints, ~] = size(RawDataComplex); 

%--Computing an ADC sampling size (num of points/words sampled at ones)
%--should be equal or bigger then RO and be
%--an integer value within ADC sampling range.
ADC = (0:1:31);
bit = 1;
while RO_steps > power(2, ADC(bit)); bit=bit+1; end

ADC_SampPoints = power(2, ADC(bit));

%if TotalPoints == ADC_SampPoints*NSlices*PE_steps*NR
    
ADCMatrix = reshape(RawDataComplex,ADC_SampPoints,NSlices,PE_steps,NR);
RawMatrix = ADCMatrix(1:RO_steps,:,:,:);
RawMatrixPerm = permute(RawMatrix,[1 3 4 2]);

[m2, tab] = mask_cs2d(pathname);

kdata = zeros(size(RawMatrixPerm));
for i=1:acq.NSlices
    for j=1:acq.NR
        kdata(:,tab(:,j,i),j,i) = RawMatrixPerm(:,:,j,i);
    end
end

m2 = shiftdim(m2,-1);
m2 = repmat(m2,[method.imSize(1),1,1]);

% kdata = permute(kdata,[2 1 3 4]); % [y x nr nslice]