classdef WatermarkProcessor < matlab.mixin.Copyable
    properties
        image
    end
    
    methods
        function obj = WatermarkProcessor(imagePath)
            obj.image = (imread(imagePath));
        end

        function inject(obj, watermark, marker)
            watermark = strcat(marker, watermark);
            [h, w, c] = size(obj.image);

            if length(watermark) > h * w * c
                error('Watermark too large for the image');
            end
            
            obj.injectSequential(watermark);
        end
        

        function injectSequential(obj, watermark)
            watermarkIndex = 1;
            
            % Iterate through the pixel
            for row = 1:size(obj.image, 1)
                for col = 1:size(obj.image, 2)
                    for colorChannel = 1:size(obj.image, 3)
                        % Get the value of the pixel
                        pixel = obj.image(row, col, colorChannel);                            
                        pixel = bitset(pixel, 1, str2double(watermark(watermarkIndex)));

                        obj.image(row, col, colorChannel) = pixel;
                        watermarkIndex = watermarkIndex + 1;
                        
                        % If there's no watermark remaining to inject
                        if watermarkIndex > length(watermark)
                            watermarkIndex = 1;
                        end
                    end
                end
            end
        end


        function saveImage(obj, outputPath, ratio)
            switch ratio
                case 100
                    obj.saveImage100(outputPath);
                case 50
                    obj.saveImage50(outputPath);
                case 25
                    obj.saveImage25(outputPath);
                case 10
                    obj.saveImage10(outputPath);
                case 5
                    obj.saveImage5(outputPath);
                otherwise
                    obj.saveImage100(outputPath);
            end
        end


        function saveImage100(obj, outputPath)
            imwrite(obj.image, outputPath);
        end
        

        function saveImage50(obj, outputPath)
            % Calculate the region of interest (ROI)
            width = size(obj.image, 2);
            height = size(obj.image, 1);
            
            roiWidth = round(0.5 * width);
            roiHeight = round(0.5 * height);
            
            startX = round((width - roiWidth) / 2) + 1;
            startY = round((height - roiHeight) / 2) + 1;
            
            % Crop the central 50% of the image
            croppedImage = obj.image(startY:startY + roiHeight - 1, ...
                startX:startX + roiWidth - 1, :);
            
            % Save the cropped image
            imwrite(croppedImage, outputPath);
        end

        
        function saveImage25(obj, outputPath)
            % Calculate the region of interest (ROI)
            width = size(obj.image, 2);
            height = size(obj.image, 1);
            
            roiWidth = round(0.25 * width);
            roiHeight = round(0.25 * height);
            
            startX = round((width - roiWidth) / 2) + 1;
            startY = round((height - roiHeight) / 2) + 1;
            
            % Crop the central 50% of the image
            croppedImage = obj.image(startY:startY + roiHeight - 1, ...
                startX:startX + roiWidth - 1, :);
            
            % Save the cropped image
            imwrite(croppedImage, outputPath);
        end


        function saveImage10(obj, outputPath)
            % Calculate the region of interest (ROI)
            width = size(obj.image, 2);
            height = size(obj.image, 1);
            
            roiWidth = round(0.1 * width);
            roiHeight = round(0.1 * height);
            
            startX = round((width - roiWidth) / 2) + 1;
            startY = round((height - roiHeight) / 2) + 1;
            
            % Crop the central 50% of the image
            croppedImage = obj.image(startY:startY + roiHeight - 1, ...
                startX:startX + roiWidth - 1, :);
            
            % Save the cropped image
            imwrite(croppedImage, outputPath);
        end


        function saveImage5(obj, outputPath)
            % Calculate the region of interest (ROI)
            width = size(obj.image, 2);
            height = size(obj.image, 1);
            
            roiWidth = round(0.05 * width);
            roiHeight = round(0.05 * height);
            
            startX = round((width - roiWidth) / 2) + 1;
            startY = round((height - roiHeight) / 2) + 1;
            
            % Crop the central 50% of the image
            croppedImage = obj.image(startY:startY + roiHeight - 1, ...
                startX:startX + roiWidth - 1, :);
            
            % Save the cropped image
            imwrite(croppedImage, outputPath);
        end
    end
end
