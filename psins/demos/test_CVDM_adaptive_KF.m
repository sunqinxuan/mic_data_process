% KF+��������Ӧ�˲����棨��Գ��ٶȶ�̬ģ��(constant velociyt dynamic model, CVDM)�ĵ���״̬����
% ���������μ�'�����ߵ��㷨����ϵ���ԭ��'����ϰ��35��.
%	RkKnownKF - ����׼ȷ��֪�Ŀ������˲�����Ϊ���Ųο���
%	MSHAKF - �Ľ�Sage-Husa����Ӧ�������˲�
%	MCKF  - �������ؿ������˲�, ���ֱ�ֱ�Ҷ˹���Ʒ���
%	RSTKF - ³��ѧ��t�������˲�
%	SSMKF - ͳ�����ƶ����������˲�
%   CERKF - �����Ч³���������˲�
% Copyright(c) 2009-2022, by Gongmin Yan, All rights reserved.
% Northwestern Polytechnical University, Xi An, P.R.China
% 03/04/2022
%% ��������
Ft = [0 1; 0 0];  Gt = [0; 1];
q = 0.05;
Ts = .2;
Phi = eye(2)+Ft*Ts;  Gamma = Gt;  Qk = q*Ts;
Hk = [1 0];  Rk = 10^2;                          % distance measurement
% Hk = [1 0; 0 1];  Rk = diag([5^2; 1^2]);       % distance+velocity measurement
[m, n] = size(Hk);
s0 = 10; v0 = 2;
len = 500;
sp = zeros(len,6); sv = sp;
for MCn=1:10  % Monte Carlo runs
    %% �켣����
    Xk = [s0; v0];
	Xkk = zeros(len,n); Zkk = zeros(len,m); Rkk = Zkk; wnk = Rkk;
    for k=1:len
        Xk = Phi*Xk + Gamma*sqrt(Qk)*randn(1);
        Xkk(k,:) = Xk';
        p=0.1; s=10;
        [wn,s] = htwn(p,s,m);  Rkk(k,:) = (s.^2)'.*diag(Rk)';  % ��β��������
        Zk = Hk*Xkk(k,:)' + sqrt(Rk)*wn;  wnk(k,:) = sqrt(Rk)*wn;
        Zkk(k,:) = Zk';
    end
    %% �����˲� KF/MSHAKF/MCKF/RSTKF/SSMKF
    kf.xk = [s0+10*randn(1); v0+1*randn(1)]*0;  kf.Pxk = diag([10, 1])^2;
    kf.Phikk_1 = Phi;   kf.Gammak = Gamma;   kf.Qk = Qk;
    kf.Rk = Rk*1;  kf.Hk = Hk;  [kf.m, kf.n] = size(Hk);  kf.measIter = 2; kf.betak = ones(kf.m,1); kf.Rmin = diag(Rk); kf.Rmax = diag(Rk)*100;
    res = zeros(length(Zkk),5);
    akf = kf; mkf = kf; rkf = kf; skf = kf; ckf = kf;   ares = res; mres = res; rres = res; sres = res; cres = res;
	bs = repmat([0.0,3],kf.m,1);
    for k=1:length(Zkk)
        kf.Rk = diag(Rkk(k,:));  % myfig(sqrt(Rkk));
        kf  = akfupdate(kf,  Zkk(k,:)', 'B', 'KF');             res(k,:)  = [kf.xk;  diag(kf.Pxk);  kf.res];
        akf = akfupdate(akf, Zkk(k,:)', 'B', 'MSHAKF',bs);       ares(k,:) = [akf.xk; diag(akf.Pxk); akf.res];
        mkf = akfupdate(mkf, Zkk(k,:)', 'B', 'MCKF',  5);       mres(k,:) = [mkf.xk; diag(mkf.Pxk); mkf.res];
        rkf = akfupdate(rkf, Zkk(k,:)', 'B', 'RSTKF', 3);       rres(k,:) = [rkf.xk; diag(rkf.Pxk); rkf.res];
        skf = akfupdate(skf, Zkk(k,:)', 'B', 'SSMKF', 3);       sres(k,:) = [skf.xk; diag(skf.Pxk); skf.res];
        ckf = akfupdate(ckf, Zkk(k,:)', 'B', 'CERKF', 3);       cres(k,:) = [ckf.xk; diag(ckf.Pxk); ckf.res];
    end
    sp = sp + delbias([res(:,1),ares(:,1),rres(:,1),mres(:,1),sres(:,1),cres(:,1)], Xkk(:,1)).^2;
    sv = sv + delbias([res(:,2),ares(:,2),rres(:,2),mres(:,2),sres(:,2),cres(:,2)], Xkk(:,2)).^2;
    disp(MCn);
end
sp = sp/MCn;  sv = sv/MCn;
rmsepv = sqrt([mean(sp(100:end,:))', mean(sv(100:end,:))']);
lgstr = {'IdealKF','MSHAKF','RSTKF','MCKF','SSMKF','CERKF'};
myfig
subplot(221), plot([Xkk(:,1),Zkk(:,1)]); xygo('\itk','���� / m'); legend('��ʵֵ', '����ֵ'); title('(a)')
subplot(222), plot([Xkk(:,2)]); xygo('\itk','�ٶ� / m/s');  title('(b)')
subplot(223), plot(smoothn(sqrt(sp),10)); xygo('\itk','������� RMSE / m');  title('(a)'); mylegend(lgstr,rmsepv(:,1));
subplot(224), plot(smoothn(sqrt(sv),10)); xygo('\itk','�ٶȹ��� RMSE / m');  title('(b)'); mylegend(lgstr,rmsepv(:,2));
return;
%%
myfig;
subplot(221), plot(Zkk(:,1)-Xkk(:,1)); xygo('k','dist meas err / m');
subplot(223), plot([Xkk(:,2),res(:,2),ares(:,2),mres(:,2),rres(:,2),sres(:,2),cres(:,2)]); xygo('k','vel / m/s'); 
    legend('real', 'IdealKF est','MSHAKF est','MCKF est','RSTKF est','SSMKF est','CERKF est');
    perr = [res(:,1)-Xkk(:,1),ares(:,1)-Xkk(:,1),mres(:,1)-Xkk(:,1),rres(:,1)-Xkk(:,1),sres(:,1)-Xkk(:,1),cres(:,1)-Xkk(:,1)];
subplot(222), plot(perr); xygo('k','dist RMSE / m'); plot(sqrt([res(:,3),ares(:,3),mres(:,3),rres(:,3),sres(:,3)]));
    perr = rms(perr(100:end,:)); mylegend(lgstr,perr);
    verr = [res(:,2)-Xkk(:,2),ares(:,2)-Xkk(:,2),mres(:,2)-Xkk(:,2),rres(:,2)-Xkk(:,2),sres(:,2)-Xkk(:,2),cres(:,2)-Xkk(:,2)];
subplot(224), plot(verr); xygo('k','vel RMSE / m/s'); plot(sqrt([res(:,4),ares(:,4),mres(:,4),rres(:,4),sres(:,4)])); 
    verr = rms(verr(100:end,:)); mylegend(lgstr,verr);
myfig;
subplot(221), xygo('k','dist RMSE / m'); plot(sqrt([res(:,3),ares(:,3),mres(:,3),rres(:,3),sres(:,3)]));    legend(lgstr)
subplot(222), xygo('k','vel RMSE / m/s'); plot(sqrt([res(:,4),ares(:,4),mres(:,4),rres(:,4),sres(:,4)]));   legend(lgstr);
subplot(2,2,[3,4]); plot([abs(wnk), res(:,5),ares(:,5),mres(:,5),rres(:,5),sres(:,5),cres(:,5)]), xygo('k','val'); legend('wn', 'KF','MSHAKF','MCKF','RSTKF','SSMKF','CERKF');

