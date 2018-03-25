function [shift_result] = MTB(g_img1, g_img2, level, shift_result)
    
    shift_tmp = zeros(1,2);
    [h1, w1] = size(g_img1);
    [h2, w2] = size(g_img2);
    
    TBitmap1 = zeros(w1, h1);
    TBitmap2 = zeros(w2, h2);
    EBitmap1 = zeros(w1, h1);
    EBitmap2 = zeros(w2, h2);
    
    if level > 0
        %�C������Ϥ��Y�p��1/2��
        half_img1 = imresize(g_img1, 0.5);
        half_img2 = imresize(g_img2, 0.5);
        shift_tmp = MTB(half_img1, half_img2, level-1, shift_tmp);
        shift_tmp = shift_tmp*2 ;
    else
        shift_tmp = zeros(1,2);
    end
    
    Threshold_1 = median(reshape(g_img1(:,:),[],1));
    Threshold_2 = median(reshape(g_img2(:,:),[],1));
    
    for i = 1:h1
        for j = 1:w1
            % g_img1
            if g_img1(i, j) < Threshold_1 
                TBitmap1(i, j) = 0;
            else
                TBitmap1(i, j) = 1;
            end
            if (g_img1(i, j) >= Threshold_1 - 4) && (g_img1(i, j) <= Threshold_1 + 4)
                % Exclusion Bitmap�w�q�O�N�ҸW��i���ϰ쬰0,��l��1�C
                EBitmap1(i, j) = 0;
            else
                EBitmap1(i, j) = 1;
            end
            % g_img2
            if g_img2(i, j) < Threshold_2 
                TBitmap2(i, j) = 0;
            else
                TBitmap2(i, j) = 1;
            end
            if (g_img2(i, j) >= Threshold_2 - 4) && (g_img2(i, j) <= Threshold_2 + 4)
                EBitmap2(i, j) = 0;
            else
                EBitmap2(i, j) = 1;
            end
        end
    end
    
    min_err = w1 * h1;
    % �q���h(�̤p)�}�l�A
    % ��{(-1, -1),(-1, 0), (-1, 1), (0,-1), (0, 0), (0, 1), (1,-1), (1, 0), (1, 1)} 
    % �o�E�Ӥ�V������
    for i = -1:1:1
        for j = -1:1:1
            v_x = shift_tmp(1) + i;
            v_y = shift_tmp(2) + j;
            shifted_TBitmap2 = imtranslate(TBitmap2, [v_x, v_y], 'FillValues', 0);
            shifted_EBitmap2 = imtranslate(EBitmap2, [v_x, v_y], 'FillValues', 0);
            
            % �N img2 �� threshold bitmap ���ʹL��A�P img1 �� threshold bitmap �� XOR
            diff_b = xor(TBitmap1, shifted_TBitmap2);
            
            % �Ψ�ӨB�J�ץ�:
            diff_b = and(diff_b, EBitmap1); % (1)�N�W�@�B�����G�P img1��s exclusion bitmap �� AND
            diff_b = and(diff_b, shifted_EBitmap2); % (2)�P img2��s shifted exclusion bitmap �� AND
            
            err = sum( diff_b(:) );%�ҥH����1���Ӽƥ[�`�V�p�N��V���ŦX��
            if err < min_err
                shift_result(1) = v_x;
                shift_result(2) = v_y;
                min_err = err;
            end
        end
    end
    
end