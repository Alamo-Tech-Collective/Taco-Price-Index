// Initialize Bootstrap components
document.addEventListener('turbo:load', function() {
  // Initialize tooltips
  const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
  tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl)
  })

  // Initialize popovers
  const popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
  popoverTriggerList.map(function (popoverTriggerEl) {
    return new bootstrap.Popover(popoverTriggerEl)
  })

  // Handle restaurant list filtering
  const searchInput = document.getElementById('restaurant-search')
  if (searchInput) {
    searchInput.addEventListener('input', function(e) {
      const searchTerm = e.target.value.toLowerCase()
      const restaurants = document.querySelectorAll('.restaurant-item')
      
      restaurants.forEach(restaurant => {
        const name = restaurant.querySelector('.restaurant-name')?.textContent?.toLowerCase() || ''
        const address = restaurant.querySelector('.restaurant-address')?.textContent?.toLowerCase() || ''
        const visible = name.includes(searchTerm) || address.includes(searchTerm)
        restaurant.style.display = visible ? '' : 'none'
      })
    })
  }

  // Handle tab navigation (only for Bootstrap tabs, not navbar links)
  const tabLinks = document.querySelectorAll('.nav-tabs .nav-link, .nav-pills .nav-link')
  tabLinks.forEach(link => {
    link.addEventListener('click', function(e) {
      // Only prevent default if this is a hash link (for tabs)
      const href = this.getAttribute('href')
      if (href && href.startsWith('#')) {
        e.preventDefault()
        const target = document.querySelector(href)
        
        if (target) {
          // Remove active class from all tabs and panels in the same container
          const tabContainer = this.closest('.nav-tabs, .nav-pills')
          const contentContainer = target.closest('.tab-content')
          
          if (tabContainer) {
            tabContainer.querySelectorAll('.nav-link').forEach(link => link.classList.remove('active'))
          }
          if (contentContainer) {
            contentContainer.querySelectorAll('.tab-pane').forEach(panel => panel.classList.remove('active'))
          }
          
          // Add active class to selected tab and panel
          this.classList.add('active')
          target.classList.add('active')
        }
      }
    })
  })



  // Handle review form submission
  const reviewForms = document.querySelectorAll('.review-form')
  reviewForms.forEach(form => {
    form.addEventListener('submit', async function(e) {
      e.preventDefault()
      try {
        const formData = new FormData(this)
        const response = await fetch(this.action, {
          method: 'POST',
          body: formData
        })
        const data = await response.json()
        
        if (data.success) {
          const reviewList = document.getElementById('reviews')
          const newReview = document.createElement('div')
          newReview.className = 'review-item'
          newReview.innerHTML = `
            <div class="review-header">
              <h5>${data.review.author_name}</h5>
              <span class="rating">${data.review.rating}★</span>
            </div>
            <p>${data.review.text}</p>
            <small>${data.review.created_at}</small>
          `
          reviewList.insertBefore(newReview, reviewList.firstChild)
          this.reset()
        }
      } catch (error) {
        console.error('Error submitting review:', error)
      }
    })
  })

  // Handle favorite toggle
  const favoriteToggleButtons = document.querySelectorAll('[data-controller="restaurant"]')
  favoriteToggleButtons.forEach(button => {
    button.addEventListener('click', function(e) {
      e.preventDefault()
      const restaurantId = this.dataset.restaurantRestaurantId
      const favoriteTarget = this.querySelector('[data-restaurant-target="favorite"]')
      const favoriteCountTarget = this.closest('.list-group-item').querySelector(`#favorite-count-${restaurantId}`)
      
      fetch(`/restaurants/${restaurantId}/toggle_favorite`, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      })
      .then(response => response.json())
      .then(data => {
        favoriteTarget.textContent = data.is_favorite ? 'Unfavorite' : 'Favorite'
        favoriteTarget.className = data.is_favorite ? 'btn btn-danger' : 'btn btn-outline-danger'
        favoriteCountTarget.textContent = `${data.favorite_count} Favorites`
      })
    })
  })

  // Handle bulk order form
  const bulkOrderForm = document.getElementById('bulk-order-form')
  if (bulkOrderForm) {
    const quantityInputs = bulkOrderForm.querySelectorAll('.quantity-input')
    const subtotalElement = document.getElementById('subtotal')
    const totalElement = document.getElementById('total')
    
    function updateTotals() {
      let subtotal = 0
      quantityInputs.forEach(input => {
        const price = parseFloat(input.dataset.price)
        const quantity = parseInt(input.value) || 0
        subtotal += price * quantity
      })
      
      subtotalElement.textContent = `$${subtotal.toFixed(2)}`
      totalElement.textContent = `$${(subtotal * 1.0825).toFixed(2)}` // 8.25% tax
    }
    
    quantityInputs.forEach(input => {
      input.addEventListener('change', updateTotals)
    })
    
    // Initial update
    updateTotals()
  }
})
