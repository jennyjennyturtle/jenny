% the code for carey UV-Vis spectrometer!! 

clc
clear 
close all 

WL_range=[300 650];
liter=[100 200 500 835 1145];%(in uL)
stock_conc=8.74*10^-5;
Dlm = '\t';
conc=stock_conc*liter*10^-6/0.01;
WL_love=[400 500 606 609 615];
Bkg=[655 800];

% read the file 
data=xlsread('2021-01-25-TIPS-TT dimer extinction coefficient.csv');
% read the head
opts=detectImportOptions('2021-01-25-TIPS-TT dimer extinction coefficient.csv');
title=opts.SelectedVariableNames;
WL=data(:,1);

Ind_bkg_min=find(Bkg(1) == WL,1,'first');
Ind_bkg_max=find(Bkg(2) == WL,1,'first');


size1=size(WL,1);
avg=zeros(size1,length(liter));
avg_bkg=zeros(length(liter));
for i = 1:length(liter)
   Index = find(contains(title,strcat('x',num2str(liter(i)),'uL')));
   nn=length(Index);
   Temp=[];
   Temp=data(:,Index+1);
   avg_pre(:,i)=sum(Temp,2)/nn;
   avg_bkg(i)=sum(avg_pre(Ind_bkg_max:Ind_bkg_min,i))/(abs(Ind_bkg_max-Ind_bkg_min)+1);
   avg(:,i)=avg_pre(:,i)-avg_bkg(i);
end

figure()
plot(WL,avg)


minnum=find(WL_range(1) > WL,1,'first');
maxnum=find(WL_range(2) > WL,1,'first');

model = fittype(('a*x'));
kk=0;
epison=zeros(abs(maxnum-minnum)+1,1);
rsquare=zeros(abs(maxnum-minnum)+1,1);
 for i = maxnum:minnum
    kk=kk+1;
    [curve,goodness,output] =fit(conc',avg(i,:)', model, 'StartPoint', 45000, 'lower',0); % alphabetical order%     if i ==wllnum
    epison(kk,1) = coeffvalues(curve);
    rsquare(kk,1)=goodness.rsquare;
 end
 
WL_new=WL(maxnum:minnum);
figure()
plot(WL_new,epison)
saveas(gcf,'2021-01-25-TIPS-TT dimer extinction coefficient.emf')

ind=zeros(length(WL_love));
ind_old=zeros(length(WL_love));
for i = 1:length(WL_love)
    
    ind(i)=find(WL_love(i) > WL_new,1,'first');
    ind_old(i)=find(WL_love(i) > WL,1,'first');
    figure()
    plot(conc',avg(ind_old(i),:)','o')
    hold on 
    plot([0;conc'],[0;conc']*epison(ind(i)),'-r')
    hold off
    
end
