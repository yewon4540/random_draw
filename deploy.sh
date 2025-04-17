#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "▶ 도커 네트워크 확인 중"
# 네트워크 없으면 생성
if ! docker network ls | grep -q draw_net; then
  echo "▶ ❌ 도커 네트워크가 발견되지 않았습니다."
  docker network create draw_network
  echo "▶ 도커 네트워크 생성 완료"
fi


echo "▶ 현재 컨테이너 상태 확인 중..."

if docker ps --format '{{.Names}}' | grep -q draw_blue; then
  CURRENT=blue
  NEXT=green
elif docker ps --format '{{.Names}}' | grep -q draw_green; then
  CURRENT=green
  NEXT=blue
else
  echo "⭐ 현재 실행 중인 앱 컨테이너가 없습니다. 초기 배포로 간주합니다."
  CURRENT=none
  NEXT=blue
fi

echo "➡️  새로 배포할 컨테이너: $NEXT"

# 새 컨테이너 실행
docker-compose -f ${NEXT}.yml up -d --build

echo "⏳ 헬스체크 진행 중..."

HEALTH_OK=false

for i in $(seq 1 10); do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5179/health || true)
  if [ "$STATUS" = "200" ]; then
	  echo "✅ 헬스체크 성공! ;) ($STATUS)"
    HEALTH_OK=true
    break
  else
    echo "❗ 아직 응답 없음... 대기 중 ($i/10) → 상태코드: $STATUS"
    sleep 5
  fi
done

if [ "$HEALTH_OK" != "true" ]; then
  echo "❌ 헬스체크 실패! 배포 중단"
  exit 1
fi

# nginx 설정 변경
echo "🔧 Nginx proxy_pass 대상 수정: draw_${NEXT}"
sed -i "s|proxy_pass .*|proxy_pass http://draw_${NEXT}:5179/;|" nginx.conf/conf.d/default.conf

# nginx up or restart
if docker ps --format '{{.Names}}' | grep -q web_server; then
  echo "🔄 nginx 컨테이너 재시작"
  docker-compose -f nginx.yml restart
else
  echo "🚀 nginx 컨테이너가 꺼져 있어 새로 실행합니다"
  docker-compose -f nginx.yml up -d
fi

# 이전 컨테이너 중단
if [ "$CURRENT" != "none" ]; then
  echo "🧹 이전 컨테이너($CURRENT) 종료"
  docker-compose -f ${CURRENT}.yml down
else
  echo "ℹ️ 초기 배포이므로 종료할 이전 컨테이너 없음"
fi

