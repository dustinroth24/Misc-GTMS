% Script: Tube Forces

% This script uses the big ass spreadsheet points and inputted tire forces
% to find the stresses in each tube and then gets the best size for the tube. Forces are in lbf and lengths are
% obviously in inches.
% Uses SolidWorks coordinate system
% USE THIS AS A REFERENCE DON'T JUST USE THE SIZES FROM THIS SCRIPT THAT
% WOULD BE STUPID.

% Inputs: tire patch forces, pneumatic trail
% Outputs: forces in each tube

% Author: Dustin Roth
% Date: 2/24/2018
clear
clc
close all
[~,~,raw]=xlsread('Dustin''sSuperUltraMegaSuspensionSpreadsheet.xlsx','Component Loads');
wb=60.5;
normal=320; %input
% normal load on tire
% should be positive
mfy=cross([raw{21,2},0,0],[0,normal,0]);
% moment from normal load about origin

fx=-2.5*normal; %input
% cornering force
% positive=inside wheel

PTrail=.9; %input
% pneumatic trail of the tire, might be a valid parameter idk
mfx=cross([raw{21,2},0,-PTrail],[fx,0,0]);
% moment from tire

fz=2*normal; %input
% drive/brake force
% positive=driving
mfz=cross([raw{21,2},0,0],[0,0,fz]);
% moment from drive/braking force (in*lbs)
% a=3*386.22;
% % how many g's
% bump=22*a;

rb=[-fx,-normal,-fz,-(mfz(1)+mfy(1)+mfx(1)),-(mfz(2)+mfy(2)+mfx(2)),-(mfz(3)+mfy(3)+mfx(3))]';
if fz>0
    fb=[-fx,-normal,0,-(mfy(1)+mfx(1)),-(mfy(2)+mfx(2)),-(mfy(3)+mfx(3))]';
else
    fb=rb;
    %     front wheels wont experience driving force
end


FUupright=[raw{5,2},raw{5,3},raw{5,4}];
FLupright=[raw{10,2},raw{10,3},raw{10,4}];
RUupright=[raw{5,9},raw{5,10},raw{5,11}]+[0 0 wb];
RLupright=[raw{10,9},raw{10,10},raw{10,11}]+[0 0 wb];
FPupright=[raw{18,2},raw{18,3},raw{18,4}];
FSupright=[raw{14,2},raw{14,3},raw{14,4}];
RPupright=[raw{18,9},raw{18,10},raw{18,11}]+[0 0 wb];
RTupright=[raw{14,9},raw{14,10},raw{14,11}]+[0 0 wb];
% upright points used for moments


FUF=[raw{5,2}-raw{3,2},raw{5,3}-raw{3,3},raw{5,4}-raw{3,4}]*-1;
mFUF=cross(FUupright,FUF/norm(FUF));
FUA=[raw{5,2}-raw{4,2},raw{5,3}-raw{4,3},raw{5,4}-raw{4,4}]*-1;
mFUA=cross(FUupright,FUA/norm(FUA));
FLF=[raw{10,2}-raw{8,2},raw{10,3}-raw{8,3},raw{10,4}-raw{8,4}]*-1;
mFLF=cross(FLupright,FLF/norm(FLF));
FLA=[raw{10,2}-raw{9,2},raw{10,3}-raw{9,3},raw{10,4}-raw{9,4}]*-1;
mFLA=cross(FLupright,FLA/norm(FLA));
sturLink=[raw{14,2}-raw{13,2},raw{14,3}-raw{13,3},raw{14,4}-raw{13,4}]*-1;
mStur=cross(FSupright,sturLink/norm(sturLink));
frontPush=[raw{18,2}-raw{17,2},raw{18,3}-raw{17,3},raw{18,4}-raw{17,4}]*-1;
mFrontPush=cross(FPupright,frontPush/norm(frontPush));

RUF=[raw{5,9}-raw{3,9},raw{5,10}-raw{3,10},raw{5,11}-raw{3,11}]*-1;
mRUF=cross(RUupright,RUF/norm(RUF));
RUA=[raw{5,9}-raw{4,9},raw{5,10}-raw{4,10},raw{5,11}-raw{4,11}]*-1;
mRUA=cross(RUupright,RUA/norm(RUA));
RLF=[raw{10,9}-raw{8,9},raw{10,10}-raw{8,10},raw{10,11}-raw{8,11}]*-1;
mRLF=cross(RLupright,RLF/norm(RLF));
RLA=[raw{10,9}-raw{9,9},raw{10,10}-raw{9,10},raw{10,11}-raw{9,11}]*-1;
mRLA=cross(RLupright,RLA/norm(RLA));
tieRod=[raw{14,9}-raw{13,9},raw{14,10}-raw{13,10},raw{14,11}-raw{13,11}]*-1;
mTieRod=cross(RTupright,tieRod/norm(tieRod));
rearPush=[raw{18,9}-raw{17,9},raw{18,10}-raw{17,10},raw{18,11}-raw{17,11}]*-1;
mRearPush=cross(RPupright,rearPush/norm(rearPush));
%  Gets vectors and moments for system of equations. Moments were found
%  using unit vectors. Tubes are assumed to be in tension.

FrontEqs=[FUF(1)/norm(FUF),FUA(1)/norm(FUA),FLF(1)/norm(FLF),FLA(1)/norm(FLA),frontPush(1)/norm(frontPush),sturLink(1)/norm(sturLink);...
    FUF(2)/norm(FUF),FUA(2)/norm(FUA),FLF(2)/norm(FLF),FLA(2)/norm(FLA),frontPush(2)/norm(frontPush),sturLink(2)/norm(sturLink);...
    FUF(3)/norm(FUF),FUA(3)/norm(FUA),FLF(3)/norm(FLF),FLA(3)/norm(FLA),frontPush(3)/norm(frontPush),sturLink(3)/norm(sturLink);...
    mFUF(1),mFUA(1),mFLF(1),mFLA(1),mFrontPush(1),mStur(1);...
    mFUF(2),mFUA(2),mFLF(2),mFLA(2),mFrontPush(2),mStur(2);...
    mFUF(3),mFUA(3),mFLF(3),mFLA(3),mFrontPush(3),mStur(3);];

RearEqs=[RUF(1)/norm(RUF),RUA(1)/norm(RUA),RLF(1)/norm(RLF),RLA(1)/norm(RLA),rearPush(1)/norm(rearPush),tieRod(1)/norm(tieRod);...
    RUF(2)/norm(RUF),RUA(2)/norm(RUA),RLF(2)/norm(RLF),RLA(2)/norm(RLA),rearPush(2)/norm(rearPush),tieRod(2)/norm(tieRod);...
    RUF(3)/norm(RUF),RUA(3)/norm(RUA),RLF(3)/norm(RLF),RLA(3)/norm(RLA),rearPush(3)/norm(rearPush),tieRod(3)/norm(tieRod);...
    mRUF(1),mRUA(1),mRLF(1),mRLA(1),mRearPush(1),mTieRod(1);...
    mRUF(2),mRUA(2),mRLF(2),mRLA(2),mRearPush(2),mTieRod(2);...
    mRUF(3),mRUA(3),mRLF(3),mRLA(3),mRearPush(3),mTieRod(3)];

FrontForces=FrontEqs\fb;
RearForces=RearEqs\rb;

frontLengths=[norm(FUF),norm(FUA),norm(FLF),norm(FLA),norm(frontPush),norm(sturLink)];
rearLengths=[norm(RUF),norm(RUA),norm(RLF),norm(RLA),norm(rearPush),norm(tieRod)];

FrontTubulars=cell(7,4);
FrontTubulars(2:end,1)={'UF','UA','LF','LA','P','S'};
FrontTubulars(1,2:end)={'OD','Wall','Max Force'};

RearTubulars=cell(7,4);
RearTubulars(2:end,1)={'UF','UA','LF','LA','P','S'};
RearTubulars(1,2:end)={'OD','Wall','Max Force'};

for i=1:6
    FrontTubulars(1+i,2:end)=UltimateBuckling(frontLengths(i),abs(FrontForces(i)));
    RearTubulars(1+i,2:end)=UltimateBuckling(rearLengths(i),abs(RearForces(i)));
end
FrontTubulars(2:end,1)={'UF','UA','LF','LA','P','S'};

open FrontTubulars
open RearTubulars
% 1. UF
% 2. UA
% 3. LF
% 4. LA
% 5. P
% 6. S

    