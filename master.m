
% TIE ANALYSES

% INPUT
name        = 'Corte (Corse)';                      % name of region (not important, put something)
geotif      = 'corte-soveria_5m-181.tif';           % DEM of region
limits      = [1207130 1208970; 6155170 6158280];   % Define [] to use entire geotif. 
                                                    % Attention - DEM area must be equal or smaller, but not larger than shapefiles!
                                                    % Use limits to cutail area if that is the case. 
projected   = 'yes';                                % the algorithm works for a projected coordinate system. For a geographic coordinate system put 'no'.
bedshape    = 'Bedrock_PLG.shp';                    % shapefile of bedrock (polygon)
fieldbed    = 'OBJ_CD';                             % attribute field of the shapefile that distinguishes between rock types (numeric!)
tecshape    = 'Tectonic_Boundaries_L.shp';          % shapefile of tectonic boundaries (faults and stuff)    
fieldtec    = 'OBJ_CD';                             % attribute field of the shapefile that distinguishes between fault types (numeric!)

orientshape = 'Planar_Structures_PT.shp';
fieldDip    = 'DIP';
fieldAzim   = 'DIP_DIRECT';


%%

% LOAD DATA
[X,Y,Z]             = loadCoord(geotif, limits);
[BEDcoor, BEDattr]  = loadBedrock(bedshape, X, Y);
[TECcoor, TECattr]  = loadTecto(tecshape, X, Y);

BED                 = rasterizeBedrock(BEDcoor, BEDattr, X, Y, fieldbed);
TEC                 = rasterizeTecto(TECcoor,TECattr,X,Y,fieldtec);
[TRACE, FAULT]      = extractTraces(BED, TEC);

if strcmp(projected,'no') % very brutal way of projecting the map. For large areas, the results may be inaccurate
    X = deg2km(X)*1000;
    Y = deg2km(Y)*1000;
    Z(Z<-100) = 0;
end

% EXTRACT TRACE INFORMATION
TRACE   = tie(TRACE,X,Y,Z,'no');
FAULT   = tie(FAULT,X,Y,Z,'no');


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
% visOrientMeas( orientshape,fieldAzim,fieldDip, X, Y, Z, projected )
hold off

%%

% VISUALIZE TRACE INFORMATION
figure(2)
visGeolMap3d(X,Y,Z,BED,0.5)
title(name)
hold on

LINE = FAULT;            % choose trace set to be displayed
for n = 1:length(LINE)
    for s = 1:length(LINE(n).Segment)
        color   = LINE(n).Segment(s).classcode;
        sett    = [color, 5, 0];
        visTRACESeg3d(LINE,n,s,X,Y,Z,sett)
    end
end

type = '3d';                            % vs 'stereo'
visOrientBar(LINE,type,X,Y,Z)
hold on

% visOrientMeas( orientshape,fieldAzim,fieldDip, X, Y, Z, projected )
hold off
%%

% VISUALIZE SIGNAL

nTrace = 6;              % choose trace that needs to be analysed
visSignal(TRACE,nTrace)
visSigStereo(TRACE,nTrace)


%%

% VISUALIZE CLASSIFICATION
figure(4)
r = [3,9,18];                   % define other planarity thresholds if it suits better for your study
visSHdiagram(r) 
title(strcat('Signal height diagram of trace set in ', name));
LINE = FAULT;

for t = 1:length(LINE)    
    Segment     = LINE(t).Segment;
    for s = 1:length(Segment)
        seriescolor = Segment(s).classcode;
        
        d       = [Segment(s).ChdPlane.dist]';
        ha      = Segment(s).signalheight(1);
        hb      = Segment(s).signalheight(2);
        dmean   = round(mean(d)*100,1);

        names   = strcat(num2str(t),'/',num2str(s));
        moy     = scatter(ha,hb,40,seriescolor,'filled'); hold on
                  set(moy,'LineWidth',2);
                  alpha(moy,0.7)
                
        if dmean > 1 && dmean <= 2
            text(ha-7,hb+4,'! >1%','Color',[1 0.7 0],'FontSize',14)
        end
        if dmean > 2 && dmean <= 3
            text(ha-7,hb+4,'! >2%','Color',[1 0.4 0],'FontSize',14)
        end
        if dmean > 3
            text(ha-7,hb+4,'! >3%','Color','r','FontSize',14)
        end        
        text(ha+5,hb,names,'Color','k','FontSize',9)    
    end
    hold on
end
hold off

