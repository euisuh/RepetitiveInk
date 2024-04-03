clc
clear
close all

% Change to your input image path
imagePath = 'input_image.tif';
% Create WatermarkProcessor that injects and extracts the watermark
processor = WatermarkProcessor(imagePath);

% WATERMARK INJECTION
tic; disp('Beginning INJECTION');

% Create watermark
marker = '1010101';
watermarkData = 'Watermark and Copyright by Euisuh John Jeong';
wm = reshape(dec2bin(watermarkData,7)', 1, strlength(watermarkData)*7);

% Inject watermark into image with sequential injection   
processor.inject(wm, marker);

elapsedTime = toc;
disp('Completed INJECTION');
disp(['Elapsed time for inject: ', num2str(elapsedTime), ' seconds']);


% Save Image in different size (crop)
% Original Image
processor.saveImage('output100.tif', 100);
% Image with central 50% of both width and height
processor.saveImage('output50.tif', 50);
% Image with central 25% of both width and height
processor.saveImage('output25.tif', 25);
% Image with central 10% of both width and height
processor.saveImage('output10.tif', 10);
% Image with central 5% of bth width and height
processor.saveImage('output5.tif', 5);

% WATERMARK EXTRACTION
tic; disp('Beginning EXTRACTION');

% Extract watermark from image
extractedWatermark = extract('output25.tif', strlength(watermarkData)*7, marker);
% Convert watermark to character
watermarkData = wm2Char(extractedWatermark);

elapsedTime = toc;
disp('Completed EXTRACTION');
disp(['Elapsed time for extract: ', num2str(elapsedTime), ' seconds']);

disp(watermarkData);

% WATERMARK DETECTION
disp('Beginning DETECTION');
img = imread('output50.tif');
[rows, cols, channels] = size(img);

% Initialize matrices to store the LSB
lsbMatrix = zeros(rows*cols*channels, 1);
lsb_index = 1;

% Iterate through each pixel and extract the LSB for each channel
for row = 1:size(img, 1)
    for col = 1:size(img, 2)
        for channel = 1:size(img, 3)
            pixel = img(row, col, channel);    
            lsbMatrix(lsb_index) = num2str(bitget(pixel, 1));
            lsb_index = lsb_index + 1;
        end
    end
end

mark = lsbMatrix;
[c, lags] = xcorr(mark, 5000);
stem(lags, c);

[pksh, lcsh] = findpeaks(c);
idx = find(pksh > 1e6);

plot(lcsh(idx), pksh(idx), 'o');
ylim([0, 8e5]);
diff(lcsh(idx))

function watermarkData = wm2Char(extractedWatermark)
    % Reshape the binary data
    binaryData = reshape(extractedWatermark, 7, []).';
    % Convert binary to decimal to character
    watermarkData = char(bin2dec(binaryData)');
    % Remove any trailing null characters (if present)
    watermarkData = strtrim(watermarkData);
end

function extracted_watermark = extract(outputPath, length_of_watermark, marker)
    output_image = imread(outputPath);
    len_marker = length(marker);
    extracted_bit = '';
    extracted_watermark = '';

    wm_collection = cell(1, 100);
    potential_wm_index = 1;
    back_wm_collection = cell(1, 100);
    potential_back_wm_index = 1;
     
    wm_found = false;

    for row = 1:size(output_image, 1)
        for col = 1:size(output_image, 2)
            for colorChannel = 1:size(output_image, 3)
                % Get the value of the pixel
                pixel = output_image(row, col, colorChannel);
                length_wm = length(extracted_watermark);

                % If marker is found. Start extracting the watermark
                if wm_found
                    extracted_watermark = strcat(extracted_watermark, num2str(bitget(pixel, 1)));
                   
                    % Extracting watermark is completed. return.
                    if length_wm+1 >= length_of_watermark
                        return;
                    end

                % If marker is not found. Continue finding it.
                else
                    extracted_bit = strcat(extracted_bit, num2str(bitget(pixel, 1)));
                    % Check if we found the marker
                    if length(extracted_bit) > len_marker
                        potential_marker = extracted_bit(end-(len_marker-1):end);
                        if strcmp(potential_marker, marker)
                            back_wm_collection{potential_back_wm_index} = extracted_bit(1:end-len_marker);
                            potential_back_wm_index = potential_back_wm_index + 1;

                            extracted_bit = '';
                            wm_found = true;
                        end
                    end
                end
            end
        end
        
        % If row has changed reset the current process
        if wm_found
            wm_collection{potential_wm_index} = extracted_watermark;
            potential_wm_index = potential_wm_index + 1;

            extracted_watermark = '';
            wm_found = false;
        else
            extracted_bit = '';
        end
    end
    
    maxLength = 0;
    % Finding the longest watermark
    for i = 1:length(wm_collection)
        % Get the current string
        currentString = wm_collection{i};
        
        % Calculate length
        currentLength = length(currentString);
                        
        % Update if the current string is longer or has more occurrences
        if currentLength > maxLength || (currentLength == maxLength)
            maxLength = currentLength;
            extracted_watermark = currentString;
        end
    end
    
    maxLength = 0;
    potential_back_wm = '';

    % Finding the longest watermark from the front
    for i = 1:length(back_wm_collection)
        % Get the current string
        currentString = back_wm_collection{i};
        
        % Calculate length
        currentLength = length(currentString);

        % Update if the current string is longer or has more occurrences
        if currentLength > maxLength || (currentLength == maxLength)
            maxLength = currentLength;
            potential_back_wm = currentString;
        end
    end

    length_watermark = length(extracted_watermark);
    remainder = mod(length_watermark, 7);
    extracted_watermark = extracted_watermark(1:end-remainder);

    length_watermark = length(potential_back_wm);
    remainder = mod(length_watermark, 7);
    required_length = length_watermark-remainder;
    potential_back_wm = potential_back_wm(end-(required_length-1):end);

    extracted_watermark = strcat(extracted_watermark, potential_back_wm);
end

