import consumer from "./consumer"

// Request browser notification permission when user subscribes
function requestNotificationPermission() {
  if ("Notification" in window && Notification.permission === "default") {
    Notification.requestPermission();
  }
}

// Play notification sound
function playNotificationSound() {
  const audio = new Audio('/notification-sound.mp3');
  audio.volume = 0.5;
  audio.play().catch(e => console.log('Could not play notification sound:', e));
}

// Show browser notification
function showBrowserNotification(title, body, url) {
  if ("Notification" in window && Notification.permission === "granted") {
    const notification = new Notification(title, {
      body: body,
      icon: '/icon.png',
      badge: '/icon.png',
      tag: 'bdr-notification',
      requireInteraction: false
    });

    notification.onclick = function(event) {
      event.preventDefault();
      window.focus();
      if (url) {
        window.location.href = url;
      }
      notification.close();
    };

    // Auto close after 5 seconds
    setTimeout(() => notification.close(), 5000);
  }
}

// Update notification badge count
function updateNotificationBadge(count) {
  // Desktop badge
  const badge = document.getElementById('notification-badge');
  const badgeCount = document.getElementById('notification-badge-count');
  
  if (badge && badgeCount) {
    if (count > 0) {
      badge.classList.remove('hidden');
      badgeCount.textContent = count > 99 ? '99+' : count;
    } else {
      badge.classList.add('hidden');
    }
  }
  
  // Mobile badge
  const mobileBadge = document.getElementById('mobile-notification-badge');
  const mobileBadgeCount = document.getElementById('mobile-notification-badge-count');
  
  if (mobileBadge && mobileBadgeCount) {
    if (count > 0) {
      mobileBadge.classList.remove('hidden');
      mobileBadgeCount.textContent = count > 99 ? '99+' : count;
    } else {
      mobileBadge.classList.add('hidden');
    }
  }
}

// Add notification to dropdown
function addNotificationToDropdown(notification) {
  const notificationsList = document.getElementById('notifications-list');
  if (!notificationsList) return;

  const notificationHtml = `
    <div class="notification-item px-4 py-3 hover:bg-gray-50 cursor-pointer border-b" data-notification-id="${notification.id}">
      <div class="flex items-start space-x-3">
        <span class="text-2xl">${notification.icon}</span>
        <div class="flex-1">
          <p class="text-sm font-semibold text-gray-900">${notification.title}</p>
          <p class="text-sm text-gray-600">${notification.message}</p>
          <p class="text-xs text-gray-400 mt-1">${notification.created_at}</p>
        </div>
      </div>
    </div>
  `;

  // Insert at the beginning of the list
  notificationsList.insertAdjacentHTML('afterbegin', notificationHtml);

  // Add click handler to mark as read and navigate
  const newNotification = notificationsList.firstElementChild;
  newNotification.addEventListener('click', function() {
    // Mark as read
    if (window.notificationChannel) {
      window.notificationChannel.perform('mark_as_read', { notification_id: notification.id });
    }
    
    // Navigate to URL if available
    if (notification.url) {
      window.location.href = notification.url;
    }
  });

  // Remove oldest notification if more than 10
  const notifications = notificationsList.querySelectorAll('.notification-item');
  if (notifications.length > 10) {
    notifications[notifications.length - 1].remove();
  }
}

// Initialize notification channel
document.addEventListener('DOMContentLoaded', function() {
  // Request permission on page load
  requestNotificationPermission();

  // Subscribe to notification channel
  window.notificationChannel = consumer.subscriptions.create("NotificationChannel", {
    connected() {
      console.log("Connected to NotificationChannel");
    },

    disconnected() {
      console.log("Disconnected from NotificationChannel");
    },

    received(data) {
      console.log("Received notification data:", data);

      if (data.type === 'unread_count') {
        // Update badge count
        updateNotificationBadge(data.count);
      } else {
        // New notification received
        updateNotificationBadge(data.count || 1);
        
        // Add to dropdown
        addNotificationToDropdown(data);
        
        // Play sound
        playNotificationSound();
        
        // Show browser notification
        showBrowserNotification(data.title, data.message, data.url);
      }
    }
  });

  // Mark all as read button
  const markAllReadBtn = document.getElementById('mark-all-read-btn');
  if (markAllReadBtn) {
    markAllReadBtn.addEventListener('click', function(e) {
      e.preventDefault();
      if (window.notificationChannel) {
        window.notificationChannel.perform('mark_all_as_read');
        
        // Clear all unread styling
        const notificationItems = document.querySelectorAll('.notification-item');
        notificationItems.forEach(item => {
          item.classList.remove('bg-blue-50');
        });
      }
    });
  }
});