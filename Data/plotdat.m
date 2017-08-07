%% %%%%%%%%%%%%%%%%%%%%%% plotDat %%%%%%%%%%%%%%%%%%%%%%%
% Matlab function to plot data from .dat files
% Example: plotdat('TT/PCFB_1of4_TT.dat')
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotdat(filename)
  set(0,'defaulttextinterpreter','Latex');
  set(0,'defaultaxesfontsize', 20);                
  set(0,'defaulttextfontsize', 20);       
  
  delimiterIn = ' ';
  headerlinesIn = 3;
  A = importdata(filename, delimiterIn, headerlinesIn);

  vdd     = A.data(:,1);        % Supply Voltage        [mV]
  tempc   = A.data(:,2);        % Temperature           [C]
  leakage = A.data(:,3).*1e-9;  % Leakge Current        [A]
  fwdUp   = A.data(:,4).*1e-9;  % Backward Latency Up   [s]
  fwdDn   = A.data(:,5).*1e-9;  % Forward Latency Down  [s]
  backUp  = A.data(:,6).*1e-9;  % Backward Latency Up   [s]
  backDn  = A.data(:,7).*1e-9;  % Backward Latency Down [s]
  tau     = A.data(:,8).*1e-9;  % Cycle Time            [s]
  EpC     = A.data(:,9).*1e-15; % Energy per Cycle      [J]

  tdcs = unique(tempc);         % Get unique temperature points
  ends = find( diff(tempc));    % Find the points tempearture changes
  ends = [ends; length(vdd)];   % Get the end points for each curve
  
  % Some recommended reading:
  % http://ieeexplore.ieee.org/document/7152689/?arnumber=7152689
  % + others by same authors 
  
  % Todo: Find better place for link above ...

  %% Plot 
  plotThroughput(1, vdd, tau, tdcs, ends);
  plotEvsTau(2, vdd, EpC, tau, tdcs, ends);
  plotET(3, vdd, tau, EpC, tdcs,ends);      
  plotET2(4, vdd, tau, EpC, tdcs, ends);   

end 
%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&
%% %%%%%%%%%%%%%%%%%% plotThroughput %%%%%%%%%%%%%%%%%%%%%
function plotThroughput(figNo, vdd, tau, tdcs, ends)
   figure(figNo);
   xlabel('$V_{DD}$  $[mV]$');
   ylabel('Peak Throughput  [GHz]');
   title('Peak-Throughput vs. Supply Voltage, TT-Corner');
   grid on; grid minor;
   hold on;
   cStart = 1;
   for i=1:size(tdcs)
       x = vdd(cStart:ends(i));
       y = 1e-9./tau(cStart:ends(i));
       plot(x, y, 'Color', getColor(tdcs(i)));
       cStart = ends(i) + 1;
       legendInfo{i} = sprintf( '$^{\\circ} C$ = %d', tdcs(i));
   end
   xlim([0 950]);
   hold off;
   legend(legendInfo, 'Location','best','Interpreter','latex');
   saveFig(figNo);
end
%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&
%% %%%%%%%%%%%%%%%%%%%%%%% plotET %%%%%%%%%%%%%%%%%%%%%%%%
function plotET(figNo, vdd, tau, EpC, tdcs, ends)
   figure(figNo);
   xlabel('$V_{DD}$  $[mV]$');
   ylabel('E$\tau$ $[10^{{-}24}$ $J \times s]$');
   title('E$\tau$ vs. Supply Voltage, TT-Corner');
   grid on; grid minor;
   hold on;
   start = 1;
   for i=1:size(tdcs)
       y = EpC(start:ends(i)).*tau(start:ends(i)).*(1e9*1e15);
       x = vdd(start:ends(i));
       [M, I] = min(y);
       %fprintf(' Temperature = %d, Min ET = %d, Vdd = %d\n', tdcs(i), M, x(I));
       plot(x, y, 'Color', getColor(tdcs(i)));
       start = ends(i) + 1;
       legendInfo{i} = sprintf( '$^{\\circ} C$ = %d', tdcs(i));
   end
   hold off;
   xlim([425 950]);
   legend(legendInfo, 'Location','best','Interpreter','latex');
   saveFig(figNo);
end
%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&
%% %%%%%%%%%%%%%%%%%%%%%% plotET^2 %%%%%%%%%%%%%%%%%%%%%%%
function plotET2(figNo, vdd, tau, EpC, tdcs, ends)
   figure(figNo);
   xlabel('$V_{DD}$  $[mV]$');
   ylabel('E$\tau^2$ $[10^{{-}33}$ $J \times s^2]$');
   title('E$\tau^2$ vs. Supply Voltage, TT-Corner');
   grid on; grid minor;
   hold on;
   start = 1;
   for i=1:size(tdcs)
       y = EpC(start:ends(i)).*tau(start:ends(i)).^2.*(1e9*1e9*1e15);
       x = vdd(start:ends(i));
       [M, I] = min(y);
       fprintf(' Temperature = %d, Min ET^2 = %d E-33 J*s^2 @ VDD = %d\n', tdcs(i), M, x(I));
       plot(x, y, 'Color', getColor(tdcs(i)));
       start = ends(i) + 1;
       legendInfo{i} = sprintf( '$^{\\circ} C$ = %d', tdcs(i));
   end
   hold off;
   xlim([425 950]);
   legend(legendInfo, 'Location','best','Interpreter','latex');
   saveFig(figNo);
end
%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&
%% %%%%%%%%%%%%%%%%%%%% plotEvsTau %%%%%%%%%%%%%%%%%%%%%%%
function plotEvsTau(figNo, vdd, EpC, tau, tdcs, ends)
   figure(figNo);
   xlabel('$\tau$  $[ns]$');
   ylabel('$Energy$ $[fJ / cycle]$');
   title('Energy vs. Cycle Time, TT-Corner');
   grid on;
   hold on;
   cStart = 1;
   for i=1:size(tdcs)
       x = tau(cStart:ends(i)).*1e9;
       y = EpC(cStart:ends(i)).*1e15;
       plot(x, y, 'Color', getColor(tdcs(i)));
       cStart = ends(i) + 1;
       legendInfo{i} = sprintf( '$^{\\circ} C$ = %d', tdcs(i));
   end
   xlim([-1 20]);
   hold off;
   legend(legendInfo, 'Location','best','Interpreter','latex');
   saveFig(figNo);
end
%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&
%% %%%%%%%%%%%%%%%%%%%%%% plotEpC %%%%%%%%%%%%%%%%%%%%%%%%
function plotEpC(figNo, vdd, EpC, tdcs, ends)
   figure(figNo);
   xlabel('$V_{DD}$  $[mV]$');
   ylabel('Energy per Cycle $[fJ]$');
   title('Energy per Cycle vs. Supply Voltage, TT-Corner');
   grid on; grid minor;
   hold on;
   start = 1;
   for i=1:size(tdcs)
       y = EpC(start:ends(i)).*1e15;
       x = vdd(start:ends(i));
       [M, I] = min(y);
       %fprintf('Temperature = %d, Min Energy = %d, Vdd = %d\n', tdcs(i), M, x(I));
       plot(x, y, 'Color', getColor(tdcs(i)));
       start = ends(i) + 1;
       legendInfo{i} = sprintf( '$^{\\circ} C$ = %d', tdcs(i));
   end
   hold off;
   xlim([0 450]);
   legend(legendInfo, 'Location','best','Interpreter','latex');
   saveFig(figNo);
end
%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&
%% %%%%%%%%%%%%%%%%%%%%%% getColor %%%%%%%%%%%%%%%%%%%%%%%
function [RGB] = getColor(temperature)
    switch temperature
        case -50   
            RGB = [0.5412, 0.1686, 0.8863];
        case -25
            RGB = [0, 0, 1];
        case 0
            RGB = [0, 1, 1];          
        case 25
            RGB = [0, 1, 0];           
        case 50
            RGB = [1, 1, 0];
        case 75
            RGB = [1, 0.2706, 0];           
        case 100
            RGB = [1, 0, 0];                
        case 125
            RGB = [1, 0, 1];              
        otherwise
    end
end
%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%
%% %%%%%%%%%%%%%%%%%%%%%% saveFig %%%%%%%%%%%%%%%%%%%%%%%
function saveFig(fn)                                    % Function to Save a Figure
    set(gcf, 'PaperPosition', [0 0 16 9]);              % Position plot at left hand corner
    set(gcf, 'PaperSize', [16 9]);                      % Set paper width 16 and height 9.
    sName = sprintf('Fig %d', fn);                      % Used in Save name 
    saveas(gcf, sName, 'pdf');                          % Save figure
end                                                     % End function
%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%
