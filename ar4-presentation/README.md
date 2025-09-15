# AR4 Robot Stack Presentation

AR4 로봇 스택을 소개하는 Slidev 프레젠테이션입니다.

## 🚀 실행 방법

### 개발 모드 (실시간 편집)
```bash
npm run dev
```

### 정적 빌드 (배포용)
```bash
npm run build
```

### PDF 내보내기
```bash
npm run export
```

## 📁 파일 구조

- `slides.md`: 메인 프레젠테이션 파일
- `package.json`: 프로젝트 설정 및 의존성
- `README.md`: 이 파일

## 🎯 프레젠테이션 내용

1. **프로젝트 개요**: AR4 Robot Stack 소개
2. **시스템 아키텍처**: ROS2 + Unity 통합 구조
3. **기술 스택**: 사용된 기술들과 코드 예시
4. **설치 및 실행**: 단계별 설치 가이드
5. **주요 기능**: MoveIt, 키보드 제어, 토픽 통신
6. **문제 해결**: 일반적인 문제와 해결책
7. **향후 계획**: AI 통합, 확장성, 교육 강화
8. **기여 방법**: 개발 참여 가이드

## 🛠️ 기술 스택

- **Slidev**: 개발자 친화적 프레젠테이션 도구
- **Vue.js**: 인터랙티브 컴포넌트
- **Markdown**: 콘텐츠 작성
- **Mermaid**: 다이어그램 생성

## 📝 편집 팁

### 슬라이드 추가
```markdown
---
layout: default
---

# 새 슬라이드 제목

내용 작성...
```

### 코드 하이라이팅
```markdown
```python {2,3|5|all}
def example():
    line1  # 첫 번째 클릭에서 강조
    line2  # 첫 번째 클릭에서 강조

    line3  # 두 번째 클릭에서 강조
```

### 애니메이션 효과
```markdown
<v-click>

애니메이션으로 나타날 내용

</v-click>
```

## 🎨 테마 및 레이아웃

현재 `apple-basic` 테마를 사용 중입니다. 다른 테마는 [Slidev 테마 갤러리](https://sli.dev/themes/gallery.html)에서 확인할 수 있습니다.

사용 가능한 레이아웃:
- `default`: 기본 레이아웃
- `center`: 중앙 정렬
- `image-right`: 오른쪽 이미지
- `two-cols`: 2열 구성

## 📤 배포

### GitHub Pages (자동 배포)

1. **저장소 설정**:
   ```bash
   # 프레젠테이션 폴더를 별도 저장소로 푸시
   cd ar4-presentation
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/ar4-presentation.git
   git push -u origin main
   ```

2. **GitHub Pages 활성화**:
   - 저장소 Settings → Pages
   - Source: GitHub Actions 선택
   - 자동 배포가 설정됩니다!

3. **접속 URL**: `https://YOUR_USERNAME.github.io/ar4-presentation/`

### 수동 배포

#### GitHub Pages (수동)
```bash
npm run build
# dist/ 폴더 내용을 gh-pages 브랜치에 푸시
```

#### Netlify
```bash
npm run build-local
# dist/ 폴더를 Netlify에 드래그 앤 드롭
```

#### Vercel
```bash
npm run build-local
# vercel CLI 또는 웹에서 dist/ 폴더 배포
```

## 📄 라이선스

이 프레젠테이션은 Creative Commons Attribution 4.0 International License (CC BY 4.0) 하에 제공됩니다.