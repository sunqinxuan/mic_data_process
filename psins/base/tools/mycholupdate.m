function R = mycholupdate(R, X, sgn)
% ����˹���ֽ���-1���£�R'*R:=R'*R+sgn*X*X',R������,X������(�ɶ���)
    if nargin<3, sgn=1; end
    [n, m] = size(X);
    if m>1  % ��XΪ���У������и���
        for k=1:m, R = mycholupdate(R, X(:,k), sgn); end
        return;
    end
    X = X(:)';  % תΪ������
    for k=1:n
        s11 = sqrt(R(k,k)^2+sgn*X(k)^2);  % ��Ǹ�
        c = R(k,k)/s11;  s = X(k)/s11;
        s12 = c*R(k,k+1:n) + sgn*s*X(k+1:n);
        X(k+1:n) = c*X(k+1:n) - s*R(k,k+1:n);
        R(k,k:n) = [s11,s12];
    end