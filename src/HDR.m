function HDR(folder, level)
    disp('-----loading images with different exposures.-----');
    [g_images, images, exposures] = ReadImages(folder);
    [r, c, channel, numbers] = size(images);
    ln_T = log(exposures);
    disp(ln_T);
    
%     disp(size(images(1)));

    disp('-----MTB image alignment.-----');
    
    for i = 1:numbers-1
        shift = zeros(1,2);
        shift_result = zeros(1,2);
        [shift] = MTB(g_images(:,:,i), g_images(:,:,i+1), level, shift_result);
        disp([i, shift(1), shift(2)]);
        
        images(:,:,:,i+1) = imtranslate(images(:,:,:,i+1),[shift(1), shift(2)],'FillValues',0);
        g_images(:,:,i+1) = imtranslate(g_images(:,:,i+1),[shift(1), shift(2)],'FillValues',0);
    end
    
    small_row = 20;
    small_col = 10;
    disp('-----shrinking the images to get the reasonable number of sample pixels (by srow*scol).-----');
    simages = zeros(small_row, small_col, channel, numbers);
    for i = 1:numbers
        simages(:,:,:,i) = round(imresize(images(:,:,:,i), [small_row small_col], 'bilinear'));
    end
    
    disp('-----calculating camera response function by gsolve.-----');
    g = zeros(256, 3);
    ln_E = zeros(small_row*small_col, 3);
    weight = 0:1:255;
	weight = min(weight, 255-weight);
    weight = weight/max(weight);% ¤W½Ò hat weighting function

    lambda = 500;
    for channel = 1:3
        rsimages = reshape(simages(:,:,channel,:), small_row*small_col, numbers);
        [g(:,channel), ln_E(:,channel)] = gsolve(rsimages, ln_T, lambda, weight);
    end 
    
    disp('-----constructing HDR radiance map.-----');
    imgHDR = hdrDebevec(images, g, ln_T, weight);
    hdrwrite(imgHDR, 'hdr.hdr');
    
    disp('-----tone mapping.-----')
    type_ = 'local';
    alpha_ = 0.8;
    delta_ = 1e-6;
    white_ = 100;
    phi = 8.0;
    epsilon = 0.05;
    
	prefix = 'img';
    
    
    imgTMO = tmoReinhard02(imgHDR, type_, alpha_, delta_, white_, phi, epsilon);
    %imgTMO = KimKautzConsistentTMO(imgHDR);
    %imgTMO = ToneMapping(imgHDR,delta_,alpha_,white_);
    %imgTMO = bfltColor(imgHDR,5,3,0.1);
    %imgTMO = tmoReinhard02(hdr, type_, alpha_, delta_, white_, phi, epsilon);
    write_rgbe(imgTMO, [prefix '_tone_mapped.hdr']);
    imwrite(imgTMO, [prefix '_tone_mapped.png']);
    
    disp('Done!')
end