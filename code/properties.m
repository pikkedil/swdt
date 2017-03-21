function Winding = properties(Qs,p,nl,yd,m,x)
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
  Winding.ypn = Qs/(gcd(Qs,2*p));
  Winding.ypd = (2*p)/(gcd(Qs,2*p));

  % Calculate yd if the user specified yd = 0. Coil span should be at least
  % one.
  if yd == 0 & nl == 1    
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
  
  Ql = Winding.nl*Winding.Qbasic/2;
  
  for n=1:1000
    tmp = mod((n*Ql+1), Winding.pbasic);
    if tmp == 0
      Winding.yc = (n*Ql+1) / Winding.pbasic;
      Winding.n = n;
      break;
    end
  end

  if mod(qcd,2) == 0
      Winding.r = m;
  else
      Winding.r = 2*m;
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