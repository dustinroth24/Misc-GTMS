% Dustin's Toe Script
% Create's a table of tie rod lengths for a given camber angle and desired
% toe angle. SolidWorks Coordinate system. Units are inches and degrees as
% God intended.
clear,clc,close
%% setup
sa_outer=[22.9735 7.411 2.85];
sa_inner=sa_outer-[0 0 1];
lbj=[22 5.75 .098];
kpi=0; % degrees of kpi
caster=4; % degrees of caster
rack_point_original=[8.7008 6.2227 2.1924];
toe=-5:.5:5; % degrees of rotation you want to sweep through
camber_settings=0:1:3; % degrees of negative camber available;

%% setup shit you don't have to worry about
upright_original=[sa_outer; sa_inner; lbj]'; % these is column vectors
upright= upright_original-lbj';% moves coordinate system to the lbj, which will not move
upright=rotz(-kpi)*rotx(caster)*upright;
rack_point1=rack_point_original-lbj;
rack_point=rotz(-kpi)*rotx(caster)*rack_point1'; % makes z axis along steering axis
table=zeros(length(toe),1,length(camber_settings));
angle_table=zeros(length(toe),1);
vars=struct();

%% sweeps
for i=1:length(camber_settings)
    upright_cambChange=rotz(camber_settings(i))*upright;
    for j=1:length(toe) % degrees of toe you want to sweep through
        upright_toechange=roty(toe(j))*upright_cambChange;
        steering_vector=upright_toechange(:,1)-upright_toechange(:,2);
        steering_vector2=rotx(-caster)*rotz(kpi)*steering_vector;% takes out the rotations to make math a bit easier
        steerxz=[steering_vector2(1) 0 steering_vector2(3)];
        angle=acosd(dot(steerxz,[0 0 1])/norm(steering_vector2));
        if toe(j)<0
            angle=-angle; % negative means toe in
        end
        angle_table(j)=angle;
        tierod_length=norm(upright_toechange(:,1)-rack_point);
        table(j,1,i)=tierod_length;
    end
    angle_table=round(angle_table,1);
    table=round(table,3);
    vars(i).Camber=camber_settings(i);
    vars(i).Desired_Toe=angle_table;
    vars(i).Tierod_Length=table(:,:,i);
end

%% Table formatting
promptMessage = sprintf('Create New Table?');
titleBarCaption = 'Yes or No';
button = questdlg(promptMessage, titleBarCaption, 'Yes', 'No', 'Yes');
if strcmpi(button,'Yes')
    prompt=sprintf('Name?');
    filename=inputdlg(prompt);
    filename=[filename{:} '.xlsx'];
    data=ones(1+length(vars(1).Desired_Toe),length(camber_settings)*3)*NaN;
    for i=1:length(camber_settings)
        comb_tab=[vars(i).Desired_Toe vars(i).Tierod_Length];
        top_row=vars(i).Camber;
        top_row=[top_row NaN];
        col=[top_row;comb_tab];
        data(:,1+3*(i-1):1+3*(i-1)+1)=col;
    end
    xlswrite(filename,data)
    disp('Done!')
end


        
        


