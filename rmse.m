function y=rmse(x,x_hat)

N=size(x,1);
dim=size(x,2);

if N~=size(x_hat,1)
    fprintf('input sequences not equal!');
    return;
end

if dim==1
    sum=0;
    for i=1:N
        sum=sum+(x(i)-x_hat(i))*(x(i)-x_hat(i));
    end
    y=sqrt(sum/N);
else
    if dim==3
        sum=0;
        for i=1:N
            res=norm(x(i,:)-x_hat(i,:));
            sum=sum+res*res;
        end
        y=sqrt(sum/N);
    else
        fprintf('input dimensions wrong!');
        return;
    end
end


