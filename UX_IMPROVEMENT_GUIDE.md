# 🎨 BDR UX/UI 개선 가이드 (shadcn 패턴 적용)

## 📋 개요
shadcn/ui의 디자인 패턴을 Rails 환경에 적용하여 BDR 플랫폼의 사용자 경험을 개선하는 가이드입니다.

## 🚀 구현된 컴포넌트

### 1. ButtonComponent
다양한 스타일과 크기의 버튼 컴포넌트

**사용법:**
```erb
<%= render ButtonComponent.new(variant: :primary, size: :lg) do %>
  경기 신청하기
<% end %>
```

**옵션:**
- `variant`: `:default`, `:destructive`, `:outline`, `:secondary`, `:ghost`, `:link`
- `size`: `:default`, `:sm`, `:lg`, `:icon`

### 2. CardComponent
구조화된 카드 레이아웃

**사용법:**
```erb
<%= render CardComponent.new do |card| %>
  <% card.with_header do %>
    <h3>제목</h3>
  <% end %>
  <% card.with_footer do %>
    푸터 내용
  <% end %>
<% end %>
```

### 3. BadgeComponent
상태 표시용 뱃지

**사용법:**
```erb
<%= render BadgeComponent.new(variant: :success) do %>
  승인됨
<% end %>
```

**옵션:**
- `variant`: `:default`, `:secondary`, `:destructive`, `:outline`, `:success`, `:warning`, `:info`

### 4. SkeletonComponent
로딩 상태 표시

**사용법:**
```erb
<%= render SkeletonComponent.new(type: :card) %>
<%= render SkeletonComponent.new(type: :text, lines: 3) %>
```

### 5. Toast 알림 (JavaScript)
모던한 알림 시스템

**사용법:**
```javascript
showToast("경기 신청이 완료되었습니다!", "success");
showToast("오류가 발생했습니다.", "error");
```

### 6. Dialog Controller (Stimulus)
모달 다이얼로그 관리

**사용법:**
```erb
<div data-controller="dialog" class="hidden">
  <div data-dialog-target="overlay" class="fixed inset-0 bg-black/50"></div>
  <div data-dialog-target="content" class="fixed inset-0 flex items-center justify-center">
    <!-- 모달 내용 -->
  </div>
</div>
```

## 🎨 CSS 변수 시스템

`app/assets/stylesheets/components.css`에 정의된 CSS 변수를 통해 일관된 디자인 유지:

```css
:root {
  --primary: 24 100% 50%; /* BDR 오렌지 */
  --secondary: 217 91% 60%; /* 파란색 */
  --radius: 0.5rem;
}
```

## 📝 적용 방법

### 1. 의존성 설치
```bash
bundle add view_component
bundle install
```

### 2. CSS 임포트
`app/assets/stylesheets/application.css`에 추가:
```css
@import "components";
```

### 3. JavaScript 컨트롤러 등록
`app/javascript/controllers/index.js`에 추가:
```javascript
import DialogController from "./dialog_controller"
import ToastController from "./toast_controller"

application.register("dialog", DialogController)
application.register("toast", ToastController)
```

## 🔄 기존 코드 마이그레이션

### Before (기존 코드):
```erb
<button class="bg-orange-500 hover:bg-orange-600 text-white px-6 py-2 rounded-lg">
  신청하기
</button>
```

### After (개선된 코드):
```erb
<%= render ButtonComponent.new(variant: :primary) do %>
  신청하기
<% end %>
```

## 📊 개선 효과

1. **일관성**: 모든 UI 요소가 통일된 디자인 시스템 사용
2. **재사용성**: 컴포넌트 기반으로 코드 중복 제거
3. **유지보수**: 한 곳에서 스타일 관리
4. **접근성**: ARIA 속성과 키보드 네비게이션 기본 지원
5. **성능**: 최적화된 CSS와 JavaScript

## 🚧 향후 계획

### Phase 1 (즉시 적용)
- [x] Button, Card, Badge 컴포넌트
- [x] Toast 알림 시스템
- [x] Skeleton 로딩
- [ ] Form 컴포넌트 개선

### Phase 2 (2주 내)
- [ ] Calendar 컴포넌트 (경기 일정 선택)
- [ ] Sheet 컴포넌트 (사이드바 필터)
- [ ] Command 컴포넌트 (검색 인터페이스)

### Phase 3 (1개월 내)
- [ ] 다크 모드 지원
- [ ] 차트 컴포넌트
- [ ] 데이터 테이블 개선

## 💡 사용 팁

1. **컴포넌트 조합**: 여러 컴포넌트를 조합하여 복잡한 UI 구성
2. **커스터마이징**: `class` 파라미터로 추가 스타일 적용 가능
3. **반응형**: 모든 컴포넌트는 모바일 우선 설계
4. **성능**: Turbo와 함께 사용하여 SPA 같은 경험 제공

## 🐛 문제 해결

### ViewComponent가 로드되지 않는 경우:
```ruby
# config/application.rb
config.view_component.preview_paths << "#{Rails.root}/test/components/previews"
```

### Stimulus 컨트롤러가 작동하지 않는 경우:
```bash
rails stimulus:manifest:update
```

---
*이 가이드는 지속적으로 업데이트됩니다.*