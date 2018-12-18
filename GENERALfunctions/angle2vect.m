

% ANGLE to VECTOR

% calculates the directional vector (length = 1) from a line defined by angles -
% trend and plunge

% INPUT
% trend, plunge -> angles of azimuth (dip azimuth) and dip of plane.  

% OUTPUT
% [vx, vy, vz]  -> coordinate of line vector;


function [vx,vy,vz]=angle2vect(trend,plunge)

vz = -sind(plunge);
vx = sind(trend)*cosd(plunge);
vy = cosd(trend)*cosd(plunge);
