
function [g_images, images, exposureTimes] = ReadImages(folder, extension)
    images = [];
    exposureTimes = [];
    g_images = [];
    
    if( ~exist('extension') )
	extension = 'jpg';
    end

    files = dir([folder, '/*.', extension]);%read .jpg files

    % initialize images and exposureTimes.
    filename = [folder, '/', files(1).name];
    info = imfinfo(filename);
    number = length(files);
    images = zeros(info.Height, info.Width, info.NumberOfSamples, number, 'uint8');
    g_images = zeros(info.Height, info.Width, number, 'uint8');
    exposureTimes = zeros(number, 1);

    for i = 1:number
	filename = [folder, '/', files(i).name];
	img = imread(filename);
	images(:,:,:,i) = img;% return original images;
    g_images(:,:,i) = rgb2gray(img);% return gray imsges;
    
    exif_info = imfinfo(filename);
    exif_info = exif_info.DigitalCamera;
	exposureTimes(i) = exif_info.ExposureTime;% return i-Dimensions exposureTimes
    end
end
