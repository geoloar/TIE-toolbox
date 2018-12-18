

% VISUALIZE ORIENTATION MEASUREMENTS

% visualise all orientation measurements with its orientation on the
% map in 3d

% INPUT
% shapefile     -> Name of shapefile containing orientation measurements.(point data)
% azim_field    -> attribute field in shapefile that contains the dip azimuth/direction information
% dip_field     -> attribute field in shapefile that contains the dip information
% X, Y, Z       -> Coordinate vectors (see loadCoord.mat)

% OUTPUT
% ORcoor        -> Structure from shapefile with the coordinates of orientation measurements
% ORattr        -> Structure from shapefile with the attributes of orientation measurements


function [ORcoor, ORattr] = visOrientMeas(shapefile,azim_field, dip_field, X, Y, Z, projected)

[ORcoor, ORattr] = shaperead(shapefile);
cs = X(2)-X(1);
for m = 1:length(ORattr)
    

    azim        = ORattr(m).(azim_field);
    dip         = ORattr(m).(dip_field) ;
    
    if ~isnumeric(azim)
        azim    = str2double(azim);
        dip     = str2double(dip);
    end
        
    
    % defining strike (both possibilites)
    if azim > 90 
        strike      = azim - 90;
    else
        strike      = azim + 90;
    end
    
    % extracting x-y coordinates for the sign orientation
    [xd,yd]     = stereoLine(azim,0); % small line (dip direction)
    [xs1,ys1]   = stereoLine(strike,0); % half of strike line
    xs2         = xs1*-1;               % other half of strike line (in the other direction)
    ys2         = ys1*-1;
    
    % defining anchoring point, where to put the sign
    if strcmp(projected,'no')
        x = deg2km(ORcoor(m).X)*1000;
        y = deg2km(ORcoor(m).Y)*1000;
    else
        x = ORcoor(m).X;
        y = ORcoor(m).Y;
    end
    
    [~,xi]  =  min(abs(X-x));
    [~,yi]  =  min(abs(Y-y));
    anchor      = [x, y,Z(yi,xi)];
    
    % figure parametres
    amp1    = (length(X)+length(Y))/3;  % sign size - how much to amplify vector (small dip vector)
    amp2    = (length(X)+length(Y));       % sign size - how much to amplify vector (large strike vector)
    zshift  = (length(X)+length(Y))/4;       % how much to shift the sign from its true z value
    txshix  = (length(X)+length(Y))/4;       % how much to shift the text from the sign - in x
    txshiy  = txshix;   % how much to shift the text from the sign - in y
    txshiz  = (length(X)+length(Y))/3;       % how much to shift the text from the sign - in z
    lwdt    = 3;        % Line Width
    
        
    pd  = plot3([anchor(1), anchor(1)+ xd*amp1],[anchor(2), anchor(2)+ yd*amp1],[anchor(3)+zshift, anchor(3)+zshift]); hold on
        set(pd,'LineWidth', lwdt)
        pd.Color    = [0,0,0,1];
    ps1 = plot3([anchor(1), anchor(1)+ xs1*amp2],[anchor(2), anchor(2)+ ys1*amp2],[anchor(3)+zshift, anchor(3)+zshift]); hold on
        set(ps1,'LineWidth', lwdt)
        ps1.Color    = [0,0,0,1];
    ps2 = plot3([anchor(1), anchor(1)+ xs2*amp2],[anchor(2), anchor(2)+ ys2*amp2],[anchor(3)+zshift, anchor(3)+zshift]); hold on
        set(ps2,'LineWidth', lwdt)
        ps2.Color    = [0,0,0,1];
    text(double(anchor(1)+txshix),double(anchor(2)+txshiy),double(anchor(3))+txshiz,num2str(dip),'FontSize',18);

    hold on

end