function [ y ] = myfun( beta,x )
%MYFUN Summary of this function goes here
%   Detailed explanation goes here
    b1 = beta(1);
    b2 = beta(2);
    b3 = beta(3);
    b4 = beta(4);
    y = b1*sin(b2*x+b3)+b4;

end

