%% function aligni0vn test demo
clear;close all;

glvs;
[imu, avp0, ts] = imufile('lasergyro.imu');
att = aligni0vn(imu(1:300/ts,:), avp0(7:9)', 180);

%% MTI-300 AHRS
clear;close all;

glvs

ts = 1/100;
pos0 = posset(39.56,0,0);
load('home21.mat'); dd = data; % cnt ax ay az wx wy wz mx my mz pitch roll yaw
imu = [dd(:,[5:7,2:4])*ts, cnt2t(dd(:,1),ts)]; 
% imuplot(imu);
% mag = [dd(:,8:10), imu(:,end)]; magplot(mag);
att = [dd(:,11:13)*glv.deg, imu(:,end)]; insplot(att,'a');

att0 = aligni0(datacut(imu,0,300), pos0);

avp00=[att0;pos0];
% avp00=[att(1,1:3)';pos0];
avp = inspure(datacut(imu,300,inf), avp00, 'f', 1);
% insplot(avp,'a');

%% IMU-GPS-CNS
close all;clear;

glvs;
ts = 1/200;
load imugpscns20211109.mat;

imuplot(imu); 
gpsplot(gps);

atts = qis(:,1:4);
Cie = cnsCie(t00(1:3), t00(4), -0.107, 37); % t00 is the UTC first sampling epoch
for k=1:length(qis)
    Cen = pos2cen(getat(gps(:,4:7),qis(k,5)));
    Cin = Cie*rxyz(qis(k,5)*glv.wie,'z')*Cen;
    atti = m2att(Cin'*q2mat(qis(k,:))); % Cns
    atts(k,:) = [ atti; qis(k,5) ]';
end

insplot(atts,'a');
att = aligni0(datacut(imu,100,300), gps(1,4:6)');
avp = inspure(datacut(imu,300,inf), [att;gps(1,4:6)'], 'H');

%  avpcmpplot(atts, avp(:,[1:3,end]), 'a', 'mu');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% error of pitch, roll and yaw between pure ins and cns
myfigure;
t1 = atts(:,end);
t2 = avp(:,end);
subplot(221), plot(t1, atts(:,1:2)/glv.deg,'-.','LineWidth',2), xygo('pr');  
hold on, plot(t2, avp(:,1:2)/glv.deg), xygo('pr'); %legend('Pitch','Roll');
legend('Pitch Ref.', 'Roll Ref.', 'Pitch', 'Roll');
subplot(223), plot(t1, yawplot(atts(:,3)/glv.deg)), xygo('y'); 
hold on, plot(t2, yawplot(avp(:,3)/glv.deg)), xygo('y'); %legend('Yaw');
legend('Yaw Ref.', 'Yaw');
err = avpcmp(avp(:,[1:3,end]), atts(:,[1:3,end]), 'mu'); 
t3 = err(:,end);
subplot(222), hold on, plot(t3, err(:,1:2)/glv.min); xygo('mu');   mylegend('mux','muy'); 
subplot(224), hold on, plot(t3, err(:,3)/glv.min); xygo('mu');   mylegend('muz'); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% error of velocity and position between pure ins and gps
t1 = gps(:,end);
t2 = avp(:,end);
vnS = gps(:,1:3); posS = gps(:,4:6);
dxyz = pos2dxyz(avp(:,7:9));
%%%%%%%%%
myfigure;
% pos
subplot(221), plot(t1, (posS(:,1)-posS(1,1))*glv.Re,'r-'); 
hold on, plot(t1, (posS(:,2)-posS(1,2))*cos(posS(1,1))*glv.Re,'g-'); 
hold on, plot(t1, posS(:,3)-posS(1,3),'b-'); 
hold on, plot(t2, dxyz(:,2),'r--'); xygo('DP');
hold on, plot(t2, dxyz(:,1),'g--'); 
hold on, plot(t2, dxyz(:,3),'b--'); 
legend('gps \Delta P_E','gps \Delta P_N','gps \Delta P_U','ins \Delta P_E','ins \Delta P_N','ins \Delta P_U');
% V_E
subplot(222), plot(t1, vnS(:,1)); xygo('V');
hold on, plot(t2, avp(:,4)); 
legend('gps V_E','ins V_E');
% V_N
subplot(223), plot(t1, vnS(:,2)); xygo('V');
hold on, plot(t2, avp(:,5)); 
legend('gps V_N','ins V_N');
% V_U
subplot(224), plot(t1, vnS(:,3)); xygo('V');
hold on, plot(t2, avp(:,6)); 
legend('gps V_U','ins V_U');

%% MEMS/FOG/GPS
close all;clear;
glvs;
ts = 1/100;
t1 = 700; t2 = 10800;
load lb_memsfoggps;
% imuplot(imuFOG); imuplot(imuMTI); gpsplot(gps); insplot(attMTI, 'a');
att0 = aligni0(imuFOG(400/ts:t1/ts,:), gps(1,4:6)');
avp = inspure(imuFOG(t1/ts:t2/ts,:), [att0; getat(gps,t1)], 'H');
avpcmpplot(avp(:,[1:3,end]), datacut(attMTI,t1,t2), 'a', 'datt');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% error of pitch and roll between pure ins and MTi-710 AHRS
myfigure;
atts=datacut(attMTI,t1,t2);
t11 = atts(:,end);
t22 = avp(:,end);
subplot(221), plot(t11, atts(:,1:2)/glv.deg,'-.','LineWidth',2), xygo('pr');  
hold on, plot(t22, avp(:,1:2)/glv.deg), xygo('pr'); %legend('Pitch','Roll');
legend('Pitch AHRS', 'Roll AHRS', 'Pitch pureINS', 'Roll pureINS');
err = avpcmp(avp(:,[1:3,end]), atts(:,[1:3,end]), 'datt'); 
t3 = err(:,end);
subplot(222), hold on, plot(t3, err(:,1:2)/glv.min); xygo('datt');   mylegend('mux','muy'); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% integrated navigation 
avp0 = [att0; getat(gps,t1)];
ins = insinit(avp0, ts);
avperr = avperrset([10*60;30*60], 10, 100);
imuerr = imuerrset(1000, 10000, 0.1, 100);
Pmin = [avperrset([0.5,2],0.01,0.01); gabias(1, [100,100]); [0.01;0.01;0.01]; 0.01].^2;
Rmin = vperrset(0.1, 0.1).^2;
[avp1, xkpk1, zkrk1, sk] = sinsgps(imuMTI(t1/ts:t2/ts,:), gps, ins, avperr, imuerr, rep3(1), 0.1, vperrset(1,10), Pmin, Rmin, 'avped');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compare pure ins and integrated navigation
avpcmpplot(avp1, avp, 'avp', 'mu');
% error of pitch and roll between pure ins and integrated navigation 
myfigure;
t11 = avp1(:,end);
t22 = avp(:,end);
subplot(221), plot(t11, avp1(:,1:2)/glv.deg,'-.','LineWidth',2), xygo('pr');  
hold on, plot(t22, avp(:,1:2)/glv.deg), xygo('pr'); %legend('Pitch','Roll');
legend('Pitch INS&GPS', 'Roll INS&GPS', 'Pitch pureINS', 'Roll pureINS');
subplot(223), plot(t11, yawplot(avp1(:,3)/glv.deg),'-.','LineWidth',2), xygo('y'); 
hold on, plot(t22, yawplot(avp(:,3)/glv.deg)), xygo('y'); %legend('Yaw');
legend('Yaw INS&GPS', 'Yaw pureINS');
err = avpcmp(avp(:,[1:3,end]), avp1(:,[1:3,end]), 'datt'); 
t33 = err(:,end);
subplot(222), hold on, plot(t33, err(:,1:2)/glv.min); xygo('datt');   mylegend('mux','muy'); 
subplot(224), hold on, plot(t33, err(:,3)/glv.min); xygo('mu');   mylegend('muz'); 

%% IMU-ISA-100C
close all;clear;
glvs;
ts = 1/100;
load imuisa100avpgsp.mat
%%%%%%%%%%%%%%%%%%%%%%%
% integrated navigation 
att = aligni0(imu(600/ts:700/ts,:), gps(1,4:6)');
ins = insinit([att;gps(1,1:6)'], ts);
avperr = avperrset([60;300], 1, 10);
imuerr = imuerrset(0.1, 1000, 0.01, 25);
Pmin = [avperrset([0.2,1.0],0.01,0.2); gabias(0.01, [10,10]); [0.01;0.01;0.01]; 0.001].^2;
Rmin = vperrset(0.1, 0.3).^2;
[avp1, xkpk1, zkrk1, sk1] = sinsgps(imu(700/ts:5500/ts,:), gps, ins, avperr, imuerr, rep3(1), 0.1, vperrset(0.1,10), Pmin, Rmin, 'avped');
avpcmpplot(avpie, avp1);
%%%%%%%%%%%%%%%%%%%%%%%
% pure INS
imu1 = imudeldrift(imu, avp1, 4000);
att1 = aligni0(imu1(400/ts:700/ts,:), gps(1,4:6)');
avp2 = inspure(imu1(700/ts+1:end,:),[att1;gps(1,4:6)'],'H');
avpcmpplot(avpie, avp2);
% error of pitch and roll between pure ins and integrated navigation 
myfigure;
t11 = avpie(:,end);
t22 = avp2(:,end);
subplot(221), plot(t11, avpie(:,1:2)/glv.deg,'-.','LineWidth',2), xygo('pr');  
hold on, plot(t22, avp2(:,1:2)/glv.deg), xygo('pr'); %legend('Pitch','Roll');
legend('Pitch INS&GPS', 'Roll INS&GPS', 'Pitch pureINS', 'Roll pureINS');
subplot(223), plot(t11, yawplot(avpie(:,3)/glv.deg),'-.','LineWidth',2), xygo('y'); 
hold on, plot(t22, yawplot(avp2(:,3)/glv.deg)), xygo('y'); %legend('Yaw');
legend('Yaw INS&GPS', 'Yaw pureINS');
err = avpcmp(avp2(:,[1:3,end]), avpie(:,[1:3,end]), 'mu'); 
t33 = err(:,end);
subplot(222), hold on, plot(t33, err(:,1:2)/glv.min); xygo('mu');   mylegend('mux','muy'); 
subplot(224), hold on, plot(t33, err(:,3)/glv.min); xygo('mu');   mylegend('muz'); 

%% simulated IMU data generation
close all;clear;
glvs
ts = 0.1;       % sampling interval
avp0 = [[0;0;0]; [0;0;0]; glv.pos0]; % init avp
% trajectory segment setting
xxx = [];
seg = trjsegment(xxx, 'init',         0);
seg = trjsegment(seg, 'uniform',      40);
seg = trjsegment(seg, 'accelerate',   20, xxx, 1);
seg = trjsegment(seg, 'uniform',      100);
seg = trjsegment(seg, 'turnleft',  10*5, 1, xxx, 4);
seg = trjsegment(seg, 'uniform',      100);
seg = trjsegment(seg, 'turnright',   45, 2, xxx, 4);
seg = trjsegment(seg, 'uniform',      100);
seg = trjsegment(seg, 'climb',        30, 2, xxx, 50);
seg = trjsegment(seg, 'uniform',      60);
seg = trjsegment(seg, 'turnleft',  10*5, 3, xxx, 4);
seg = trjsegment(seg, 'deaccelerate', 10,  xxx, 2);
seg = trjsegment(seg, 'uniform',      60);
seg = trjsegment(seg, 'descent',      30, 2, xxx, 50);
seg = trjsegment(seg, 'uniform',      100);
% generate, save & plot
trj = trjsimu(avp0, seg.wat, ts, 1);
trjfile('trj0516.mat', trj);
insplot(trj.avp);
imuplot(trj.imu);
% pos2gpx('trj_SINS_gps', trj.avp(1:round(1/trj.ts):end,7:9)); % to Google Earth

%% pure ins on simulated imu data
close all;clear;
glvs
trj = trjfile('trj0516.mat');
% error setting
imuerr = imuerrset(0.01, 100, 0.001, 10);
imu = imuadderr(trj.imu, imuerr);
davp0 = avperrset([0.5;0.5;5], 0.1, [10;10;10]);
avp00 = avpadderr(trj.avp0, davp0);
trj = bhsimu(trj, 1, 10, 3, trj.ts);
% pure inertial navigation & error plot
avp = inspure(imu, avp00, trj.bh, 1);
% avp = inspure(imu, avp00, 'f', 1);
avperr = avpcmpplot(trj.avp, avp);

myfigure;
dxyz = pos2dxyz(trj.avp(:,7:9));
plot(0, 0, 'rp');   % 19/04/2015
hold on, plot(dxyz(:,1), dxyz(:,2)); xygo('est', 'nth');
dxyz = pos2dxyz(avp(:,7:9));
hold on, plot(dxyz(:,1), dxyz(:,2)); xygo('est', 'nth');
legend(sprintf('LON0:%.2f, LAT0:%.2f (DMS), H0:%.1f (m)', r2dms(avp(1,8)),r2dms(avp(1,7)),avp(1,9)),'true trajectory','estimated trajectory');

%%
% close all;clear;
glvs

aln=load('aln.txt');

t1 = aln(:,end);
myfigure;
subplot(211), plot(t1, aln(:,1:2)/glv.deg), xygo('pr');
subplot(212), plot(t1, aln(:,3)/glv.deg), xygo('y');
title(sprintf('\\psi=%.4f \\circ', aln(end,3)/glv.deg));
%%
ins=load('ins1.txt');
avp=[ins(:,1:9),ins(:,end)];
insplot(avp);

%%
glvs
[imu, avp0, ts] = imufile('lasergyro');
imuplot(imu);
phi = [.5; .5; 5]*glv.deg;
imuerr = imuerrset(0.01, 10, 0.001, 1);
wvn = [0.01; 0.01; 0.01];
[att, attk, xkpk] = alignvn(imu(1:600/ts,:), avp0(1:3)', avp0(7:9)', phi, imuerr, wvn);
avp = inspure(imu(600/ts+1:end,:), [att;avp0(7:9)], 'f');

% [att, attk, xkpk] = alignvn(imu(1:end,:), avp0(1:3)', avp0(7:9)', phi, imuerr, wvn);
% avp = inspure(imu(1:end,:), [avp0(1:3);avp0(7:9)], 'f');

%%



