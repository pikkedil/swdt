function Wnd = CDesign(varargin)

  % CDesign('Qs',144,'p',20,'x',1,'nl',2,'yd',4,'m',3)
  % CDesign('Qs',54,'p',6,'x',1,'nl',2,'yd',4,'m',3)
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

  if (nargin < 12)
    error('Too few input arguments');
  end

  paramPairs = varargin(1:end);
  [Qs,p,m,yd,nl,x] = input_parameter(paramPairs);

  [Wnd] = properties(Qs,p,m,yd,nl,x);

  [C,CRe,theta_m] = coilassign(Wnd.Qs,Wnd.p, ...
      Wnd.m,Wnd.yd,Wnd.nl,Wnd.x);
  Wnd.C = C;
  Wnd.CRe = CRe;
  Wnd.theta_m = theta_m;

  % The winding factor properties depends wheter the denominator qcn
  % is odd or even. the harmonic that corresponds to the working harmonic
  % equals nu=p. theta_m is in radians.

  Xsi = [];
  fac = m/(2*Wnd.Qc);
  for nu = 1:Wnd.Qs
    tmp = C*exp(-i*(nu-1)*theta_m)'+CRe*exp(-i*(nu-1)*theta_m)';
    if mod((nu-1)/Wnd.p,3) == 0
      Xsi = [Xsi, [nu-1; 0]];
    else
      Xsi = [Xsi, [nu-1; fac*abs(tmp(1))]];
    end
  end
  Wnd.Xsi = Xsi;

  % Calculate the winding axis in degrees. 
  
  Wnd.winding_axis = winding_axis_deg(Wnd);

return;

function [Qs,p,m,yd,nl,x,plot] = input_parameter(paramPairs)
  %
  % Process param-value pairs (no specific order)
  % 
  % Qs : number of stator slots
  % p  : number of pole pairs
  % m  : number of phases
  % yd : coil pitch
  % nl : number of layers
  % x  : slot pitch factor
  %
  args = {};
  for k = 1:2:length(paramPairs)
    param = lower(paramPairs{k});
    if (~ischar(param))
      error('Optional parameter names must be strings');
    end
    value = paramPairs{k+1};
    
    switch (param)
     case 'qs'
      Qs = value;
     case 'p'
      p = value;
     case 'm'
      m = value;
     case 'yd'
      yd= value;
     case 'nl'
      nl = value;
     case 'x'
      x = value;
     otherwise
      error(['Unrecognized option ' param '.']);
    end
  end
return

function [C,CRe,theta_m] = coilassign(Qs,p,varargin)
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
  
  if numel(varargin) == 0
      m = 3;
      yd = floor(Qs/(2*p));
      nl = 2;
      x = 1;
  else
      m = varargin{1};
      yd = varargin{2};
      nl = varargin{3};
      x = varargin{4};
  end
  
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

function [Winding] = properties(Qs,p,m,yd,nl,x)
  %
  % Distinguish between following common divisors:
  %
  % 1. ts = gcd(Qs,p)
  % 2. tc = gcd(Qc,p)
  % 3. tq = gcd(Qs,2pm)

  % Determine the coil sides per phase
  % Wnd.cspp = Wnd.Qs/Wnd.m*Wnd.nl;

  Winding = [];
  Winding.Qs = Qs;
  Winding.p = p;
  Winding.m = m;
  Winding.yd = yd;
  Winding.nl = nl;
  Winding.x = x;
  if nl == 2
      Qc = Qs;
  else
      Qc = Qs/2;
  end

  % Get the common divisors
  ts  = gcd(Qs,p);
  tc  = gcd(Qc,p);
  tqs = gcd(Qs,2*p*m);
  tqc = gcd(Qc,2*p*m);

  % Get the number of coils per pole and phase
  qcn = Qc/tqc;
  qcd = (2*p*m)/tqc;

  % Get the number of slots per pole and phase
  qsn = Qs/tqs;
  qsd = (2*p*m)/tqs;

  % Average coil pitch
  yp = Qs/(2*p);

  % Calculate yd if the user specified yd = 0. Coil span should be at least
  % one.
  if yd == 0    
      yd = floor(yp);
      if yd <= 0; yd = 1; end;
  end

  Winding.t   = tc;
  Winding.qsn = qsn;
  Winding.qsd = qsd;
  Winding.qcn = qcn;
  Winding.qcd = qcd;
  Winding.yp = yp;
  Winding.yd = yd;
  Winding.nl = nl;
  Winding.Qbasic = Qs/tc;
  Winding.pbasic = p/tc;
  Winding.Qc = Qc;

  if mod(qcd,2) == 0
      r = m;
  else
      r = 2*m;
  end

  if ts<p
      Winding.subharmonic = true;
  else
      Winding.subharmonic = false;
  end

  if mod(Winding.Qs/Winding.t,Winding.m)==0
      Winding.feasable = true;
  else
      Winding.feasable = false;
  end
return

function res = winding_axis_deg(Wnd)
  %
  % Calculate the winding axis of phase A in degrees.
  %
  z  = 0+i;
  lo = 1;
  hi = Wnd.Qbasic;
  slot_angle_rad = Wnd.theta_m(lo:hi);
  M1 = abs(Wnd.C(1,lo:hi));
  M2 = abs(Wnd.CRe(1,lo:hi));
  tmpA = M1 * exp(z*slot_angle_rad)';
  tmpB = M2 * exp(z*slot_angle_rad)';
  axis = tmpA+tmpB;
  tmpx = real(axis);
  tmpy = imag(axis);
  res  = -atan2(tmpy,tmpx)*180/pi + 180/Wnd.p + 360/(2*Wnd.Qs);

return