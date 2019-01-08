% read the colour image
 colourimage=imread('4.jpg');
% convert it into gray scale
 grayimage=rgb2gray(colourimage);
 figure(1),imshow(colourimage),title('original image');
 
%  apply median filter to strech the contrast of the image
 mediangrayimage=median(grayimage,[8,8]);
 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %  
%  get the count of rowss and coloumns
 [rows,columns]=size(mediangrayimage);
% partioning the image and applying block processing method, here mean of the image is used 
 blocklength=8;
 for i=1:blocklength:rows-blocklength
     for j=1:blocklength:columns-blocklength
         sum=0;
        tempblock=mediangrayimage(i:i+blocklength,j:j+blocklength);
        rowmean=mean(tempblock);
       blockmean=mean(rowmean);
          for p=1:1:blocklength
             for q=1:1:blocklength
               meanimage(i+p,j+q)=blockmean;
                             
               
             end
         end
         
     end
 end
%  convert double image into unsigned-int-8
 meanimage=uint8(meanimage);
 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% level set segmentation of the image
% set the lower and upper thresholds for segmentation in meanimage
 indexset = find(190>meanimage & meanimage>156);
 mask1 = zeros(size(meanimage));
 mask1(indexset) = 255;
%  fill the holes in the mask
 mask1Fill = imfill(mask1,'holes');
%  remove the region in image which contain less than 10000 pixels in it
 segmentedbinaryarea = bwareaopen( mask1Fill, 10000);
%  smoothened by using averaging filter 'h'
 h=ones(8,8);
 smoothsegmentedbinaryarea=imfilter(segmentedbinaryarea,h);
%  again fill the holes for reconfinformation as smoothen may result in
%  holes
 smoothsegmentedbinaryarea= imfill(smoothsegmentedbinaryarea, 'holes');
 temp=smoothsegmentedbinaryarea;
 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% smoothen the valleys in the mask of the image
 [m1,n1]=size(smoothsegmentedbinaryarea);
for i=1:m1
    f=0;
    f1=0;
    f2=0;
    for j=1:n1
        if f==0
        if smoothsegmentedbinaryarea(i,j)==1
            f=1;
        end
        else if f1==0
            if smoothsegmentedbinaryarea(i,j)==0
                f1=1;
                d=i;
                x=j;
            end
            else
                if smoothsegmentedbinaryarea(i,j)==1
                    f2=1;
                    d1=i;
                    x1=j;
                end
            end
        end
            if f2==1
                for y=x:x1
                   smoothsegmentedbinaryarea(i,y)=1;
                end
                f2=0;
                f=0;
                f1=0;
            end
        
    end

end
% above loop is for rowwise and below one is for coloumnwise
for i=1:n1
    f=0;
    f1=0;
    f2=0;
    for j=1:m1
        if f==0
        if smoothsegmentedbinaryarea(j,i)==1
            f=1;
        end
        else if f1==0
            if smoothsegmentedbinaryarea(j,i)==0
                f1=1;
                d=i;
                x=j;
            end
            else
                if smoothsegmentedbinaryarea(j,i)==1
                    f2=1;
                    d1=i;
                    x1=j;
                end
            end
        end
            if f2==1
                for y=x:x1
                   smoothsegmentedbinaryarea(y,i)=1;
                end
                f2=0;
                f=0;
                f1=0;
            end
        
    end
 
end
                
 smoothsegmentedbinaryareanew=smoothsegmentedbinaryarea;
 smoothsegmentedbinaryarea=temp;
  
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% liver segmentation is done in previous part and now it is tumor segmentation
% to get the image in the liver mask
 for i=1:rows-blocklength
     for j=1:columns-blocklength
         if smoothsegmentedbinaryareanew(i,j)==1
         liver(i,j)=grayimage(i,j);
         else
             liver(i,j)=0;
         end
     end
 end
 liver=uint8(liver);
%  search for the pixels between 150 and 130
 indexset2 = find((150>liver & liver>130));
 mask2 = zeros(size(liver));
 mask2(indexset2) = 255;
 maskFill1 = imfill(mask2,'holes');
 h=ones(5,5);
 masktumor=imfilter(maskFill1,h);
%  watershed segmentation to remove the laceration parts
 B8=watershedseg(masktumor);
 h=ones(3,3);
 masktumor1=imfilter(B8,h);
 masktumor1 = imfill(masktumor1,'holes'); 
 figure(2), imshow(masktumor1), title('extracted tumour part');
 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% draw outlines for the fetched masks of tumor and the liver
 OutlinePerimeterOfSmallObjectsRemovedImage = bwperim(masktumor1);
 OutlinePerimeterOfSmallObjectsRemovedImage1 = bwperim(smoothsegmentedbinaryareanew);
%  to thicken the perimeter
 h=ones(3,3);
 thikOutlinePerimeterOfSmallObjectsRemovedImage=imfilter(OutlinePerimeterOfSmallObjectsRemovedImage,h);
 thikOutlinePerimeterOfSmallObjectsRemovedImage1=imfilter(OutlinePerimeterOfSmallObjectsRemovedImage1,h);
 [w,r]=size(thikOutlinePerimeterOfSmallObjectsRemovedImage);
 [w1,r1]=size(thikOutlinePerimeterOfSmallObjectsRemovedImage1);
%  crop for the image which has minimum size to avoid matrix mismatches
 if w1<w
      w=w1
      if r1<r
          r=r1
      end
 end
 
%  colouring the perimeters
 OutlineOverlay1 = imoverlay(thikOutlinePerimeterOfSmallObjectsRemovedImage(1:w,1:r), thikOutlinePerimeterOfSmallObjectsRemovedImage(1:w,1:r), [1 0 0]);
 figure(3);
 imshow(OutlineOverlay1),title('perimeter of tumor');
 OutlineOverlay2 = imoverlay(thikOutlinePerimeterOfSmallObjectsRemovedImage1(1:w,1:r), thikOutlinePerimeterOfSmallObjectsRemovedImage1(1:w,1:r), [0 .75 0]);
 figure(4);
 imshow(OutlineOverlay2),title('perimeter of liver');;
 OutlineOverlay3 = imoverlay(thikOutlinePerimeterOfSmallObjectsRemovedImage1(1:w,1:r), thikOutlinePerimeterOfSmallObjectsRemovedImage1(1:w,1:r), [0 .75 0]);
% prepare the final image by adding tumor and liver perimeters to the
% original image
 finalimage=colourimage(1:w,1:r,:)+OutlineOverlay1+ OutlineOverlay2;
 figure(5);
 imshow(finalimage),title('final image');;