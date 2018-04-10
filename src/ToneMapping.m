function toneMappedImg = ToneMapping(img,delta,key,L_white)
    toneMappedImg = zeros(size(img));
    % 將RGB轉換成Lw (Luminance of World)
    Lw = 0.2126 * img(:,:,1) + 0.7152 * img(:,:,2) + 0.0722 * img(:,:,3);
    % Lw = 0.299 * img(:,:,1) + 0.587 * img(:,:,2) + 0.114 * img(:,:,3);
    
    % Global Operator
    LwMean = exp(mean(mean(log(delta + Lw))));
    Lm = key ./ LwMean .* Lw;
    % Ld = Lm ./ (1 + Lm);
    Ld = (Lm .* (1 + (Lm ./ L_white^2))) ./ (1 + Lm);
    
    % 輸出Tone Mapping後的影像
    for channel = 1:3
        C = img(:,:,channel) ./ Lw;
        toneMappedImg(:,:,channel) = C .* double(Ld);
    end
end