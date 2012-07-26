function c = fade(color, percent)
    colorHSV = rgb2hsv(color);
    colorHSV(2) = colorHSV(2).*percent;
    colorHSV(3) = colorHSV(3)+(1-percent)/3.5;
    c = hsv2rgb(colorHSV);
    c(c<0) = 0;
    c(c>1) = 1;
end
