# 완전순열 제비뽑기

### 간단 실행 명령어
```docker compose up -d```

1. Nginx
 - 80으로 호스팅됨.
 - 리버스 프록시 설정을 진행함. '/' 요청 시 flask container(random_draw : 5180)으로 라우팅 진행.

2. Flask
 - Flask와 random을 사용하여 각 유저들이 쪽지에 이름을 적어넣으면 랜덤으로 뽑아줌.
 - 완전 순열을 성립하기 위해 작성함.
 - 실시간 반영을 위해 AJAX을 통해서 비동기 갱신을 진행함.

3. Docker
 - 확장성 및 로드밸런싱을 위해 docker Network 및 compose 활용.
 - nginx config를 사전에 작성하여 volume으로 잡아둠.
 - 리버스 프록시만 사용함.

4. deploy
 - blue-green 배포 방식으로 채택
 - sh를 통해 blue / green 컨테이너 존재 여부 파악 후 반대 색상 컨테이너 실행
 - Jenkinsfile 참조


### 배포 방식
 - git push 트리거를 인식
 - github webhook을 통한 jenkins 트리거 작동
 - jenkins 빌드 실행
 - private ssh protocol을 세팅하여 ssh agent가 작동 가능토록 함 (credential 사전 세팅)
    - git token
    - ssh key
 - 빌드 진행 : jenkins 빌드 확인
 - 트리거 체크하기
