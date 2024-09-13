function y=yawplot(yaw)

y=yaw;
delta_yaw=0;
for k=1:size(yaw,1)
    if k==1
        continue;
    else
        if yaw(k)-yaw(k-1)<-300
            delta_yaw=delta_yaw+360;
        else
            if yaw(k)-yaw(k-1)>300
                delta_yaw=delta_yaw-360;
            end
        end
        y(k)=yaw(k)+delta_yaw;
    end
end