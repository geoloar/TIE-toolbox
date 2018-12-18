

% CLASSIFY TRACE

% Trace classification based on TIE

% INPUT
% TRACE     -> structure containing basic TRACE information (any TRACE set, -
             % could also be FAULTS). Fields needed:
                % -> TRACE.index    = ordered index array of trace 
                %                     points within the matrix. 
                % -> TRACE.matrix   = matrix size of BED or TEC
                % -> TRACE.length   = index array of length (in m) between
                %                     two individual points. Sum of the
                %                     array corresponds to the trace length
                % -> TRACE.Segment  = structure of trace segments. Fields needed:
                        % Segment.Chords    = sturcture of connecting chord information
                        %   -> Chords.alpha         = alpha for each connecting chord

                        % Segment.ChordsR   = sturcture of connecting chord information
                        %                     based on reverse orientation analysis
                        %                     same structure as Segment.Chords

                        % Segment.ChdPlane  = structure of Chord plane information
                        %   -> ChdPlane.beta         = beta through each chord plane
                      
                        % Segment.ChdPlaneR = structure of Chord plane information 
                        %                     based on reverse orientation analysis
                        %                     same structure as Segment.ChdPlane
            
% OUTPUT
% TRACE  -> structure containing TRACE information (as input) with added fields:
                        % Segment.signalheight  = [signalheight alpha, % signalheight beta                    
                        % Segment.classID       = ID of classification zone.
                        % Segment.classcode     = colorcode[r,g,b] according to % classID


function TRACE = classifyTRACE(TRACE)

    cmapblue    = flipud([0 1 1; 0 0.7 1; 0 0.4 1; 0.3 0 0.8]);
    cmapred     = flipud([0.98 0.7 0.9; 0.953 0.557 0.718; 0.933 0.247 0.463; 0.616 0.106 0.286]);
    
    r1          = 3;
    r2          = 9;
    r3          = 18;
    
for t = 1:length(TRACE)

    Seg     = TRACE(t).Segment;
    
    for s = 1:length(Seg)
        aN      = [Seg(s).Chords.alpha];
        aN      = aN(~isnan(aN));
        aR      = [Seg(s).ChordsR.alpha];
        aR      = aR(~isnan(aR));
        bN      = [Seg(s).ChdPlane.beta];
        bN      = bN(~isnan(bN));
        bR      = [Seg(s).ChdPlaneR.beta];
        bR      = bR(~isnan(bR));
        

        alpS    = sum(aN + aR);
        alpD    = abs(sum(aN)-sum(aR));
        alp     = alpS - alpD;
        meana   = alp/length(Seg(s).Chords);

        if ~isempty(bN) && ~isempty(bR) 
            betS    = sum(bN + bR);
            betD    = abs(sum(bN)-sum(bR));
            bet     = betS - betD;
            meanb   = bet/length(Seg(s).ChdPlane);
        else
            meanb   = 180;
        end
        meanr   = meana/meanb;
        
        fcurb1a = 180./(meana-r1)+r1;
        fcurb2a = 180./(meana-r2)+r2;
        fcurb3a = 180./(meana-r3)+r3;
        
        fcurb1b = 180./(meanb-r1)+r1;
        fcurb2b = 180./(meanb-r2)+r2;
        fcurb3b = 180./(meanb-r3)+r3;
        
        if meanr < 1
            cmap    = cmapred;
            if meana > fcurb3b
                g   = 4;
            end
            if meana > fcurb2b && meana <= fcurb3b
                g   = 3;
            end
            if meana > fcurb1b && meana <= fcurb2b
                g   = 2;
            end
            if meana <= fcurb1b
                g   = 1;
            end
            
            Seg(s).classID = -g;
        
        else
            cmap    = cmapblue;
            if meanb > fcurb3a
                g   = 4;
            end
            if meanb > fcurb2a && meanb <= fcurb3a
                g   = 3;
            end
            if meanb > fcurb1a && meanb <= fcurb2a
                g   = 2;
            end
            if meanb <= fcurb1a
                g   = 1;
            end
            Seg(s).classID = g;
        end
        
        Seg(s).classcode = cmap(g,:);
        Seg(s).signalheight = [meana,meanb];  
        
    end
    
    TRACE(t).Segment = Seg;
end
