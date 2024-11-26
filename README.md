# 24_SCS_SNR-Coverage-Map

## 프로젝트 개요 
현대 사회에서의 통신 기술은 거의 모든 장소에서 원활한 정보 교환을 가능하게 한다. 하지만 통신 음영 지역 및 재난 상황에서 지상 통신망의 한계가 발생한다. 이를 해결하기 위하여 저궤도 위성의 낮은 지연 시간과 넓은 커버리지 특성을 활용한 **실시간 SNR 분석이 필요**하다. 본 프로젝트에서 대한민국의 지리 데이터를 활용한 SNR 커버리지 맵을 시각화하고 분석하기 위한 시뮬레이션을 만들었다. 

## 실험 1 - 저궤도 위성 모델 비교 
저궤도 위성 모델인 Walker Star와 Walker Delta 모델을 비교하였다. 
그 결과 **Walker Star** 모델을 사용한 경우 더 균등한 SNR Coverage Map이 생성되었다.

## 실험 2 - 위성 배치 별 SNR Coverage Map 비교 
위성의 배치를 균등한 경우와 균등하지 않은 경우를 비교하였다. 그 결과 **위성의 배치가 균등하고 위성의 개수가 많을수록** SNR Coverage Map 신호의 강도가 균일하게 나타났다.

## 구현 기능 
기존 매트랩 예제 코드와 위의 실험 결과를 바탕으로하여 기능을 추가 구현하였다.
1. landarea.shp 파일에 GADM에서 제공하는 한국의 지리정보 데이터를 추가
2. 저궤도 위성 모델 : Walker Star를 사용하여 위성 구성 
3. 위성의 배치를 균등하게 하여 더 좋은 SNR Coverage Map 출력
4. 한국의 Covearge Map 계산에 필요한 데이터를 Mat 파일로 저장 => 실행 시간 단축
5. 사용자가 지정한 특정 지역(대전)의 SNR 값 출력 기능 추가

## 코드의 활용 방안
특정 GPS 좌표의 SNR 커버리지 맵을 분석하여 6G 통신 시스템 구축 및 재난 통신 환경에 유용하게 사용될것으로 예상 

## 주요 파일 설명 
combined_landareas.shp : 대한민국의 지리 정보가 추가된 파일
korea_coverage_map.mat : 한국 커버리지 계산에 필요한 데이터 파일 

# 참고 
[1] Y. Su et al., "Broadband LEO Satellite Communications: Architectures and Key Technologies," IEEE Wireless Communications, Vol. 26, No. 2, April 2019.
[2] MATLAB. Version 202Ab, "Coverage Maps for Satellite Constellation" link: https://kr.mathworks.com/help/satcom/ug/coverage-maps-for-satellite-constellation.html
