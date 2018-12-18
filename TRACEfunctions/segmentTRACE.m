

% TRACE SEGMENTATION 

% Segments the trace according to inflexion points

% INPUT
% TRACE     -> structure containing basic TRACE information (any TRACE set, -
             % could also be FAULTS). Fields needed:
                % -> TRACE.index    = ordered index array of trace 
                %                     points within the matrix.                
% X, Y, Z   -> Coordinate vectors (see loadCoord.mat)

% OUTPUT
% TRACE  -> structure containing TRACE information (as input) with added fields:
                % -> TRACE.Segment  = structure of trace segments. Fields:
                        % Segment.index     = indexes of Trace.index. If only
                        %                     one segment exists, Segment.index =
                        %                     1:length(TRACE.index)

                        % Segment.indexR    = indexes of Trace.index by
                        %                     starting the analysis at the other end of the
                        %                     trace
                    
                    
function TRACE = segmentTRACE(TRACE,mX,mY,Z)

for t = 1:length(TRACE)
    % scalar definitions
    ind     = TRACE(t).index;
    n       = length(ind);
    d       = 2;            % steps between connecting points to create a vector v
    l       = n - d;        % final vector length of connected paths
    
    % allocations
    v       = zeros(l,3);  
    angle   = zeros(l,1);

    % segmentation
    if length(ind) > d
        k        = 1:l;
        v(k,1)  = mX(ind(k+d)) - mX(ind(k));
        v(k,2)  = mY(ind(k+d)) - mY(ind(k));
        v(k,3)  = Z(ind(k+d))  - Z(ind(k));
        
        % calculation of angle between two vectors
        for m = 1:l
            angle(m)    = angleBtwVec(v(m,:),v(1,:));
        end
        
        % my weird unelegant hand-made way of doing a moving average (because I have
        % to understand it myself :))
        % I guess one could use a matlab function which does this in one
        % line
        anmean1         = angle; 
        anmean2         = angle;    
        m = 2:l;
        anmean1(m)      = (angle(m)+angle(m-1))/2;
        p = 1:l-1;
        anmean2(p)      = (angle(p+1)+angle(p))/2;
        
        
        if rem(n,4) > 0
            smo = (n-rem(n,4))/2;
        else
            smo = n/2;
        end
        
        P = 1;
        while P < smo
            anmean1(m)      = (anmean1(m)+anmean1(m-1))/2;
            anmean2(p)      = (anmean2(p+1)+anmean2(p))/2;
            P = P+1;
        end
        
        % final moving average with 'smo' itinerations
        anmean          = cosd([anmean1(smo/2+1:end);anmean2(end-smo+1:end-smo/2)])*n;

        % finding positive and negative peaks (--> inflexion points) by
        % defining minimum peak width and minimum peak prominence

        % threshold definition(arbitrarily, resp. through try outs)
        prom = 100; width = n/10; %prom2 = 100; width2 = n/20;
        
        [~,ppi]  = findpeaks(anmean,    'MinPeakProminence',prom,   'MinPeakWidth',width);
        [~,npi]  = findpeaks(-anmean,   'MinPeakProminence',prom,   'MinPeakWidth',width);

        pind     = sort([1;ppi;npi;l]);
        pval     = anmean(pind);
  
        for jada = 1:2
            if length(pval) > 2
                [~,ploc]        = findpeaks(pval);
                [~,nloc]        = findpeaks(-pval);
            else
                ploc = [];
                nloc = [];
            end
            pind = sort([1;pind(ploc);pind(nloc);l]);
        end

        seg             = sort([pind(ploc); pind(nloc)]);
        clear('ploc','nloc');

        % defining Segmentations and storing it in the structure
        Segment         = struct('index',[],'indexR',[],'angles',[],'almean',[]);
        Segment.angles  = angle;
        Segment.almean  = anmean;

        if ~isnan(seg)
            Segment(1).index             = 1:seg(1)+ d;
            if length(seg) > 1
                for s = 2:length(seg)
                    Segment(s).index     = seg(s-1):seg(s)+ d;
                end
            end
            Segment(length(seg)+1).index = seg(end):n;
        else
            Segment(1).index             = 1:n;
        end

    else
        Segment(1).index = [];
    end
    

    for s = 1:length(Segment)
        indMin = Segment(s).index(1);
        indMax = Segment(s).index(end);
        Segment(s).indexR = n+1-indMax:n+1-indMin;
    end
    
    TRACE(t).Segment = Segment; 
end
