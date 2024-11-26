%java test

startTime = datetime(2023,2,21,18,0,0);
stopTime = startTime + hours(1);
sampleTime = 60; % seconds
sc = satelliteScenario(startTime,stopTime,sampleTime);
viewer = satelliteScenarioViewer(sc,ShowDetails=false);

%%
% 위성의 개수 설정
numOrbits=7; 
numSatellitesPerOrbitalPlane = 7;
numSatellites = numOrbits*numSatellitesPerOrbitalPlane; % Walker Star 모델에서는 총 위성의 개수를 설정

% RAAN (Right Ascension of Ascending Node) 설정 - 모든 위성이 동일한 궤도 공유 => 동일하게 설정
RAAN = zeros(1, numSatellites); % 동일한 궤도 평면

% True Anomaly 설정 - 균등한 각도 간격으로 분포
trueanomaly = zeros(1,numSatellites);

satIndex=1;
for i=1:numOrbits
    for j=1:numSatellitesPerOrbitalPlane
        RAAN(satIndex)=360*(i-1)/numOrbits;
        trueanomaly(satIndex)=360*(j-1)/numSatellitesPerOrbitalPlane;
        satIndex=satIndex+1;
    end
end

% 궤도 요소 설정
semimajoraxis = repmat((6371 + 780)*1e3, size(RAAN)); % 반장축 (고도 780km)
inclination = repmat(86.4, size(RAAN)); % 경사각
eccentricity = zeros(size(RAAN)); % 이심률 (원형 궤도)
argofperiapsis = zeros(size(RAAN)); % 근지점 인수

% 위성 생성
sats = satellite(sc, semimajoraxis, eccentricity, inclination, RAAN, argofperiapsis, trueanomaly, Name="Star " + string(1:numSatellites)');

latlim = [33 39]; % South Korea의 위도 범위
lonlim = [124 131]; % South Korea의 경도 범위

spacingInLatLon = 1; % degrees / 간격 지정
%% 투영 좌표
proj = projcrs(3857);
%x-y 지도 좌표 계산
spacingInXY = deg2km(spacingInLatLon)*1000; % meters
[xlim,ylim] = projfwd(proj,latlim,lonlim);

R = maprefpostings(xlim,ylim,spacingInXY,spacingInXY);
[X,Y] = worldGrid(R);
[gridlat,gridlon] = projinv(proj,X,Y);
%java추출

landareas = readgeotable('combined_landareas.shp', 'CoordinateSystemType', 'geographic');

java = landareas(string(landareas.Name) == "South Korea", :);

% MAT 파일에서 한국 지리 정보 불러오기
load('korea_coverage_map.mat', 'gslat', 'gslon', 'javab','gridpts','inregion');

gs = groundStation(sc,gslat,gslon);

%% 송신기 및 수신기 추가
fq = 1625e6; % Hz  403000000
txpower = 20; % dBW  7
antennaType = "Gaussian";
halfbeamWidth = 62.7; % degrees

if antennaType == "Gaussian"
    lambda = physconst('lightspeed')/fq; % meters
    dishD = (70*lambda)/halfbeamWidth; % meters
    tx = transmitter(sats, ...
        Frequency=fq, ...
        Power=txpower); 
    gaussianAntenna(tx,DishDiameter=dishD);
end

% 사용자 정의 48-beam 안테나를 사용하여 위성 송신기 추가
if antennaType == "Custom 48-Beam"
    antenna = helperCustom48BeamAntenna(fq);
    tx = transmitter(sats, ...
        Frequency=fq, ...
        MountingAngles=[0,-90,0], ... 
        Power=txpower, ...
        Antenna=antenna);  
end

isotropic = arrayConfig(Size=[1 1]);
rx = receiver(gs,Antenna=isotropic);

pattern(tx,Size=500000);
%% 컴퓨터 래스터 커버리지 맵 데이터
delete(viewer)
maxsigstrength = satcoverage(gridpts,sc,startTime,inregion,halfbeamWidth);

%axesm map 시각화
minpowerlevel = -120; % dBm
maxpowerlevel = -100; % dBm


%% 특정 지역 snr값 출력 

% 대전  
inputLat = 36.3504119; % 위도 입력
inputLon = 127.3845475; % 경도 입력

% 입력한 좌표에 대응하는 SNR 값을 추정
if inputLat >= min(latlim) && inputLat <= max(latlim) && ...
   inputLon >= min(lonlim) && inputLon <= max(lonlim)

    % SNR 값을 위한 보간 (위도, 경도에 대해 SNR 값을 추정)
    snrValue = interp2(gridlon, gridlat, maxsigstrength, inputLon, inputLat, 'linear');
    fprintf("지역명 : 대전\n")
    fprintf("입력한 좌표 (%.4f, %.4f)의 SNR 값은 %.2f dBm입니다.\n", inputLat, inputLon, snrValue);
end


%% 지도 생성
figure
worldmap(latlim,lonlim)
mlabel south

colormap turbo
clim([minpowerlevel maxpowerlevel])
geoshow(gridlat,gridlon,maxsigstrength,DisplayType="contour",Fill="on")
geoshow(java,FaceColor="none")

cBar = contourcbar;
title(cBar,"dBm");
title("Signal Strength at " + string(startTime) + " UTC")

%% 등고선 계산
levels = linspace(minpowerlevel,maxpowerlevel,8);
GT = contourDataGrid(gridlat,gridlon,maxsigstrength,levels,proj);
GT = sortrows(GT,"Power (dBm)");
disp(GT)

%% 지도  축에 적용 범위 시각화

figure
newmap(proj)
hold on

colormap turbo
clim([minpowerlevel maxpowerlevel])
geoplot(GT,ColorVariable="Power (dBm)",EdgeColor="none")
% colorvariable : 등고선의 색상 / edgecolor : 윤곽선 색상
% GT 객체 사용하여 플로팅
% 플로팅 = 데이터 or 그래프를 시각적으로 표현하는 것

geoplot(java,FaceColor="none")

cBar = colorbar;
title(cBar,"dBm");
title("Signal Strength at " + string(startTime) + " UTC")


%% 
secondTOI = startTime + minutes(2); % 2 minutes after the start of the scenario
maxsigstrength = satcoverage(gridpts,sc,secondTOI,inregion,halfbeamWidth);

GT2 = contourDataGrid(gridlat,gridlon,maxsigstrength,levels,proj);
GT2 = sortrows(GT2,"Power (dBm)");

figure
newmap(proj)
hold on


colormap turbo
clim([minpowerlevel maxpowerlevel])
geoplot(GT2,ColorVariable="Power (dBm)",EdgeColor="none")
geoplot(java,FaceColor="none")

cBar = colorbar;
title(cBar,"dBm");
title("Signal Strength at " + string(secondTOI) + " UTC")

