function [Iobr] =watershedseg(B8)
I=B8;

hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(I), hy, 'replicate');
Ix = imfilter(double(I), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);

L = watershed(gradmag);
Lrgb = label2rgb(L);

se = strel('disk', 20);
Io = imopen(I, se);

Ie = imerode(I, se);
Iobr = imreconstruct(Ie, I);