# BDR ViewComponents

이 디렉토리는 shadcn/ui 디자인 패턴을 Rails ViewComponent로 구현한 컴포넌트들을 포함합니다.

## 설치

```bash
bundle add view_component
rails generate component Example
```

## 사용법

### Button Component
```erb
<%= render ButtonComponent.new(variant: :primary, size: :lg) do %>
  경기 신청하기
<% end %>
```

### Card Component
```erb
<%= render CardComponent.new do |card| %>
  <% card.with_header do %>
    <h3>경기 정보</h3>
  <% end %>
  
  <% card.with_body do %>
    <!-- 내용 -->
  <% end %>
<% end %>
```

### Dialog Component
```erb
<%= render DialogComponent.new(id: "game-apply") do |dialog| %>
  <% dialog.with_trigger do %>
    <button>경기 신청</button>
  <% end %>
  
  <% dialog.with_content do %>
    <!-- 모달 내용 -->
  <% end %>
<% end %>
```

## 컴포넌트 목록

- **ButtonComponent**: 다양한 스타일의 버튼
- **CardComponent**: 카드 레이아웃
- **DialogComponent**: 모달 다이얼로그
- **ToastComponent**: 알림 메시지
- **SkeletonComponent**: 로딩 스켈레톤
- **BadgeComponent**: 상태 뱃지

## 디자인 시스템

CSS 변수를 통해 일관된 디자인을 유지합니다:

```css
:root {
  --radius: 0.5rem;
  --primary: 24 100% 50%; /* 오렌지 */
  --secondary: 217 91% 60%; /* 파란색 */
  --destructive: 0 84% 60%; /* 빨간색 */
}
```