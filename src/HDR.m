function HDR(folder, level)
    disp('-----loading images with different exposures.-----');
    [g_images, images, exposures] = ReadImages(folder);
    [r, c, channel, numbers] = size(images);
    disp(size(images(1)));
    
    disp('-----MTB image alignment.-----');
    for i = 1:numbers-1
        shift = zeros(1,2);
        shift_result = zeros(1,2);
        [shift] = MTB(g_images(:,:,i), g_images(:,:,i+1), level, shift_result);
        disp([i, shift(1), shift(2)]);
        
        images(:,:,:,i+1) = imtranslate(images(:,:,:,i+1),[shift(1), shift(2)],'FillValues',0);
        g_images(:,:,i+1) = imtranslate(g_images(:,:,i+1),[shift(1), shift(2)],'FillValues',0);
    end
        
end