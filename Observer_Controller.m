clc
clear all
close all
% Full order observer and minumum-order observer
% in the s domain
num=[1 2 50];
den=[1 10 24 0];
sys=tf(num,den);
% state space representation
A=[0 1 0; 0 0 1; 0 -24 -10];
B=[1;-8;106];
C=[1 0 0 ];
D=0;
% desired poles and gain
r=[(-1-2*j),(-1+2*j), -5]; % for state-feedback gain
K=acker(A,B,r)
% desired poles and gain
re=[-10, -10, -10];
Ke=acker(A',C',re)'% full-state observer gain

AA=A-Ke*C-B*K;
BB=Ke;
CC=K;
sys_fso=ss(AA,BB,CC,D); 
[num_fso, den_fso]=ss2tf(AA,BB,CC,D);
sys_fso=tf(num_fso,den_fso);
% closed loop for full-state order
% depending on the figure(series and feedback connections)
sys_fso_cl=feedback(series(sys,sys_fso),1)

% minumum order observer
Aaa=0;
Aba=[0;0];
Abb=[0 1;-24 -10]; % equals to A
Aab=[1 0 ]; % equals to C
Ba=1;
Bb=[-8;106];
% Ka and Kb are derived from K
Ka=0.5; 
Kb=[-0.0904, -0.0398];
re_min=[-10, -10];
Ke_min=acker(Abb',Aab',re_min)'

% ...hat
Ahat=Abb-Ke_min*Aab;
Bhat=Ahat*Ke_min+Aba-Ke_min*Aaa;
Fhat=Bb-Ke_min*Ba;

% ...tilda (using ...hat and other variables)
Atilda=Ahat-Fhat*Kb;
Btilda=Bhat-Fhat*(Ka+Kb*Ke_min);
Ctilda= -Kb;
Dtilda= -(Ka+Kb*Ke_min);
[num_moo, den_moo]=ss2tf(Atilda,Btilda,-Ctilda,-Dtilda);
% closed loop for minumum-order observer
% depending on the figure(series and feedback connections)
sys_moo=tf(num_moo,den_moo);
sys_moo_cl=feedback(series(sys,sys_moo),1)

figure(1)
% step response
step(sys_fso_cl)
hold on
step(sys_moo_cl)

figure(2)
% bode plot
w=logspace(-1,1,100);
bode(sys_moo_cl,w,'g')% we are only intrested in mag plot(bodemag)
bode(sys_fso_cl,w,'b')% we are only intrested in mag plot(bodemag)

% bandwidth info.
BW_moo=bandwidth(sys_moo_cl)% minumum order observer bandwitdh
BW_fso=bandwidth(sys_fso_cl)% full-state observer bandwitdh