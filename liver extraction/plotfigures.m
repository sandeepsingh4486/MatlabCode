function [y]=plotfigures(mask1, temp, smoothsegmentedbinaryarea,masktumor1,OutlineOverlay1, OutlineOverlay2,finalimage)
figure(1);
subplot(1,3,1),imshow(mask1),title('Extracted Liver Part By Thresholding');
subplot(1,3,2),imshow(temp),title('Extracted Liver Part With Valleys In The Mask');
subplot(1,3,3),imshow(smoothsegmentedbinaryarea),title('Extracted Liver Part');
figure(2);
subplot(1,3,1),imshow(masktumor1), title('Extracted Tumor Part');
subplot(1,3,2),imshow(OutlineOverlay1),title('Perimeter Of Tumor');
subplot(1,3,3),imshow(OutlineOverlay2),title('Perimeter Of Liver');
figure(3);
imshow(finalimage),title('Final Image');
y=1;