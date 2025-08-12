import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { restaurantId: String, url: String }

  toggle(event) {
    event.preventDefault()
    const button = event.currentTarget
    const url = this.urlValue || `/restaurants/${this.restaurantIdValue}/toggle_favorite`

    fetch(url, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      credentials: 'same-origin'
    })
    .then(response => {
      if (response.redirected) {
        window.location.href = response.url
        return
      }
      if (!response.ok) {
        throw new Error('Network response was not ok')
      }
      return response.json()
    })
    .then(data => {
      if (!data) return
      
      // Remove the card from the favorites page
      const card = button.closest('.col-md-6')
      if (card) {
        card.remove()
        
        // Check if there are no more favorites
        const container = document.querySelector('.row.g-4')
        if (container && container.children.length === 0) {
          // Show the "no favorites" message
          location.reload()
        }
      }
    })
    .catch(error => console.error('Error:', error))
  }
}