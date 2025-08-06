import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    message: String,
    type: { type: String, default: "default" },
    duration: { type: Number, default: 3000 }
  }

  connect() {
    this.show()
  }

  show() {
    // 애니메이션 적용
    requestAnimationFrame(() => {
      this.element.classList.add("animate-slide-up", "opacity-100")
      this.element.classList.remove("opacity-0", "translate-y-2")
    })

    // 자동 숨김
    if (this.durationValue > 0) {
      this.hideTimeout = setTimeout(() => {
        this.hide()
      }, this.durationValue)
    }
  }

  hide() {
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout)
    }

    this.element.classList.remove("animate-slide-up", "opacity-100")
    this.element.classList.add("opacity-0", "translate-y-2")

    setTimeout(() => {
      this.element.remove()
    }, 300)
  }

  // 전역 함수로 토스트 표시
  static showToast(message, type = "default", duration = 3000) {
    const container = document.getElementById("toast-container") || createToastContainer()
    
    const toast = document.createElement("div")
    toast.innerHTML = `
      <div data-controller="toast" 
           data-toast-message-value="${message}"
           data-toast-type-value="${type}"
           data-toast-duration-value="${duration}"
           class="toast-item ${getToastClasses(type)}">
        <div class="flex items-center">
          <span class="flex-1">${message}</span>
          <button data-action="click->toast#hide" class="ml-4 text-white/70 hover:text-white">
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      </div>
    `
    
    container.appendChild(toast.firstElementChild)
  }
}

// 토스트 컨테이너 생성
function createToastContainer() {
  const container = document.createElement("div")
  container.id = "toast-container"
  container.className = "fixed bottom-4 right-4 z-50 space-y-2"
  document.body.appendChild(container)
  return container
}

// 토스트 타입별 클래스
function getToastClasses(type) {
  const base = "p-4 rounded-lg shadow-lg transform transition-all duration-300 opacity-0 translate-y-2 min-w-[300px]"
  
  const types = {
    default: "bg-gray-900 text-white",
    success: "bg-green-500 text-white",
    error: "bg-red-500 text-white",
    warning: "bg-yellow-500 text-white",
    info: "bg-blue-500 text-white"
  }
  
  return `${base} ${types[type] || types.default}`
}

// 전역 함수로 등록
window.showToast = ToastController.showToast