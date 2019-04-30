function im = read_Bruker2dseq(pathname)

if(~exist('pathname', 'var'))
    pathname = '.';
end
    
visu_pars = readvisu_pars(pathname);
reco = readreco(pathname);


% read data from '2dseq' file
data = fopen([pathname,'/2dseq'], 'r', 'ieee-le');
if data == -1, error('File Read Error'), end;

if(strcmp(reco.type, '_32BIT_SGN_INT'))
    temp_im = fread(data,'int32');
end
if(strcmp(reco.type, '_16BIT_SGN_INT'))
    temp_im = fread(data,'int16');
end
if(strcmp(reco.type, '_8BIT_SGN_INT'))
    temp_im = fread(data,'int8');
end
   

if(visu_pars.dim == 2)
    im = reshape(temp_im,visu_pars.size(1),visu_pars.size(2), visu_pars.frame);
    for frame = 1:visu_pars.frame,
        im(:,:,frame) = im(:,:,frame)*visu_pars.dataslope(frame);
    end
    im = reshape(im,visu_pars.size(1),visu_pars.size(2), visu_pars.frame);
    im = permute(im,[2 1 3 4]);
end
if(visu_pars.dim == 3)
    im = reshape(temp_im,visu_pars.size(1),visu_pars.size(2), visu_pars.size(3),visu_pars.frame);
    for frame = 1:visu_pars.frame,
        im(:,:,:,frame) = im(:,:,:,frame)*visu_pars.dataslope(frame);
    end

    im = permute(im,[2 1 3 4]);
end

im = squeeze(im);
