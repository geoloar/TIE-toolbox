

% Trace Information Extraction (TIE) ANALYSES

% This script performs the Trace Information Extraction (TIE) algorithm 
% on traces (bedrock interface traces and fault traces) in a geological map.
% Read the 'readme.txt' file for further technical instructions, requirements and advice.
% For more information concerning the TIE, see Rauch et al. (2019): https://doi.org/10.1016/j.jsg.2019.06.007.

%%

% INPUT
name        = 'Example: Widdergalm (Switzerland)';  % name of region (not important, put something)
geotif      = 'swissALTI3D_Widdergalm.tif';         % filename of DEM
limits      = [];                                   % Define limits of DEM to be analysed or define [] to use entire geotif. 
                                                    % Attention - DEM area should be equal or smaller, but not larger than shapefiles!
                                                    % Use limits to cutail area if that is the case. 
bedshape    = 'Widdergalm_BED.shp';                 % shapefile of bedrock (polygon format)
fieldbed    = 'KIND';                               % name of attribute field that distinguishes between rock types (numeric!)
tecshape    = 'Widdergalm_TEC.shp';                 % shapefile of tectonic boundaries, faults, thrusts etc. (line format)    
fieldtec    = 'KIND';                               % name of attribute field that distinguishes between fault types (numeric!)

% optional:
orientshape = 'Widdergalm_OM.shp';                  % shapefile containing orientation measurements
fieldDip    = 'DIP';                                % name of attribute field where the dip is defined
fieldAzim   = 'DIP_DIRECT';                         % name of attribute field where the dip direction/azimuth is defined. 
                                                    % Strike data will have to be transformed to dip direction data.

% ATTENTION: Make sure all your data is in the current Matlab path or that
% it is registered in a Matlab search path.
% Example data 'Widdergalm' are available under: https://github.com/geoloar/TIE-toolbox/blob/master/Example%20Data.zip

%%

% LOAD DATA
[X,Y,Z]             = loadCoord(geotif, limits);
[BEDcoor, BEDattr]  = loadBedrock(bedshape, X, Y);
[TECcoor, TECattr]  = loadTecto(tecshape, X, Y);

BED                 = rasterizeBedrock(BEDcoor, BEDattr, X, Y, fieldbed);
TEC                 = rasterizeTecto(TECcoor,TECattr,X,Y,fieldtec);
[TRACE, FAULT]      = extractTraces(BED, TEC);

[ORcoor, ORattr]    = shaperead(orientshape);

%%

% EXTRACT TRACE INFORMATION (actual TIE analysis)
TRACE   = tie(TRACE,X,Y,Z,'yes');        % 'no' stands for 'no segmentation', change to 'yes' if you want to segment the traces according to their inflexion points
FAULT   = tie(FAULT,X,Y,Z,'yes');  


%%

% VISUALIZE MAP AND TRACES
figure(1)
visGeolMap3d(X,Y,Z,BED,0.9)
title(name)
hold on

setTrace = [[0 0 0.5], 5, 14];          % settings [color, linesize, textsize]
visTRACE3d(TRACE,X,Y,Z,setTrace)
setFault = [[1 0 0],   5, 14];          % settings [color, linesize, textsize]
visTRACE3d(FAULT,X,Y,Z,setFault)

hold on
visOrientMeas(ORcoor, ORattr, fieldAzim, fieldDip, X, Y, Z)
hold off


%%

% VISUALIZE TRACE INFORMATION
figure(2)
visGeolMap3d(X,Y,Z,BED,0.5)
title(name)
hold on

LINE    = TRACE;                        % choose main trace set to be displayed in a classifyed fashion
LINE2   = FAULT;                        % choose secondary trace set to be displayed unclassified
for n = 1:length(LINE)
    for s = 1:length(LINE(n).Segment)
        color   = LINE(n).Segment(s).classcode;
        sett    = [color, 5, 0];
        visTRACESeg3d(LINE,n,s,X,Y,Z,sett)
    end
end
set2 = [[0 0 0],   1, 14];              % settings [color, linesize, textsize]
visTRACE3d(LINE2,X,Y,Z,set2)

type = '3d';                            % '3d' vs 'stereo' -> if it is intented as image (non-interactive), 'stereo' is recommended
visOrientBar(LINE,type,X,Y,Z)
visBarLegend(type,X,Y,Z)
hold on

% visOrientMeas( orientshape,fieldAzim,fieldDip, X, Y, Z, projected )
hold off

%%

% VISUALIZE SIGNAL
LINE   = TRACE;                 % choose bedrock interface traces (TRACE) or fault traces (FAULT)
nTrace = 1;                     % choose trace that needs to be analysed

visSignal(LINE,nTrace,3)        % figure 3 -> signal alpha and beta
visSigStereo(LINE,nTrace,4)     % figure 4 -> evolution of chords and chord planes in a stereonet
% nTrace = nTrace +1;


%%

% VISUALIZE CLASSIFICATION
pth     = [3,9,18];             % pth = planarity thresholds: Other planarity thresholds can be defined. However,
                                % it is recommended to adapt it also in the classification parametres of the TIE analysis
                                % -> function 'tie.m' line 93
LINE    = TRACE;                % choose bedrock interface traces (TRACE) or fault traces (FAULT) to be displayed

figure(4)
visSHdiagram(pth) 
title(['Signal height diagram of trace set in',' ',name]);
for t = 1:length(LINE)    
    Segment     = LINE(t).Segment;
    for s = 1:length(Segment)
        ccolor  = Segment(s).classcode;       
        d       = [Segment(s).ChdPlane.dist]';
        ha      = Segment(s).signalheight(1);
        hb      = Segment(s).signalheight(2);
        dmean   = round(mean(d)*100,1);

        names   = [num2str(t),' (',num2str(s),')'];
        moy     = scatter(ha,hb,40,ccolor,'filled'); hold on
                  set(moy,'LineWidth',2);
                  alpha(moy,0.7)
        
        if length(Segment(s).index) > 50
            if dmean > 1 && dmean <= 2
                text(ha-7,hb+4,'! >1%','Color',[1 0.7 0],'FontSize',14)
            end
            if dmean > 2 && dmean <= 3
                text(ha-7,hb+4,'! >2%','Color',[1 0.4 0],'FontSize',14)
            end
            if dmean > 3
                text(ha-7,hb+4,'! >3%','Color','r','FontSize',14)
            end 
        end
        text(ha+2,hb,names,'Color','k','FontSize',9)    
    end
    hold on
end
hold off

