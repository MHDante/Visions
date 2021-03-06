function [ m_ret ] = SeamCarve( img, c )
sobelY = fspecial('sobel');
sobelX = sobelY';
sigma = 1;
width = sigma*6+1;
gauss = fspecial('gaussian', width, sigma);

derivGaussY = imfilter(gauss, sobelY, 'conv');
derivGaussX = imfilter(gauss, sobelX, 'conv');
[h,w,~] = size(img);
tempImg = img;
for newWidth = w-1:-1:c
    [h,w,~] = size(tempImg);
    newWidth
    newImage = zeros(h,newWidth,3);
    energy = zeros(h,w);
    for i = 1:3
        convdY = im2double(imfilter(tempImg(:,:,i), derivGaussY, 'conv'));
        convdX = im2double(imfilter(tempImg(:,:,i), derivGaussX, 'conv'));
        convdX = convdX .^ 2;
        convdY = convdY .^ 2;
        energy = energy + sqrt(convdX +  convdY);
    end
    energy = energy / 3;
    score = energy;
    
    for y=2:h
        for x=1:w
            left = 1000000;
            middle = score(y-1,x);
            right = 1000000;
            if x > 1
                left = score(y-1,x-1);
            elseif x < w
                right = score(y-1,x+1);
            end
            score(y,x) = energy(y,x) + min([left,middle,right]);
        end
    end
    %     imshow(score,[]);
    %     pause;
    minIndex = 0;
    minVal = 10000000;
    for x=1:w
        s = score(h,x);
        if (s < minVal)
            minVal = s;
            minIndex = x;
        end
    end
    currentIndex = minIndex;
    for y=h:-1:1
        summand = 0;
        for x=1:w-1
            if x == currentIndex
                summand = 1;
                newImage(y,currentIndex,:) = (tempImg(y,currentIndex,:) + tempImg(y,currentIndex+1,:))./2;
            elseif x == currentIndex -1
                newImage(y,currentIndex-1,:) = (tempImg(y,currentIndex,:) + tempImg(y,currentIndex-1,:))./2;
            else
                indx = x + summand;
                newImage(y,x,:) = tempImg(y,indx,:);
            end
        end
        if y ~= 1
            left = 1000000;
            middle = score(y-1,currentIndex);
            right = 1000000;
            if currentIndex > 1
                left = score(y-1,currentIndex-1);
            elseif currentIndex < w
                right = score(y-1,currentIndex+1);
            end
            
            [~,ind] = min([left,middle,right]);
            currentIndex = currentIndex + ind - 2;
        end
    end
    tempImg = newImage;
    imshow(tempImg);
end

m_ret = tempImg;
end

