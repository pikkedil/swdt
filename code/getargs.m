function [Qs,p,nl,yd,m,x] = getargs(arg)
  %
  % Extract the parameters: order is important!!
  %
  % Process param-value pairs (no specific order)
  % 
  % Qs : number of stator slots
  % p  : number of pole pairs
  % nl : number of layers
  % yd : coil pitch
  % m  : number of phases
  % x  : slot pitch factor
  % 
  par = [findstr(arg,'Q'),...
         findstr(arg,'p'),...
         findstr(arg,'nl'),...
         findstr(arg,'yd'),...
         findstr(arg,'m'),...
         findstr(arg,'x')];
  for i=1:6
    switch (i)
      case 1
        lo = par(i)+1;
        hi = par(i+1)-1;
        tmp = str2num(arg(lo:hi));
        Qs = tmp;
      case 2
        lo = par(i)+1;
        hi = par(i+1)-1;
        tmp = str2num(arg(lo:hi));
        p  = tmp;
      case 3
        lo = par(i)+2;
        hi = par(i+1)-1;
        tmp = str2num(arg(lo:hi));
        nl = tmp;
      case 4
        lo = par(i)+2;
        hi = par(i+1)-1;
        tmp = str2num(arg(lo:hi));
        yd = tmp;
      case 5
        lo = par(i)+1;
        hi = par(i+1)-1;
        tmp = str2num(arg(lo:hi));
        m  = tmp;
      case 6
        lo = par(i)+1;
        hi = length(arg);
        tmp = str2num(arg(lo:hi));
        x  = tmp;
    end 
  end
  return
end
   