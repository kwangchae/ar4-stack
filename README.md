# AR4 Robot Stack 🤖

**통합 AR4 로봇 제어 시스템** - ROS2 워크스페이스와 Unity 시뮬레이션을 서브모듈로 통합한 메타 저장소입니다.

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

## 🚀 빠른 시작

### 1. 전체 시스템 클론
```bash
git clone --recursive https://github.com/kwangchae/ar4-stack.git
cd ar4-stack
```

### 2. ROS2 환경 설정
```bash
cd ros2-ar4-ws
colcon build
source install/setup.bash
```

### 3. ROS TCP 서버 시작
```bash
ros2 run ros_tcp_endpoint default_server_endpoint --ros-args -p ROS_IP:=0.0.0.0
```

### 4. Unity 프로젝트 실행
```bash
cd ../unity-ar4-sim
# Unity Hub에서 프로젝트 열기
```

### 5. MoveIt 실행
```bash
cd ros2-ar4-ws
ros2 launch annin_ar4_moveit_config demo.launch.py
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
# 1. 서브모듈 업데이트
git submodule update --remote

# 2. 각 서브모듈에서 작업
cd ros2-ar4-ws
git checkout -b feature/new-controller
# 작업 후 커밋 & 푸시

# 3. 메타 저장소 업데이트
cd ..
git add ros2-ar4-ws
git commit -m "Update ROS2 workspace to latest"
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

### 필수 요구사항
- **WSL2**: Ubuntu 24.04+ 
- **ROS2**: Jazzy Jellyfish
- **Unity**: 2022.3 LTS
- **Python**: 3.8+

### 권장 도구
- **VS Code**: ROS 확장 프로그램
- **RViz**: 시각화 및 디버깅
- **Unity Hub**: 프로젝트 관리

## 📊 주요 토픽

| 토픽 | 타입 | 설명 |
|------|------|------|
| `/joint_command` | `JointState` | Unity 로봇 제어 |
| `/joint_states` | `JointState` | 현재 관절 상태 |
| `/trajectory_preview` | `Path` | 궤적 waypoint |
| `/display_planned_path` | `DisplayTrajectory` | MoveIt 계획 |

## 🔧 문제 해결

### 서브모듈 문제
```bash
# 서브모듈이 비어있을 때
git submodule update --init --recursive

# 서브모듈 최신 상태로 업데이트
git submodule update --remote --merge
```

### Unity 연결 문제
```bash
# WSL2 IP 확인
hostname -I

# 방화벽 설정 (Windows)
New-NetFirewallRule -DisplayName "ROS-Unity" -Direction Inbound -Protocol TCP -LocalPort 10000 -Action Allow
```

### ROS2 빌드 문제
```bash
cd ros2-ar4-ws
colcon build --symlink-install
source install/setup.bash
```

## 📝 버전 관리

- **메인 브랜치**: `main` (안정 버전)
- **개발 브랜치**: `develop` (최신 개발)
- **태그 규칙**: `v{major}.{minor}.{patch}`

## 🤝 기여 가이드

1. **이슈 생성**: 버그 리포트 또는 기능 요청
2. **브랜치 생성**: `feature/` 또는 `bugfix/` 접두사
3. **서브모듈 작업**: 각 서브모듈에서 별도 작업
4. **메타 저장소 업데이트**: 서브모듈 변경사항 반영
5. **PR 생성**: 상세한 설명과 함께

## 📚 관련 링크

- **ROS2 워크스페이스**: [ros2-ar4-ws](https://github.com/kwangchae/ros2-ar4-ws)
- **Unity 시뮬레이션**: [unity-ar4-sim](https://github.com/kwangchae/unity-ar4-sim)  
- **AR4 로봇 공식**: [Annin Robotics](https://www.anninrobotics.com/)
- **MoveIt 문서**: [MoveIt2 Official](https://moveit.ros.org/)

---

> 🤖 **AR4 Stack** - 통합 로봇 제어 시스템으로 연구와 교육을 지원합니다.