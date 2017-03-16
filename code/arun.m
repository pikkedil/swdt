function wdt = arun(val)
    %
    % This example m-file is a driver for main function CDesign.m. Test cases
    % given here are for three phases. The test cases are defined as follows:
    %
    % 1. wdt = CDesign('Qs',30,'p',5, 'x',1,'nl',2,'yd',3,'m',3)
    % 2. wdt = CDesign('Qs',54,'p',6, 'x',1,'nl',2,'yd',4,'m',3)
    % 3. wdt = CDesign('Qs',30,'p',10,'x',1,'nl',1,'yd',1,'m',3)
    % 4. wdt = CDesign('Qs',30,'p',10,'x',1,'nl',2,'yd',1,'m',3)
    % 5. wdt = CDesign('Qs',30,'p',5, 'x',1,'nl',1,'yd',3,'m',3)
    % 
    % To run the function:
    %
    % arun(3)
    %
    % to run test case number 3.
    %
    if nargin == 0
        fprintf('Type <%s\n%s\n','help arun>','for more information');
        return;
    end
    switch val
        case 1
            wdt = CDesign('Qs',30,'p',10,'x',1,'nl',1,'yd',1,'m',3);
            filename = 'fig6b.tex';
        case 2            
            wdt = CDesign('Qs',30,'p',10,'x',1,'nl',2,'yd',1,'m',3);
            filename = 'fig7b.tex';
        case 3
            wdt = CDesign('Qs',30,'p',5, 'x',1,'nl',1,'yd',3,'m',3);
            filename = 'fig8b.tex';
        case 4
            wdt = CDesign('Qs',30,'p',5, 'x',1,'nl',2,'yd',3,'m',3);
            filename = 'fig9b.tex';
        case 5            
            wdt = CDesign('Qs',54,'p',6, 'x',1,'nl',2,'yd',4,'m',3);
        case 6
            wdt = CDesign('Qs',60,'p',2, 'x',1,'nl',2,'yd',13,'m',3);
        otherwise
            disp('Invalid test case numer. Type help arun');
            wdt = NaN;
            return;
    end
    
    % Qs            : number of stator slots
    % p             : number of pole pairs
    % m             : number of phases
    % yd            : coil pitch
    % nl            : number of layers
    % x             : slot pitch (set default to 1)
    % t             : symmetry factor
    % qsn           : see definition 3.1
    % qsd           : see definition 3.1
    % qcn           : see definition 3.2
    % qcd           : see definition 3.2
    % yp            : average coil pitch
    % Qbasic        : basic winding number of slots
    % Qc            : number of coils
    % C             : in-going coil sides
    % CRe           : out-going coil sides
    
    basic.m = wdt.m;
    basic.Q = wdt.Qs;
    basic.p = wdt.p;
    basic.yd = wdt.yd;
    basic.nl = wdt.nl;
    basic.Qb = wdt.Qbasic;
    basic.pb = wdt.p/wdt.t;
    
    % Construct the winding factor
    fac = wdt.m/(2*wdt.Qc);
    kw = fac*abs(wdt.Xsi(1,basic.p+1));
    
    clf;
    if basic.nl == 1
        bot = zeros(1,basic.Qb);
        mmf = zeros(1,basic.Qb); 
        M1 = wdt.C;
        M2 = wdt.CRe;
        for i = 1:basic.Qb
            for ii = 1:wdt.m
                bot(i) = bot(i) + M1(ii,i)*ii + M2(ii,i)*ii;
                mmf(i) = mmf(i) + ...
                    1/basic.nl*(M1(ii,i)*cos((ii-1)*2*pi/wdt.m) ...
                + M2(ii,i)*cos((ii-1)*2*pi/wdt.m));
             end
        end      
    else
        bot = zeros(1,basic.Qb);
        top = zeros(1,basic.Qb); 
        mmf = zeros(1,basic.Qb); 
        M1 = wdt.C;
        M2 = wdt.CRe;
        for i = 1:basic.Qb
            for ii = 1:wdt.m
                bot(i) = bot(i) + M1(ii,i)*ii;
                top(i) = top(i) + M2(ii,i)*ii;
                mmf(i) = mmf(i) + ...
                  1/basic.nl*(M1(ii,i)*cos((ii-1)*2*pi/wdt.m) ...
                  + M2(ii,i)*cos((ii-1)*2*pi/wdt.m));
             end
        end    
    end    
    %
    % Generate the slot numbers
    %
    x_str = {};
    x_str(1) = ' ';
    for i = 2:2*basic.Qb+1
        if mod(i,2) == 0
            x_str(i) = num2str(i/2);
        else
            x_str(i) = ' ';
        end
    end
    %
    % A scaling factor is used to map the total number of 
    % slots to 360 degrees. Each slot has 4 parts.
    %
    fac = 1/(4*basic.Q)*360;
    if basic.m == 3
        figure(1);
        clf;
        if ~ishold            
            hold on;
        end
        %
        % Plot the coil sides in the slots
        %
        for ii=1:basic.Qb
            [x,y] = slot(ii);
            plot(x*fac,y);
            if basic.nl == 1
                [x,y] = rect(ii,basic.nl,0,basic.yd);
                fill(x*fac,y,colour(bot(ii)));
            else
                [x,y] = rect(ii,basic.nl,0,basic.yd);
                fill(x*fac,y,colour(bot(ii)));
                [x,y] = rect(ii,basic.nl,1,basic.yd);
                fill(x*fac,y,colour(top(ii)));
            end
        end   
        %
        % This part adds the slot mmf.
        %
        x = [4:4:basic.Qb*4]-2;
        bar(x*fac,mmf,0.5,'k');
        % x-axis
        set(gca,'xlim',[0 basic.Qb*4]*fac);
        set(gca,'xtick',fac*[0:x(end)/(2*basic.Qb-1):x(end)])
        set(gca,'xticklabel',x_str)
        % y-axis
        set(gca,'ylim',[-1.75 1]);
        set(gca,'ytick',[-1.75:0.25:1]);
        set(gca,'yticklabel',{' ', ' ', ' ', '-1.0', ' ', '-0.5',...
            ' ', ' ', ' ', '0.5', ' ', '1.0'});
        xlabel('Slot number')
        %
        % Add the working harmonic. The calculated winding axis is in
        % degrees. Add half slot pitch. 
        %
        wnd = [];
        slotpitch_deg = 360/basic.Q;
        wnd.axis = wdt.theta_ma+slotpitch_deg/2;
        phi = wnd.axis*basic.p*pi/180+pi/2;
        xw = linspace(0,basic.pb*2*pi,100*basic.pb);
        yw = kw*cos(xw-phi);
        fac = 180/pi*basic.Qb/basic.Q/basic.pb;
        plot(xw*fac,yw,'k--');
        hold off;
        grid on;
    end
    %matlab2tikz(filename,'width','\fwidth');
end