function [tubespecs]=UltimateBuckling(l,Load)
% Author: Trevor Hyatt
% Honorable Mentions: Lee Selbach
% Edited to be function 4/20/2018, Dustin Roth
% clear
% clc
% close all
%Inputs
% l = 18.6581; % [in] length of tube
C = 1; %Buckling condition
% Load = 450; % lbs
E = 29.7e6; %psi Young's Modulus 4130 steel
Sy = 63.1e3; %psi Yield strength 4130 steel
rho = .283; %lbs/in^3 density 4130 steel
fos = 1; % factor of safety
% OD = [0.188 0.25 0.313 0.438 0.5 0.563 0.625 0.75 0.875 1 1.125 1.25 1.315 1.375 1.415 1.5]; % [in] vector of standard outer diameters (ascending)
% t = [0.028 0.035 0.049 0.058 0.065 0.083 0.095 0.12 0.156 0.188 0.214 0.25 0.313 0.344 0.38 0.534]; % [in] vector of standard wall thicknesses (ascending)
OD=[.5 .625];
t=[.028 .035 .049];
n=1;
load_fos = Load.*fos;
o = length(OD);
m = length(t);
Pcr = zeros(o,m);
weight = zeros(o,m);
for i = 1:o
    di = OD(i) - 2.*t; % inner diameters
    for index = 1:m
        if di(index) < 0
            di(index) = 0; % turns tubes with negative inner diameters into rods
        end
    end
    I = pi.*((OD(i).^4)-(di.^4))./64; % second area moment of inertia
    A = pi.*(OD(i).^2 - di.^2)./4; % cross-sectional area
    k = sqrt(I./A); % radius of gyration
    slenderness_0 = l./k; % nominal slenderness ratio for Euler buckling
    slenderness_1 = sqrt((2.*(pi.^2).*n.*E)./Sy); % slenderness ratio for parabolic buckling
    for j = 1:m
        if slenderness_0(j) > slenderness_1 % compares slenderness ratios
            Pcr(i,j) = (n.*(pi.^2).*E.*I(j))./(l.^2); % critical load for Euler buckling
        else
            Pcr(i,j) = A(j).*(Sy - (((Sy./(2.*pi)).*(l./k(j))).^2).*(1./(n.*E))); % critical load for parabolic buckling
        end
    end
    weight(i,:) = A.*l.*rho; % matrix of tube/rod weights
end
idealP = Pcr >= load_fos; % optimization stuff
idealW = weight.*idealP;
idealW(idealW==0) = NaN;
[idealW3, Tindex] = min(idealW);
[idealW4, ODindex] = min(idealW3);
BestOD = OD(Tindex(ODindex));
BestT = t(ODindex);
BucklingPoint=Pcr(ODindex);
tubespecs={BestOD, BestT, BucklingPoint};

% hold on
% grid on
% plot(Pcr',weight','.-', 'linewidth',2)
% ylabel('Weight (lbs)')
% xlabel('Critical Load (lbf)')
% plot(Pcr((Tindex(ODindex)),ODindex),weight(Tindex(ODindex),ODindex),'o','linewidth',3)
% legend('.25','.375','.5','.625','Selected Tube','Location','NorthWest')
% fprintf('Ideal size: %g OD\n%g wall thickness\nWeight: %.3g lbs\nBuckling Load: %g Lbs\n',BestOD,BestT,weight(Tindex(ODindex),ODindex),BucklingPoint)
end