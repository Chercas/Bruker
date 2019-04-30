function im = read2dseq(pathname,visupars)

data = fopen([pathname,'/2dseq'], 'r', 'ieee-le');
if data == -1, error('File Read Error'), end;
if(strcmp(visupars.type, '_32BIT_SGN_INT'))
    temp_im = fread(data, 'int32');

elseif(strcmp(visupars.type, '_16BIT_SGN_INT'))
    temp_im = fread(data, 'int16');

elseif(strcmp(visupars.type, '_8BIT_SGN_INT'))
    temp_im = fread(data, 'int8');
end
    

scalingFactors = visupars.dataslope(:);

switch visupars.dim
    case  2
        if(isfield(visupars,'Necho')==0)
        volumesize = visupars.frame/visupars.orientation;
        im = reshape(temp_im,visupars.size(1),visupars.size(2), volumesize, visupars.orientation);

        elseif visupars.Necho == 1
        volumesize = visupars.frame/visupars.orientation;
        im = reshape(temp_im,visupars.size(1),visupars.size(2), visupars.orientation, volumesize);
        
        else
         im2 = reshape(temp_im,visupars.size(1),visupars.size(2), visupars.frame);
         im = zeros([visupars.size(1),visupars.size(2), visupars.frame/visupars.Necho,visupars.Necho]);
             for i = 1:visupars.Necho
              j = 0;
                 for k= i:visupars.Necho:visupars.frame
                     j = j+1;
                    im(:,:,j,i) = im2(:,:,k);        
                 end
             end
        end

    index = 1;
    for iTR = 1:size(im,4),
        for iSlice = 1:size(im,3),
            im(:,:,iSlice,iTR) = im(:,:,iSlice,iTR)*scalingFactors(index);
            index = index+1;
        end
    end
    
    if(isfield(visupars,'Necho')==0)
    im = permute(im,[1 2 4 3]);
    end

    im = im(end:-1:1,end:-1:1,end:-1:1,:);
    
    case 3
    volumesize = visupars.frame/visupars.orientation;
    im = reshape(temp_im,visupars.size(1),visupars.size(2), visupars.size(3), volumesize);
    index = 1;
    for iTR = 1:size(im,4),
        im(:,:,:,iTR) = im(:,:,:,iTR)*scalingFactors(index);
        index = index+1;
    end

    im = im(end:-1:1,end:-1:1,end:-1:1,:);
end

im = im(:,:,end:-1:1,:);

