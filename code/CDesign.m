function Wnd = CDesign(strval)

  % [Xsi,C,CRe,theta_m,Coil_Data,Wnd] = CDesign(varargin)
  % 
  % Calculate the winding properties and coil layout
  %
  % C and CRe
  % thata_m
  % Coil_Data
  % Wnd
  %
  % Inputs:
  % Qs, p, x, nl, yd, m
  %
  % The winding is uniquely specified by the following two numbers:
  % 1. number of slots per pole and phase
  % 2. number of coils per pole and phase
  % When these numbers are written in its reduced form the following are 
  % used for the winding layout:
  %
  % qcn/qcd: The number of slots per phase of the basic winding to which a
  % coil side must assigned to.
  %
  % J.J. Germishuizen 2007-2017

  [Qs,p,nl,yd,m,x] = getargs(strval);

  Wnd = properties(Qs,p,nl,yd,m,x);

  [C,CRe,theta_m] = coilassign(Wnd);
  Wnd.C = C;
  Wnd.CRe = CRe;
  Wnd.theta_m = theta_m;

  % The winding factor properties depends wheter the denominator qcn
  % is odd or even. The harmonic that corresponds to the working harmonic
  % equals nu=p. theta_m is in radians.

  Xsi = [];  
  for nu = 0:Wnd.Qs-1
    z   = 0+i*nu;
    mij = C*exp(z*theta_m)'+CRe*exp(z*theta_m)';
    Xsi = [Xsi, mij];
  end
  Wnd.Xsi = Xsi;

  % Calculate the winding axes in degrees. 
  
  tmpx = real(Xsi(1,p+1));
  tmpy = imag(Xsi(1,p+1));
  theta = atan2(tmpy,tmpx);
  theta_an = -theta/p*180/pi;
  theta_ma = -(theta+pi/2)/p*180/pi;
  Wnd.theta_an = theta_an;
  Wnd.theta_ma = theta_ma;

return;

function [C,CRe,theta_m] = coilassign(wnd)
  % 
  % Input Qs : Number of stator slots
  %       p  : Pole pairs
  % Optional inputs
  %       m  : Number of phases
  %       cs : Coil span
  %       nl : Double/Single layer
  %       x  : Slot pitch (x*tau_s)
  %
  % The default output is the winding factor. The slot arrangement for
  % a finite element analysis is an optional output.

  Qs = wnd.Qs;
  p  = wnd.p;
  nl = wnd.nl;
  yd = wnd.yd;
  m  = wnd.m;  
  x  = wnd.x;
  
  tau_s = 2*pi/Qs;
  phase_belt = 2*pi/(2*m);
  n_phase_belts = 2*pi*p/phase_belt;
  Np = n_phase_belts;
  C   = zeros(m,Qs);
  CRe = zeros(m,Qs);
 
  if nl == 2; x = 1; end;
  
  Return_Path = [(m+1):2*m 1:m];
  theta_m = [];
  
  for n = 1:Qs
      if mod(n,2) == 1
          % odd slot numbers
          theta_m = [theta_m, tau_s*(n-1)];
      else
          % even slot numbers
          theta_m = [theta_m, theta_m(n-1)+tau_s*(x)];
      end
  end
  
  sumC = sum(abs(C));
  sumCRe = sum(abs(CRe)); 
  for n1 = 1:Np
      theta_1 = phase_belt*(n1-1);
      theta_2 = phase_belt*(n1);
      % Determine the current phase belt
      k = mod(n1,2*m);
      if k == 0; k = 2*m; end;
      %
      % Only consider the slot for which the phase belt is valid. 
      %
      low = find(p*theta_m<=theta_1);
      if isempty(low)
          lower_bound = 1;
      else
          lower_bound = max(low);
      end;
      high = find(p*theta_m>=theta_2);
      if isempty(high)
          high_bound = Qs;
      else
          high_bound = min(high);
      end;    
      %
      for n2 = lower_bound:high_bound
          % Loop if theta_e is not in range
          theta_e = p*theta_m(n2);
          if theta_e > theta_2*1.05 
              break; 
          end;
          % Loop in case of a single layer fractional slot
          if nl==1 & wnd.qcd > 1 & yd > 1
            if mod(n2,2) == 0
              continue;
            end;
          end;
          phase_interval = false;
          % Find the nonzero elements in column of ingoing matrix. 
          % matrix is empty:    isempty(col_test_C) = 1
          % matrix not emtpty:  isempty(col_test_C) = 0              
          if nl == 1                 
              %
              % Test if coil is already assigned to current slot. Find the
              % non-zero elements. If slot is not assigned yet, then col_test 
              % is empty. Isempty returns 1 when col_test is empty. This only
              % holds for single layer. For double layer each slot must be
              % tested.
              %                 
              if sumC(n2)>=1 | sumCRe(n2)>=1
                  continue;            
              end
          else
              if sumC(n2)>=1
                  continue;            
              end
          end
          %
          % Test if current slot is a multiple of the phase belt. Override
          % the value of k to assure correct coil assignment.
          %
          phase_test = zeros(1,2*m);
          for j = 1:2*m
              dmy = mod(theta_e,2*pi);
              epsilon = abs(dmy-(j-1)*phase_belt);
              if  epsilon < 1e-10
                  % override k
                  k = j;
                  if j==k
                      phase_interval = true;
                  end
              end
          end
          if k <= m
              row = k;
          else
              row = k-m;
          end
          %
          % Slot found when slot angle within phase belt or phase interval.
          %
          if (theta_e >= theta_1) & (theta_e < theta_2) | phase_interval
              %
              % Assign the in-going coil side
              % (-1)^(k-1) = -1*cos(mod(k,2)*pi)
              %
              C(row,n2) = (-1)^(k-1);              
              %
              % Determine the return coil side -> fisrt the slot number
              %
              if (n2+yd) <= Qs
                  PhRe = n2+yd;
              else
                  PhRe = mod(n2+yd,Qs);
              end
              CRe(row,PhRe) = -1*C(row,n2);
              sumC = sum(abs(C));
              sumCRe = sum(abs(CRe)); 
          end
      end
  end
return