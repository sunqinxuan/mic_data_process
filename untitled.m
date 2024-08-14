

h_m=zeros(size(x_m));
h_n=zeros(size(x_n));
for i=1:size(x_m,1)
    h_m(i)=norm([x_m(i),y_m(i),z_m(i)]);
    h_n(i)=norm([x_n(i),y_n(i),z_n(i)]);
end
scale=mean(h_m)/mean(h_n);

figure; 
plot(h_m,'r'); hold on;
plot(h_n,'b'); hold on;


