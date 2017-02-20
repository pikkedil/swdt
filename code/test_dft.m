function shift = test_dft(opt,phi,dc)
  % 
  % Simple function to test the Matlab DFT. Define a cos function,
  % sample it and then apply the DFT. The function is defined between
  % theta_1 and theta_2.
  %
  % test_dft(opt,phi,dc)
  %
  % opt: opt = 1 -> default DFT; opt = 2 -> manuel DFT
  % phi: phase shift in degree
  % dc : dc offset value
  %
  % Author: J.J. Germishuizen

  if nargin != 3
    disp('Type help test_dft');
    return;
  end
  
  theta_1 = -pi;
  theta_2 = theta_1+2*pi;
  x   = linspace(theta_1,theta_2,100);
  phi = phi*pi/180;
  y0  = dc;
  y   = 1.0*cos(x-phi)+y0;

  % Sample the function over the interval (theta_1,theta_2) 
  N_sample = 14;
  xx = linspace(theta_1,theta_2,N_sample);
  yy = interp1(x,y,xx,'spline');

  % Now perform the DFT. The primary required information are
  % the amplitude and the phase. The expected harmonics are known.
  % Keep track of the offset angle theta_1.
  N  = length(xx)-1;
  switch opt
    case 1
      disp('Build-in function');
      Y  = 2*fft(yy(1:N))/N;
    case 2
      disp('Manual function');
      Y_real = 0;
      Y_imag = 0;
      Y      = [];
      for k=1:N
        Y_real = 0;
        Y_imag = 0;  
        for j=1:N
          arg    = -2*pi/N*(j-1)*(k-1);
          Y_real = Y_real + yy(j)*cos(arg);
          Y_imag = Y_imag + yy(j)*sin(arg);    
        end  
        Y(k) = 2*(complex(Y_real,Y_imag))/N;
      end
    otherwise
      disp('Invalid value for opt')
  end
  
  Yp = abs(Y(2));
  Y0 = abs(Y(1))/2;
  tmp_re = real(Y(2));
  tmp_im = imag(Y(2));
  ph = -atan2(tmp_im,tmp_re)+theta_1;
  if ph > pi
    ph = 2*pi+ph;
  end
  if ph < -pi
    ph = 2*pi+ph;
  end
  shift = ph;

  % Construct the fundamental from Yp and ph.
  yf = Yp*cos(x-ph)+Y0;

  clf
  plot(x*180/pi,y,'k',xx*180/pi,yy,'o',x*180/pi,yf,'r--')
  legend('reference','sampled data','result')
  axis tight;
  grid on;
  set(gca,'fontsize',12);
  set(gca,'xtick',[theta_1*180/pi:180:theta_2*180/pi]);
  xcoord = (theta_1 + (theta_2-theta_1)/8)*180/pi;
  text(xcoord,Y0-Yp*0.7,['input: phi = ' num2str(phi*180/pi)]);
  text(xcoord,Y0-Yp*0.9,['result: phase = ' num2str(ph*180/pi)]); 
  xlabel('x'); 
  ylabel('y')
end  