import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "overlay"]
  static values = { open: Boolean }

  connect() {
    // ESC 키로 닫기
    this.handleKeydown = this.handleKeydown.bind(this)
    
    if (this.openValue) {
      this.open()
    }
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown)
  }

  open(event) {
    if (event) event.preventDefault()
    
    this.openValue = true
    document.body.style.overflow = "hidden"
    document.addEventListener("keydown", this.handleKeydown)
    
    // 애니메이션
    requestAnimationFrame(() => {
      this.element.classList.remove("hidden")
      this.overlayTarget.classList.remove("opacity-0")
      this.overlayTarget.classList.add("opacity-100")
      this.contentTarget.classList.remove("opacity-0", "scale-95")
      this.contentTarget.classList.add("opacity-100", "scale-100")
    })

    // 포커스 트랩
    this.trapFocus()
  }

  close(event) {
    if (event) event.preventDefault()
    
    this.openValue = false
    
    // 애니메이션
    this.overlayTarget.classList.remove("opacity-100")
    this.overlayTarget.classList.add("opacity-0")
    this.contentTarget.classList.remove("opacity-100", "scale-100")
    this.contentTarget.classList.add("opacity-0", "scale-95")
    
    setTimeout(() => {
      this.element.classList.add("hidden")
      document.body.style.overflow = ""
      document.removeEventListener("keydown", this.handleKeydown)
      
      // 포커스 복원
      if (this.previouslyFocused) {
        this.previouslyFocused.focus()
      }
    }, 300)
  }

  closeOnOverlay(event) {
    if (event.target === this.overlayTarget) {
      this.close()
    }
  }

  handleKeydown(event) {
    if (event.key === "Escape" && this.openValue) {
      this.close()
    }
  }

  trapFocus() {
    this.previouslyFocused = document.activeElement
    
    const focusableElements = this.contentTarget.querySelectorAll(
      'a[href], button, textarea, input[type="text"], input[type="radio"], input[type="checkbox"], select'
    )
    
    const firstFocusable = focusableElements[0]
    const lastFocusable = focusableElements[focusableElements.length - 1]
    
    firstFocusable?.focus()
    
    this.contentTarget.addEventListener("keydown", (e) => {
      if (e.key !== "Tab") return
      
      if (e.shiftKey) {
        if (document.activeElement === firstFocusable) {
          lastFocusable.focus()
          e.preventDefault()
        }
      } else {
        if (document.activeElement === lastFocusable) {
          firstFocusable.focus()
          e.preventDefault()
        }
      }
    })
  }
}