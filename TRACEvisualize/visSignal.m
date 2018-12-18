

% VISUALIZE SIGNALS

% visualise signals of a specific trace. In a first subplot, major signals are illustrated: the alpha (normal
% and reverse) and beta (normal and reverse) as well as the signalheight illustrated with a horizontal line.
% In the second subplot, the orthogonal distance signal between chords forming a
% chord plane is illustrated (normalized to the total length of the trace).


% INPUT
% TRACE     -> structure containing basic TRACE information (any TRACE set, -
             % could also be FAULTS). Fields needed:
                    % -> TRACE.index    = ordered index array of trace 
                    %                     points within the matrix.
                    % -> TRACE.Segment  = structure of trace segments.  
                            % Segment.index     = indexes of Trace.index. If only
                            %                     one segment exists, Segment.index =
                            %                     1:length(TRACE.index)
                            % Segment.Chords    = sturcture of connecting chord information
                            %   -> Chords.alpha          = alpha for each connecting chord

                            % Segment.ChordsR   = sturcture of connecting chord information
                            %                     based on reverse orientation analysis
                            %                     same structure as Segment.Chords
                            %   -> ChordsR.alpha         = alpha for each connecting chord

                            % Segment.ChdPlane  = structure of Chord plane information
                            %   -> ChdPlane.beta         = beta through each chord plane
                            %   -> ChdPlane.dist         = orthogonal distance between
                            %                              chords that form a chord plane normalized
                            %                              to the total length of the trace

                            % Segment.ChdPlaneR = structure of Chord plane information 
                            %                     based on reverse orientation analysis
                            %                     same structure as Segment.ChdPlane
                            %   -> ChdPlaneR.beta        = beta through each chord plane
                            %   -> ChdPlaneR.dist        = orthogonal distance between
                            %                              chords that form a chord plane normalized
                            %                              to the total length of the trace

                            % Segment.signalheight  = [signalheight alpha, % signalheight beta                    


% n         -> n - trace number (within TRACE structure) 

% OUTPUT 
% fig       -> figure handle

function fig = visSignal(TRACE,t)

Segment = TRACE(t).Segment;
l1      = length(Segment);

for s = 1:l1
    
    Alpha   = [TRACE(t).Segment(s).Chords.alpha]';
    Beta    = [TRACE(t).Segment(s).ChdPlane.beta]';
    Dist    = [TRACE(t).Segment(s).ChdPlane.dist]';
    AlphaR  = [TRACE(t).Segment(s).ChordsR.alpha]';
    BetaR   = [TRACE(t).Segment(s).ChdPlaneR.beta]';
    DistR   = [TRACE(t).Segment(s).ChdPlaneR.dist]';   
    ha      =  TRACE(t).Segment(s).signalheight(1);
    hb      =  TRACE(t).Segment(s).signalheight(2);
    
    la      = length(Alpha);
    lb      = length(Beta);
    
    stna    = 99/(la-1);        % define normlized step length
    stnb    = 99/(lb-1);        % define normlized step length
    lbeg    = 100*(s-1)+1;
    lend    = 100*s;

    fig     = figure(1000);
    subpl1  = subplot(2,1,1);
    
    a   = plot(lbeg:stna:lend,Alpha,'-',lbeg:stna:lend,AlphaR,'-.');
        set(a,'Color','r','LineWidth',2); hold on
    acl = plot([lbeg,lend],[ha,ha],':');
        set(acl,'Color','r','LineWidth',0.5); hold on
    b   = plot(lbeg:stnb:lend,Beta,'-',lbeg:stnb:lend,BetaR,'-.');
        set(b,'Color','b','LineWidth',2); hold on
    bcl = plot([lbeg,lend],[hb,hb],':');
        set(bcl,'Color','b','LineWidth',0.5); hold on

    title(strcat(num2str(t),' - alpha & beta'))
    legend('alpha (normal)','alpha (reverse)','signalheight alpha',...
                          'beta (normal)','beta (reverse)','signalheight beta')
    axis([1 lend 0 180])
    
    subpl2  = subplot(2,1,2);
    
    d   = plot(lbeg:stnb:lend,Dist*1000,'-',lbeg:stnb:lend,DistR*1000,'-.');
        set(d,'Color','b','LineWidth',2); hold on  
    title(strcat(num2str(t),' - string distance'))
    axis([1 lend 0 180])

end
    hold(subpl1,'off')
    hold(subpl2,'off')
end
