// 이미지 업로드 미리보기 기능
document.addEventListener('DOMContentLoaded', function() {
  const imageInput = document.getElementById('tournament-images');
  const previewContainer = document.getElementById('image-preview');
  
  if (!imageInput || !previewContainer) return;
  
  let selectedFiles = [];
  
  imageInput.addEventListener('change', function(e) {
    const files = Array.from(e.target.files);
    
    // 기존 파일과 합쳐서 5장 제한 체크
    if (selectedFiles.length + files.length > 5) {
      alert('이미지는 최대 5장까지만 업로드할 수 있습니다.');
      imageInput.value = '';
      return;
    }
    
    // 파일 크기 체크 (10MB)
    const maxSize = 10 * 1024 * 1024; // 10MB
    const oversizedFiles = files.filter(file => file.size > maxSize);
    
    if (oversizedFiles.length > 0) {
      alert('10MB를 초과하는 파일이 있습니다.');
      imageInput.value = '';
      return;
    }
    
    // 이미지 파일만 허용
    const validFiles = files.filter(file => file.type.startsWith('image/'));
    
    if (validFiles.length !== files.length) {
      alert('이미지 파일만 업로드할 수 있습니다.');
      imageInput.value = '';
      return;
    }
    
    selectedFiles = [...selectedFiles, ...validFiles];
    displayPreviews();
  });
  
  function displayPreviews() {
    previewContainer.innerHTML = '';
    
    selectedFiles.forEach((file, index) => {
      const reader = new FileReader();
      
      reader.onload = function(e) {
        const previewDiv = document.createElement('div');
        previewDiv.className = 'relative group';
        previewDiv.innerHTML = `
          <div class="aspect-square rounded-lg overflow-hidden bg-gray-100">
            <img src="${e.target.result}" alt="Preview ${index + 1}" class="w-full h-full object-cover">
          </div>
          <button type="button" 
                  class="absolute top-1 right-1 bg-red-500 text-white rounded-full p-1 opacity-0 group-hover:opacity-100 transition-opacity"
                  onclick="removeImage(${index})">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
          ${index === 0 ? '<span class="absolute bottom-1 left-1 bg-blue-500 text-white text-xs px-2 py-1 rounded">대표</span>' : ''}
        `;
        
        previewContainer.appendChild(previewDiv);
      };
      
      reader.readAsDataURL(file);
    });
  }
  
  // 이미지 제거 함수를 전역으로 설정
  window.removeImage = function(index) {
    selectedFiles.splice(index, 1);
    
    // 파일 입력 업데이트
    const dt = new DataTransfer();
    selectedFiles.forEach(file => dt.items.add(file));
    imageInput.files = dt.files;
    
    displayPreviews();
  };
  
  // 드래그 앤 드롭 지원
  const dropZone = document.querySelector('.border-dashed');
  
  if (dropZone) {
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
      dropZone.addEventListener(eventName, preventDefaults, false);
    });
    
    function preventDefaults(e) {
      e.preventDefault();
      e.stopPropagation();
    }
    
    ['dragenter', 'dragover'].forEach(eventName => {
      dropZone.addEventListener(eventName, highlight, false);
    });
    
    ['dragleave', 'drop'].forEach(eventName => {
      dropZone.addEventListener(eventName, unhighlight, false);
    });
    
    function highlight(e) {
      dropZone.classList.add('border-blue-400', 'bg-blue-50');
    }
    
    function unhighlight(e) {
      dropZone.classList.remove('border-blue-400', 'bg-blue-50');
    }
    
    dropZone.addEventListener('drop', handleDrop, false);
    
    function handleDrop(e) {
      const files = Array.from(e.dataTransfer.files);
      
      // 파일 입력에 추가
      const dt = new DataTransfer();
      files.forEach(file => dt.items.add(file));
      imageInput.files = dt.files;
      
      // change 이벤트 트리거
      const event = new Event('change', { bubbles: true });
      imageInput.dispatchEvent(event);
    }
  }
});