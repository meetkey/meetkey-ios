# 🚀 MEETKEY

![배너 이미지 또는 로고](링크)

> 간단한 한 줄 소개 – 프로젝트의 핵심 가치 또는 기능

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)]()
[![Xcode](https://img.shields.io/badge/Xcode-16.0-blue.svg)]()
[![License](https://img.shields.io/badge/license-MIT-green.svg)]()

---

<br>

## 👥 멤버
| 주디 | 하이빈 | 블루 | 제로 |
|:------:|:------:|:------:|:------:|
| 사진1 | 사진2 | 사진3 | 사진4 |
| iOS | iOS | iOS | iOS |
| [GitHub](https://github.com/kangjooy0ung) | [GitHub](https://github.com/oevinqu) | [GitHub](https://github.com/bluesummerskin) | [GitHub](https://github.com/sum130) |

<br>


## 📱 소개

> 프로젝트의 주요 목적과 사용자가 얻게 될 경험을 설명해주세요.

<br>

## 📆 프로젝트 기간
- 전체 기간: `YYYY.MM.DD - YYYY.MM.DD`
- 개발 기간: `YYYY.MM.DD - YYYY.MM.DD`

<br>

## 🤔 요구사항
For building and running the application you need:

iOS 26.0 <br>
Xcode 26 <br>
Swift 6.2

<br>

## ⚒️ 개발 환경
* Front : SwiftUI
* 버전 및 이슈 관리 : Github, Github Issues
* 협업 툴 : Discord, Notion

<br>

## 🔎 기술 스택
### Envrionment
<div align="left">
<img src="https://img.shields.io/badge/git-%23F05033.svg?style=for-the-badge&logo=git&logoColor=white" />
<img src="https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white" />
<img src="https://img.shields.io/badge/SPM-FA7343?style=for-the-badge&logo=swift&logoColor=white" />
<img src="https://img.shields.io/badge/Fastlane-n?style=for-the-badge&logo=fastlane&logoColor=black" />
</div>

### Development
<div align="left">
<img src="https://img.shields.io/badge/Xcode-007ACC?style=for-the-badge&logo=Xcode&logoColor=white" />
<img src="https://img.shields.io/badge/Firebase-DD2C00?style=for-the-badge&logo=Firebase&logoColor=white" />
<img src="https://img.shields.io/badge/SwiftUI-42A5F5?style=for-the-badge&logo=swift&logoColor=white" />
<img src="https://img.shields.io/badge/Alamofire-FF5722?style=for-the-badge&logo=swift&logoColor=white" />
<img src="https://img.shields.io/badge/Moya-8A4182?style=for-the-badge&logo=swift&logoColor=white" />
<img src="https://img.shields.io/badge/Kingfisher-0F92F3?style=for-the-badge&logo=swift&logoColor=white" />
<img src="https://img.shields.io/badge/Combine-FF2D55?style=for-the-badge&logo=apple&logoColor=white" />
</div>

### Communication
<div align="left">
<img src="https://img.shields.io/badge/Miro-FFFC00.svg?style=for-the-badge&logo=Miro&logoColor=050038" />
<img src="https://img.shields.io/badge/Notion-white.svg?style=for-the-badge&logo=Notion&logoColor=000000" />
<img src="https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=Discord&logoColor=white" />
<img src="https://img.shields.io/badge/Figma-F24E1E?style=for-the-badge&logo=figma&logoColor=white" />
</div>

<br>

## 📱 화면 구성
<table>
  <tr>
    <td>
      사진 넣어주세요
    </td>
    <td>
      사진 넣어주세요
    </td>
   
  </tr>
</table>

## 🔖 브랜치 컨벤션

### 1. 브랜치 전략
모든 개발은 `dev` 브랜치를 기준으로 진행합니다.
- **main**: 배포 가능한 상태의 최종 코드만 관리합니다.
- **dev**: 개발 중인 코드가 모이는 곳입니다. (Default Branch)
- **feat**: 새로운 기능 개발 브랜치입니다.
- **fix**: 버그 수정 브랜치입니다.

### 2. 브랜치 명명 규칙
> `타입/#이슈번호-설명`

이슈 번호를 포함하여 어떤 작업인지 명확히 식별합니다.
- `feat/#1-login-view`
- `fix/#3-crash-error`
- `design/#5-home-layout`

<br>

## 🌀 코딩 컨벤션

### 1. Naming Rules
- **Class, Struct, Enum**: `UpperCamelCase` (대문자 시작)
    - 예: `LoginViewController`, `UserMenu`
- **Variable, Function**: `lowerCamelCase` (소문자 시작)
    - 예: `viewDidLoad`, `userName`
- **Action Function**: 동작이 명확한 동사로 시작합니다.
    - 예: `didTapLoginButton`, `fetchUserData`

### 2. Architecture (MVVM)
- **View**: UI 구성과 사용자 입력만 담당합니다.
- **ViewModel**: 비즈니스 로직을 담당하며, `import UIKit`을 사용하지 않습니다. (순수 로직 유지)
- **Role**: 뷰컨트롤러가 비대해지지 않도록 로직 분리에 집중합니다.

### 3. Code Style
- **강제 언래핑 지양**: 앱 안정성을 위해 `!` 대신 `guard let` 또는 `if let`을 사용합니다.
- **함수 분리**: 하나의 함수가 너무 길어지지 않도록, 기능별로 작게 나눕니다.
- **주석 활용**: 복잡한 로직이나 팀원 간 공유가 필요한 부분에는 주석을 작성합니다.
 
<br>

## 📁 PR 컨벤션
* PR 시, 템플릿이 등장한다. 해당 템플릿에서 작성해야할 부분은 아래와 같다
    1. `PR 유형 작성`, 어떤 변경 사항이 있었는지 [] 괄호 사이에 x를 입력하여 체크할 수 있도록 한다.
    2. `작업 내용 작성`, 작업 내용에 대해 자세하게 작성을 한다.
    3. `추후 진행할 작업`, PR 이후 작업할 내용에 대해 작성한다
    4. `리뷰 포인트`, 본인 PR에서 꼭 확인해야 할 부분을 작성한다.
    6. `PR 태그 종류`, PR 제목의 태그는 아래 형식을 따른다.

#### 🌟 태그 종류 (커밋 컨벤션과 동일)
<!-- 팀원들끼리 협의하여 기록해주세요! -->

### ✅ PR 예시 모음
> 🎉 [Chore] 프로젝트 초기 세팅 <br>
> ✨ [Feat] 프로필 화면 UI 구현 <br>
> 🐛 [Fix] iOS 17에서 버튼 클릭 오류 수정 <br>
> 💄 [Design] 로그인 화면 레이아웃 조정 <br>
> 📝 [Docs] README에 프로젝트 소개 추가 <br>

<br>

## 📑 커밋 컨벤션

### 💬 깃모지 가이드

| 아이콘 | 코드 | 설명 | 원문 |
| :---: | :---: | :---: | :---: |
| 🐛 | bug | 버그 수정 | Fix a bug |
| ✨ | sparkles | 새 기능 | Introduce new features |
| 💄 | lipstick | UI/스타일 파일 추가/수정 | Add or update the UI and style files |
| ♻️ | recycle | 코드 리팩토링 | Refactor code |
| ➕ | heavy_plus_sign | 의존성 추가 | Add a dependency |
| 🔀 | twisted_rightwards_arrows | 브랜치 합병 | Merge branches |
| 💡 | bulb | 주석 추가/수정 | Add or update comments in source code |
| 🔥 | fire | 코드/파일 삭제 | Remove code or files |
| 🚑 | ambulance | 긴급 수정 | Critical hotfix |
| 🎉 | tada | 프로젝트 시작 | Begin a project |
| 🔒 | lock | 보안 이슈 수정 | Fix security issues |
| 🔖 | bookmark | 릴리즈/버전 태그 | Release / Version tags |
| 📝 | memo | 문서 추가/수정 | Add or update documentation |
| 🔧| wrench | 구성 파일 추가/삭제 | Add or update configuration files.|
| ⚡️ | zap | 성능 개선 | Improve performance |
| 🎨 | art | 코드 구조 개선 | Improve structure / format of the code |
| 📦 | package | 컴파일된 파일 추가/수정 | Add or update compiled files |
| 👽 | alien | 외부 API 변경 반영 | Update code due to external API changes |
| 🚚 | truck | 리소스 이동, 이름 변경 | Move or rename resources |
| 🙈 | see_no_evil | .gitignore 추가/수정 | Add or update a .gitignore file |

### 🏷️ 커밋 태그 가이드
<!-- 팀원들끼리 협의하여 기록해주세요! -->

### ✅ 커밋 예시 모음
> 🎉 [Chore] 프로젝트 초기 세팅 <br>
> ✨ [Feat] 프로필 화면 UI 구현 <br>
> 🐛 [Fix] iOS 17에서 버튼 클릭 오류 수정 <br>
> 💄 [Design] 로그인 화면 레이아웃 조정 <br>
> 📝 [Docs] README에 프로젝트 소개 추가 <br>

<br>

## 🗂️ 폴더 컨벤션
```
```
