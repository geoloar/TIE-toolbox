

% VISUALIZE STEREO DATA

% visualise stereographic projection of connecting chords and chord plane
% poles

% INPUT
% TRACE     -> structure containing basic TRACE information (any TRACE set, -
             % could also be FAULTS). Fields needed:
                    % -> TRACE.Segment  = structure of trace segments.  
                            % Segment.Chords    = sturcture of connecting chord information
                            %   -> Chords.axtr  = trend of conncecting chord (plunge azimuth)
                            %   -> Chords.axpl  = plunge of connecting chord
                            % Segment.ChdPlane  = structure of Chord plane information
                            %   -> ChdPlane.plane_orient = [dip direction, dip] of each chord plane
                            %   -> ChdPlane.pole_orient  = [trend, plunge] of each pole of chord plane
                           
% n         -> n - trace number (within TRACE structure)
             
% OUTPUT 
% fig       -> figure handle


function fig = visSigStereo(TRACE,n)

fig = figure(2000);

ls = length(TRACE(n).Segment);    
for s = 1:length(TRACE(n).Segment)

    subplot(ls,2,1)
    visAlphaStereo(TRACE,n,s);
    title(strcat('ALPHA',num2str(n)))
    hold off

    subplot(ls,2,2)
    visBetaStereo(TRACE,n,s) 
    title(strcat('BETA',num2str(n)))
    hold off

end


