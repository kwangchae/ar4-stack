## 버전 관리 정책 (SemVer + 서브모듈)

본 문서는 ar4-stack(상위 리포)와 두 서브모듈(ros2-ar4-ws, unity-ar4-sim)에 적용되는 버전/릴리스 원칙을 정의합니다.

### 목적
- 재현 가능한 빌드: 상위 리포가 서브모듈 커밋 해시를 고정(pinned)
- 명확한 릴리스 의미: SemVer로 변경 범위와 영향도를 표현
- 단순한 운영: 일관된 브랜치/PR/태깅 흐름 유지

### 브랜치 전략
- 기본: trunk-based 개발
  - 상위/서브모듈 모두 `main`을 안정 상태로 유지
  - 기능 작업은 짧은 수명의 `feature/<name>` 브랜치에서 진행 후 PR 머지
- 릴리스 분기(선택): 장기 유지가 필요하면 `release/x.y` 브랜치 운영, 버그픽스만 수용

### 버전 규칙 (SemVer)
- 형식: `MAJOR.MINOR.PATCH` (예: `v1.4.2`)
- 증가 기준
  - MAJOR: API/사용법의 호환 불가 변경, 데이터/구성의 중대한 변화
  - MINOR: 하위 호환 신규 기능, 개선
  - PATCH: 하위 호환 버그 수정, 문서/빌드 스크립트 소규모 변경

### 태깅 규칙
- 서브모듈 각각 독립적으로 태깅: `vX.Y.Z`
- 상위 리포도 동일 버전으로 태깅하며, 태그 메시지에 두 서브모듈의 참조를 기록
  - 예시 메시지
    - `ros2-ar4-ws: v1.4.0 (abc123)`
    - `unity-ar4-sim: v1.4.0 (def456)`

### 서브모듈 업데이트 흐름
1) 서브모듈에서 작업 완료 → PR 머지 → 태그 생성/푸시
2) 상위 리포에서 서브모듈 포인터 업데이트(PR)
   - `git -C <submodule> fetch --tags --all`
   - `git -C <submodule> checkout <tag-or-commit>`
   - 상위 리포 루트에서 `git add <submodule>`
   - 커밋 메시지 예: `chore: bump <submodule> to <tag>`
3) 상위 리포 PR 머지 후 태그(필요 시) 생성/푸시

> 참고: 통합 검증 목적으로만 `git submodule update --remote --ff-only`를 사용하세요. 상시 추적은 재현성을 해칠 수 있습니다.

### 릴리스 절차 (권장 체크리스트)
- [서브모듈] 변경사항 머지, 테스트 통과
- [서브모듈] 버전 산정(SemVer) 및 태그 푸시
- [상위] 두 서브모듈 포인터 최신으로 bump → PR
- [상위] 릴리스 태그 생성: `vX.Y.Z`
- [상위] 릴리스 노트: 포함된 서브모듈 버전/커밋, 주요 변경, 마이그레이션 안내

### 핫픽스(패치) 플로우
- 영향 모듈에만 `PATCH` 증가 후 태그
- 상위 리포에서 해당 서브모듈 포인터만 bump → 상위 리포도 `PATCH` 증가

### CI 권장 검사(선택)
- 상위 리포 PR에서 서브모듈이 유효한 커밋/태그를 가리키는지 확인
- (Unity) LFS 추적 검증: 큰 바이너리가 LFS 규칙을 따르는지 검사
- (ROS2) linters/format/빌드 검증

### 유용한 명령어
```bash
# 서브모듈 초기화/동기화
git submodule update --init --recursive

# 특정 태그로 서브모듈 고정
git -C unity-ar4-sim fetch --tags --all
git -C unity-ar4-sim checkout v1.4.0

# 상위 리포에서 포인터 커밋
git add unity-ar4-sim
git commit -m "chore: bump unity-ar4-sim to v1.4.0"

# 최신 태그로 빠르게 맞추기(검증 용)
git submodule update --remote --ff-only
```

### 변경을 유발하는 예시
- MAJOR: ROS2 메시지 타입 변경, 핵심 토픽/서비스명 변경, Unity API 사용법 변경
- MINOR: 신규 노드/스크립트/씬 추가, 옵션 파라미터 추가
- PATCH: 버그 수정, 성능 튜닝, 문서/예제/CI 수정

---
본 정책은 프로젝트 상황에 맞춰 조정될 수 있으며, 변경 시 PR로 문서부터 업데이트합니다.
