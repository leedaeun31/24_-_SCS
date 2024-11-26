%%
% 기존 landareas.shp 파일 읽기
landareas = shaperead('landareas.shp');

% 한국의 지리정보가 포함된 파일 읽기
korea = shaperead('KOR_0.shp');

% Korea의 GID_0 필드를 제거하고, COUNTRY 필드를 Name으로 변경
for i = 1:length(korea)
    korea(i).Name = korea(i).COUNTRY;
end

%필드를 한 번에 제거 (한국 데이터)
korea = rmfield(korea, {'COUNTRY', 'GID_0'});
landareas=landareas(~strcmp({landareas.Name},''));

% Java의 필드 정보 확인
javaIndex = find(strcmp({landareas.Name}, 'Java')); % Java의 인덱스를 찾음
if ~isempty(javaIndex)
    javaInfo = landareas(javaIndex);  % Java의 필드 정보
    disp('Java의 필드 정보:');
    disp(javaInfo);
else
    disp('Java가 shapefile에 포함되어 있지 않습니다.');
end

% South Korea의 필드 정보 확인
koreaIndex = find(strcmp({korea.Name}, 'South Korea'));  % NAME_0이 South Korea인 경우 찾기
if ~isempty(koreaIndex)
     koreaInfo = korea(koreaIndex);  % South Korea의 필드 정보
     disp('South Korea의 필드 정보:');
     disp(koreaInfo);
 else
     disp('South Korea가 shapefile에 포함되어 있지 않습니다.');
end


%%
% 두개의 shp 파일 합치기
combinedData = [landareas; korea];

% 새로운 Shapefile로 저장
shapewrite(combinedData, 'combined_landareas.shp');

% 저장된 shapefile 읽기
verifiedData = shaperead('combined_landareas.shp');

disp(verifiedData)

% 한국 데이터 필터링
korea_data = verifiedData(strcmp({verifiedData.Name}, 'South Korea')); 

disp(korea_data)


latlim = [min([korea_data.Y]), max([korea_data.Y])];  % 한국의 위도 범위
lonlim = [min([korea_data.X]), max([korea_data.X])];  % 한국의 경도 범위 
disp(latlim)
disp(lonlim)
