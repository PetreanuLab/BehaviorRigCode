function [ output_args ] = go( input_args )
%GO Summary of this function goes here
%   Detailed explanation goes here
flush;
newstartup;
dispatcher('init')
        a = findobj('type','figure');
        [b c] = sort(a);
        set(a(c(1)), 'position', [50 50 405 550]);
