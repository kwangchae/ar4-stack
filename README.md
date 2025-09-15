# AR4 Robot Stack 🤖

**통합 AR4 로봇 제어 시스템** - ROS2 워크스페이스와 Unity 시뮬레이션을 서브모듈로 통합한 메타 저장소입니다.

## 📑 목차

- 버전 관리 정책: [VERSIONING.md](./VERSIONING.md)

## 🏗️ 아키텍처

```
ar4-stack/                    ← 메타 저장소
├── ros2-ar4-ws/             ← ROS2 워크스페이스 (서브모듈)
│   ├── src/ar4_ros_driver/   
│   ├── src/ROS-TCP-Endpoint/
│   └── src/*.py              ← 제어 스크립트들
├── unity-ar4-sim/           ← Unity 시뮬레이션 (서브모듈)  
│   ├── Assets/
│   ├── ProjectSettings/
│   └── README.md
└── README.md                 ← 이 파일
```

## 🐳 Docker로 실행 (ROS2 서버)

Unity는 Windows에서 실행하고, ROS2 TCP 서버만 컨테이너로 실행하는 구성을 권장합니다.

### 1) 이미지 빌드
```bash
docker compose build
```

### 2) ROS TCP 서버 실행
```bash
docker compose up
```
- 컨테이너가 포트 `10000`을 열고 `0.0.0.0:10000`에서 대기합니다.
- Unity의 ROS 설정은 기존과 동일하게 WSL2/호스트 IP + 포트 `10000`을 사용하면 됩니다.

### 3) 권장 옵션
- 호스트 파일 권한 보존: `user` 옵션으로 UID/GID 매핑
  - `docker compose run --rm --user "$(id -u):$(id -g)" ros bash`
- 실기(USB) 연결 시: `--privileged`와 `--device=/dev/ttyUSB0` 등을 추가하여 별도 서비스 구성

참고: 컨테이너는 `./ros2-ar4-ws`를 `/ws`로 마운트하여 빌드/실행합니다.

### 4) 실기 연결용 서비스 (USB)
```bash
# 기본 서버(소프트 시뮬레이션):
docker compose up ros

# 하드웨어(USB) 연결용:
docker compose up ros-hw
```
- `ros-hw` 서비스는 `--privileged`와 `/dev/ttyUSB0`, `/dev/ttyACM0` 디바이스를 컨테이너에 전달합니다.
- 다른 포트를 쓴다면 `devices` 매핑을 수정하세요. (예: `/dev/ttyUSB1`)
- 권한 이슈가 있으면 `group_add: [dialout]`가 적용된 이 서비스를 사용하거나, `user: "$(id -u):$(id -g)"` 옵션을 추가하세요.

### (대안) 로컬에서 서버+브리지 한 번에 실행
```bash
cd ar4-stack/ros2-ar4-ws
./scripts/run_server_and_bridge.sh \
  # 선택 환경변수: \
  # ROS_IP=0.0.0.0 ROS_TCP_PORT=10000 \
  # CONTROLLER_NAME=joint_trajectory_controller \
  # PREVIEW_TOPIC=/trajectory_preview COMMAND_TOPIC=/joint_command
```

## 🚀 완전 초보자 가이드

### 🔧 사전 준비사항

#### 1. Windows 11 + WSL2 설치
```powershell
# PowerShell 관리자 모드에서 실행
wsl --install Ubuntu-24.04
wsl --set-default-version 2
```

#### 2. ROS2 Jazzy 설치 (WSL2 Ubuntu 24.04)
```bash
# 시스템 업데이트
sudo apt update && sudo apt upgrade -y

# ROS2 키 및 저장소 추가
sudo apt install software-properties-common
sudo add-apt-repository universe
sudo apt update && sudo apt install curl -y
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# ROS2 Jazzy 설치
sudo apt update
sudo apt install ros-jazzy-desktop python3-argcomplete -y
sudo apt install python3-colcon-common-extensions python3-pip python3-rosdep -y

# 환경 설정 자동화
echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
source ~/.bashrc

# rosdep 초기화
sudo rosdep init
rosdep update
```

#### 3. Unity Hub 및 Unity 6000.2.3f1 설치 (Windows)
1. [Unity Hub 다운로드](https://unity3d.com/get-unity/download)
2. Unity Hub에서 **Unity 6000.2.3f1** 설치
3. **Windows Build Support** 모듈 포함하여 설치

### 📦 프로젝트 설치

#### 1. 전체 시스템 클론
```bash
# WSL2 Ubuntu에서 실행
git clone --recursive https://github.com/kwangchae/ar4-stack.git
cd ar4-stack

# 서브모듈이 제대로 클론되었는지 확인
ls -la ros2-ar4-ws/ unity-ar4-sim/
```

#### 2. ROS2 워크스페이스 빌드
```bash
cd ros2-ar4-ws

# 의존성 설치
rosdep install --from-paths . --ignore-src -r -y

# 워크스페이스 빌드
colcon build --symlink-install

# 환경 설정 로드
source install/setup.bash

# 빌드 확인
ros2 pkg list | grep annin
```

#### 3. Unity 프로젝트 설정
```bash
# WSL2에서 IP 주소 확인 (Unity 설정에 필요)
hostname -I
# 출력 예: 172.27.144.1 (이 값을 기억해두세요)
```

**Unity에서 설정:**
1. Unity Hub에서 `ar4-stack/unity-ar4-sim` 폴더를 **프로젝트로 추가**
2. 프로젝트 열기
3. **Package Manager** 열기 (`Window > Package Manager`)
4. **[+] > Add package from git URL** 선택하고 다음 URL들을 **순서대로** 추가:
   ```
   https://github.com/Unity-Technologies/URDF-Importer.git?path=/com.unity.robotics.urdf-importer#v0.5.2
   https://github.com/Unity-Technologies/ROS-TCP-Connector.git?path=/com.unity.robotics.ros-tcp-connector#v0.7.0
   ```
5. **Robotics > ROS Settings** 메뉴 열기
6. 다음과 같이 설정:
   - **ROS IP Address**: WSL2 IP (예: `172.27.144.1`)
   - **ROS Port**: `10000`
   - **Protocol**: `TCP`

### 🎯 실행 가이드

#### 터미널 1: ROS TCP 서버 시작
```bash
cd ar4-stack/ros2-ar4-ws
source install/setup.bash
ros2 run ros_tcp_endpoint default_server_endpoint --ros-args -p ROS_IP:=0.0.0.0
```
✅ **성공 메시지**: `Starting server on 0.0.0.0:10000`

#### 터미널 2: MoveIt 실행
```bash
cd ar4-stack/ros2-ar4-ws
source install/setup.bash
ros2 launch annin_ar4_moveit_config demo.launch.py
```
✅ **성공 메시지**: RViz 창이 열리고 AR4 로봇 모델이 표시됨

#### 터미널 3: MoveIt ↔ Unity 브리지 실행
```bash
cd ar4-stack/ros2-ar4-ws
source install/setup.bash
python3 src/moveit_bridge.py
```
✅ **효과**:
- Plan 수행 시: Unity에 `/trajectory_preview`로 웨이포인트 스트림 전송 → 노란 웨이포인트 표시
- Execute 수행 시: 컨트롤러 토픽 또는 실행 액션 상태를 감지하여 `/joint_command`로 포인트들을 순차 전송 → Unity 로봇이 따라감

#### Unity 실행
1. Unity에서 **Play** 버튼 클릭
2. **터미널 1**에서 연결 메시지 확인:
   ```
   Connection from 172.27.144.1
   RegisterSubscriber(...) OK
   RegisterPublisher(...) OK
   ```

### 🎮 사용법

#### RViz에서 로봇 제어
1. RViz에서 **MotionPlanning** 패널 확인
2. **Interactive Marker**를 드래그하여 목표 위치 설정
3. **Plan** 버튼 클릭 → Unity에서 노란색 waypoint 확인
4. **Execute** 버튼 클릭 → Unity 로봇이 움직임

#### 추가 제어 스크립트 (선택사항)
```bash
# 터미널 3: 키보드 제어
cd ar4-stack/ros2-ar4-ws
source install/setup.bash
python3 src/simple_keyboard_teleop.py

# 터미널 4: 부드러운 로봇 제어
cd ar4-stack/ros2-ar4-ws
source install/setup.bash
python3 src/smooth_robot_controller.py
```

## 🎯 주요 기능

### 🔧 ROS2 워크스페이스 ([ros2-ar4-ws](https://github.com/kwangchae/ros2-ar4-ws))
- **AR4 드라이버**: 로봇 하드웨어 제어
- **MoveIt 통합**: 경로 계획 및 실행
- **Unity 브릿지**: TCP/IP 통신 스크립트
- **텔레오퍼레이션**: 키보드 제어 시스템

### 🎮 Unity 시뮬레이션 ([unity-ar4-sim](https://github.com/kwangchae/unity-ar4-sim))  
- **3D 로봇 모델**: 실시간 관절 시뮬레이션
- **궤적 시각화**: MoveIt 경로를 3D로 표시
- **ROS2 통신**: WSL2와 실시간 데이터 교환
- **사용자 인터페이스**: 직관적인 로봇 제어

## 🔄 워크플로우

### 개발 워크플로우
```bash
# 1. 서브모듈 초기화/동기화
git submodule update --init --recursive

# 2. 각 서브모듈에서 작업
cd ros2-ar4-ws
git checkout -b feature/new-controller
# 작업 후 커밋 & 푸시 (PR 머지)

# 3. 상위 리포에서 서브모듈 포인터 업데이트
cd ..
git -C ros2-ar4-ws pull --ff-only          # 또는 특정 태그로 고정
# git -C ros2-ar4-ws checkout vX.Y.Z       # 태그로 고정하는 경우
git add ros2-ar4-ws
git commit -m "chore: bump ros2-ar4-ws submodule"
```

### 배포 워크플로우
```bash
# 1. 각 서브모듈 태그 생성
cd ros2-ar4-ws && git tag v1.2.0 && git push --tags
cd ../unity-ar4-sim && git tag v1.2.0 && git push --tags

# 2. 메타 저장소 릴리스
cd ..
git tag v1.2.0 -m "AR4 Stack v1.2.0"
git push --tags
```

## 📡 시스템 통신

```
┌─────────────────────┐    TCP/IP     ┌────────────────────┐
│    WSL2 (ROS2)      │◄─────────────►│  Windows (Unity)   │
│                     │   Port 10000  │                    │
│ ┌─────────────────┐ │               │ ┌────────────────┐ │
│ │ ros2-ar4-ws     │ │               │ │ unity-ar4-sim  │ │  
│ │                 │ │               │ │                │ │
│ │ ├─ MoveIt       │ │               │ │ ├─ AR4 Robot   │ │
│ │ ├─ Controllers  │ │               │ │ ├─ Visualizer  │ │
│ │ ├─ TCP Bridge   │ │               │ │ └─ ROS Manager │ │
│ │ └─ Scripts      │ │               │ │                │ │
│ └─────────────────┘ │               │ └────────────────┘ │
└─────────────────────┘               └────────────────────┘
```

## 🛠️ 개발 환경

### 📋 시스템 요구사항

#### 필수 요구사항
- **운영체제**: Windows 11 (WSL2 지원)
- **WSL2**: Ubuntu 24.04 LTS
- **ROS2**: Jazzy Jellyfish
- **Unity**: 6000.2.3f1 (권장)
- **Python**: 3.10+ (Ubuntu 24.04 기본)
- **Git**: 최신 버전

#### 하드웨어 권장사양
- **CPU**: 4코어 이상 (8코어 권장)
- **RAM**: 16GB 이상 (32GB 권장)
- **GPU**: DirectX 11 지원 (Unity 렌더링용)
- **저장공간**: 20GB 이상 여유공간

#### 권장 개발 도구
- **VS Code**: ROS 및 Python 확장 프로그램
- **Windows Terminal**: 멀티 탭 터미널
- **Git GUI**: GitHub Desktop 또는 SourceTree
- **Unity Hub**: 프로젝트 및 버전 관리

## 📊 주요 토픽

| 토픽 | 타입 | 설명 |
|------|------|------|
| `/joint_command` | `JointState` | Unity 로봇 제어 |
| `/joint_states` | `JointState` | 현재 관절 상태 |
| `/trajectory_preview` | `Path` | 궤적 waypoint |
| `/display_planned_path` | `DisplayTrajectory` | MoveIt 계획 |

## 🔧 문제 해결

### ❗ 일반적인 문제들

#### 1. 서브모듈이 비어있는 경우
```bash
# 서브모듈이 제대로 클론되지 않은 경우
git submodule update --init --recursive

# 서브모듈을 최신 상태로 업데이트(검증용)
git submodule update --remote --ff-only
# 주의: 정식 반영은 서브모듈에서 PR/태그 후 상위 리포에서 포인터를 bump 합니다.
# 자세한 정책은 VERSIONING.md 참고
```

#### 2. ROS2 빌드 실패
```bash
# 의존성 문제 해결
cd ros2-ar4-ws
rosdep install --from-paths . --ignore-src -r -y

# 클린 빌드
colcon build --symlink-install --cmake-clean-cache
source install/setup.bash

# 특정 패키지만 빌드
colcon build --packages-select annin_ar4_description
```

#### 3. Unity 연결 문제
**증상**: Unity에서 "Connection failed" 오류
```bash
# WSL2 IP 주소 재확인
hostname -I

# TCP 서버 포트 확인
netstat -tlnp | grep 10000

# TCP 서버 프로세스 종료 후 재시작
pkill -f default_server_endpoint
ros2 run ros_tcp_endpoint default_server_endpoint --ros-args -p ROS_IP:=0.0.0.0
```

**Windows 방화벽 설정** (PowerShell 관리자 모드):
```powershell
New-NetFirewallRule -DisplayName "ROS-Unity-TCP" -Direction Inbound -Protocol TCP -LocalPort 10000 -Action Allow
New-NetFirewallRule -DisplayName "ROS-Unity-TCP-Out" -Direction Outbound -Protocol TCP -LocalPort 10000 -Action Allow
```

#### 4. Unity 패키지 설치 실패
```bash
# Unity Package Manager에서 오류 발생 시
# 1. Unity 재시작
# 2. Package Manager > In Project > Reset Packages to defaults
# 3. 패키지를 하나씩 순서대로 재설치:
#    - URDF Importer 먼저
#    - ROS TCP Connector 나중에
```

#### 5. MoveIt 실행 오류
```bash
# MoveIt 설정 파일 누락 문제
cd ros2-ar4-ws
source install/setup.bash

# 패키지 설치 확인
ros2 pkg list | grep annin_ar4

# MoveIt 데모 실행 (시뮬레이션만)
ros2 launch annin_ar4_moveit_config demo.launch.py

# 로그 확인
ros2 launch annin_ar4_moveit_config demo.launch.py --ros-args --log-level DEBUG
```

#### 6. Python 스크립트 실행 오류
```bash
# Python 의존성 설치
pip3 install numpy scipy matplotlib

# 스크립트 실행 권한 확인
chmod +x src/*.py

# ROS 환경 로드 확인
echo $ROS_DISTRO  # jazzy가 출력되어야 함
```

### 🆘 고급 문제 해결

#### WSL2 네트워크 문제
```bash
# WSL2와 Windows 간 네트워크 연결 확인
ping $(hostname -I | cut -d' ' -f1)

# WSL2 재시작
wsl --shutdown
wsl
```

#### Unity 성능 최적화
```
Unity Editor Settings:
1. Edit > Project Settings > Player
2. Configuration: Release
3. Scripting Backend: IL2CPP
4. Api Compatibility Level: .NET Standard 2.1
```

### 🔍 로그 및 디버깅

#### ROS2 노드 상태 확인
```bash
# 실행 중인 노드 확인
ros2 node list

# 토픽 목록 확인
ros2 topic list

# 특정 토픽 메시지 확인
ros2 topic echo /joint_states

# 노드 정보 확인
ros2 node info /move_group
```

#### Unity 로그 확인
- Unity Console 창: `Window > General > Console`
- ROS TCP Connector 로그: `Robotics > ROS Settings > Show/Hide ROS TCP Connector Logs`

## 📝 버전 관리

- 브랜치: trunk-based (`main` 안정 유지, 기능은 `feature/*`, 필요 시 `release/x.y`)
- 태그: `v{MAJOR}.{MINOR}.{PATCH}` (SemVer)
- 정책 문서: [VERSIONING.md](./VERSIONING.md) 참고 (서브모듈 bump/릴리스 절차 포함)
- CI 가드: PR에서 서브모듈 포인터가 원격 브랜치/태그에 도달 가능한지 검사하며, `release/*` PR에서는 태그를 요구합니다. 워크플로우: `.github/workflows/submodule-guard.yml`

## 🧾 변경 로그

- 프로젝트의 변경 내역은 [CHANGELOG.md](./CHANGELOG.md)에 기록됩니다.

## ✅ 설치 검증

### 🔍 정상 설치 확인 체크리스트

#### 1. ROS2 설치 확인
```bash
# ROS2 버전 확인
ros2 --version  # ros2 cli version 0.x.x 출력

# ROS 환경 변수 확인
echo $ROS_DISTRO  # jazzy 출력

# ROS2 노드 테스트
ros2 run demo_nodes_py listener &
ros2 run demo_nodes_py talker
# "Hello World: X" 메시지가 계속 출력되면 성공
```

#### 2. 워크스페이스 빌드 확인
```bash
cd ar4-stack/ros2-ar4-ws
source install/setup.bash

# AR4 패키지 설치 확인
ros2 pkg list | grep annin_ar4
# 다음이 모두 출력되어야 함:
# - annin_ar4_description
# - annin_ar4_driver
# - annin_ar4_moveit_config
# - annin_ar4_gazebo

# URDF 파일 확인
ros2 launch annin_ar4_description display.launch.py
# RViz가 열리고 AR4 로봇 모델이 표시되면 성공
```

#### 3. Unity 연결 확인
```bash
# TCP 서버 실행
ros2 run ros_tcp_endpoint default_server_endpoint --ros-args -p ROS_IP:=0.0.0.0

# Unity에서 Play 후 연결 메시지 확인:
# [INFO] [timestamp] [UnityEndpoint]: Connection from 172.x.x.x
```

### 📺 데모 영상 따라하기

성공적인 설치 후 다음 데모를 실행해보세요:

#### 🎥 기본 MoveIt 데모
```bash
# 터미널 1: TCP 서버
ros2 run ros_tcp_endpoint default_server_endpoint --ros-args -p ROS_IP:=0.0.0.0

# 터미널 2: MoveIt 데모
ros2 launch annin_ar4_moveit_config demo.launch.py

# Unity에서 Play 버튼 클릭
# RViz에서 Interactive Marker를 드래그하여 Plan & Execute
```

#### 🎮 키보드 제어 데모
```bash
# 터미널 3: 키보드 제어
python3 src/simple_keyboard_teleop.py

# 키보드로 로봇 제어:
# q/a: 관절 1, w/s: 관절 2, e/d: 관절 3
# r/f: 관절 4, t/g: 관절 5, y/h: 관절 6
```

## 🤝 기여 가이드

### 🛠️ 개발 워크플로우

#### 1. 이슈 및 기능 요청
- **버그 리포트**: 재현 가능한 단계 포함
- **기능 요청**: 구체적인 사용 사례 설명
- **개선 제안**: 현재 문제점과 해결책 제시

#### 2. 브랜치 전략
```bash
# 메인 브랜치에서 새 기능 브랜치 생성
git checkout -b feature/your-feature-name

# 버그 수정용 브랜치
git checkout -b bugfix/issue-description

# 문서 개선용 브랜치
git checkout -b docs/update-readme
```

#### 3. 서브모듈 개발
```bash
# ROS2 워크스페이스 작업
cd ros2-ar4-ws
git checkout -b feature/new-controller
# 개발 작업...
git add . && git commit -m "Add new controller"
git push origin feature/new-controller

# Unity 프로젝트 작업
cd ../unity-ar4-sim
git checkout -b feature/ui-improvement
# 개발 작업...
git add . && git commit -m "Improve UI layout"
git push origin feature/ui-improvement

# 메타 저장소에서 서브모듈 업데이트
cd ..
git add ros2-ar4-ws unity-ar4-sim
git commit -m "Update submodules with new features"
```

#### 4. 풀 리퀘스트 가이드
- **제목**: 간결하고 명확한 변경사항 요약
- **설명**: 상세한 변경 내용과 테스트 결과
- **체크리스트**:
  - [ ] 코드가 빌드되는지 확인
  - [ ] 기존 기능이 정상 동작하는지 확인
  - [ ] 새 기능에 대한 테스트 추가
  - [ ] README 업데이트 (필요시)

### 🧪 테스트 가이드

#### 코드 변경 시 필수 테스트
```bash
# 1. ROS2 빌드 테스트
cd ros2-ar4-ws
colcon build --symlink-install
source install/setup.bash

# 2. MoveIt 데모 실행 테스트
ros2 launch annin_ar4_moveit_config demo.launch.py

# 3. Unity 연결 테스트
ros2 run ros_tcp_endpoint default_server_endpoint --ros-args -p ROS_IP:=0.0.0.0
# Unity에서 Play 후 연결 확인

# 4. 기본 제어 스크립트 테스트
python3 src/simple_keyboard_teleop.py
```

### 📝 커밋 메시지 규칙
```
<type>(<scope>): <subject>

<body>

<footer>
```

**타입**:
- `feat`: 새 기능
- `fix`: 버그 수정
- `docs`: 문서 변경
- `style`: 코드 스타일 변경
- `refactor`: 리팩토링
- `test`: 테스트 추가/수정
- `chore`: 기타 작업

**예시**:
```
feat(moveit): add trajectory smoothing algorithm

- Implement cubic spline interpolation for smoother robot motion
- Add configurable velocity and acceleration limits
- Update MoveIt configuration for improved performance

Closes #123
```

## 📚 관련 링크

- **ROS2 워크스페이스**: [ros2-ar4-ws](https://github.com/kwangchae/ros2-ar4-ws)
- **Unity 시뮬레이션**: [unity-ar4-sim](https://github.com/kwangchae/unity-ar4-sim)  
- **AR4 로봇 공식**: [Annin Robotics](https://www.anninrobotics.com/)
- **MoveIt 문서**: [MoveIt2 Official](https://moveit.ros.org/)

---

> 🤖 **AR4 Stack** - 통합 로봇 제어 시스템으로 연구와 교육을 지원합니다.
