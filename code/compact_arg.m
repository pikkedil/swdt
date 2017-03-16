function [Qs,p,nl,yd,m,x] = compact_arg(arg)
  %
  % Extract the parameters: order is important!!
  %
  x = 1;
  par = [findstr(arg,'Q'),...
         findstr(arg,'p'),...
         findstr(arg,'nl'),...
         findstr(arg,'yd'),...
         findstr(arg,'m')];
  for i=1:5
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
        hi = length(arg);
        tmp = str2num(arg(lo:hi));
        m  = tmp;
    end 
  end
return