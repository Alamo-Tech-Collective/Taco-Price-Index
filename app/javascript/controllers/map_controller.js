import { Controller } from "@hotwired/stimulus"

// Simple debug logger - disabled for production
const debug = (...args) => {
  // Console logging disabled for cleaner output
  // Uncomment for debugging:
  // console.log('[MapController]', ...args);
};

// Global state
window.mapDebug = debug;

export default class extends Controller {
  static values = {
    apiKey: String,
    markers: { type: String, default: '[]' },
    center: { type: String, default: '{"lat":29.4430149,"lng":-98.5250144}' },
    zoom: { type: Number, default: 15 }
  }

  connect() {
    debug('Map controller connected');
    
    // Create map container - simplified without debug panel
    this.element.innerHTML = `
      <div style="height: 100%; width: 100%; position: relative;">
        <div id="map" style="height: 100%; width: 100%;"></div>
      </div>
    `;
    
    // Debug panel removed for cleaner UI
    
    this.mapElement = this.element.querySelector('#map');
    this.debugOutput = this.element.querySelector('#map-debug-output');
    
    // Parse markers and center
    this.markersData = [];
    this.mapCenter = { lat: 29.4430149, lng: -98.5250144 };
    
    try {
      this.markersData = JSON.parse(this.markersValue);
      debug('Parsed markers:', this.markersData);
    } catch (e) {
      debug('Error parsing markers:', e);
    }
    
    try {
      this.mapCenter = JSON.parse(this.centerValue);
      debug('Parsed center:', this.mapCenter);
    } catch (e) {
      debug('Error parsing center:', e);
    }
    
    // Load Google Maps API
    debug('Loading Google Maps API...');
    if (typeof loadGoogleMapsAPI === 'function') {
      loadGoogleMapsAPI(() => {
        debug('Google Maps API loaded, initializing map...');
        this.initMap();
      });
    } else {
      this.showError('Failed to load Google Maps API: loadGoogleMapsAPI function not found');
    }
  }
  
  initMap() {
    try {
      debug('=== INITIALIZING MAP ===');
      
      if (!this.mapElement) {
        throw new Error('Map container element not found');
      }
      
      if (!window.google?.maps) {
        throw new Error('Google Maps API not loaded');
      }
      
      // Create map with options
      const mapOptions = {
        center: this.mapCenter,
        zoom: this.zoomValue,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        streetViewControl: false,
        mapTypeControl: false,
        fullscreenControl: true,
        zoomControl: true,
        zoomControlOptions: {
          position: google.maps.ControlPosition.RIGHT_TOP
        },
        styles: [
          {
            featureType: 'poi',
            elementType: 'labels',
            stylers: [{ visibility: 'off' }]
          }
        ]
      };
      
      debug('Creating map with options:', JSON.stringify(mapOptions, null, 2));
      this.map = new google.maps.Map(this.mapElement, mapOptions);
      
      // Add map load event listener
      google.maps.event.addListenerOnce(this.map, 'tilesloaded', () => {
        debug('Map tiles loaded');
        // Dispatch custom event when map is ready
        document.dispatchEvent(new Event('map:ready'));
      });
      
      debug('Map instance created');
      
      // Add markers
      if (this.markersData && this.markersData.length > 0) {
        this.addMarkers(this.markersData);
      } else {
        debug('No markers provided, adding test marker');
        this.addTestMarker(this.mapCenter.lat, this.mapCenter.lng, 'Test Location');
      }
      
    } catch (error) {
      console.error('Error initializing map:', error);
      this.showError(`Map initialization failed: ${error.message}`);
    }
  }
  
  addTestMarker(lat, lng, title) {
    if (!this.map) return null;
    
    try {
      debug(`Adding test marker at ${lat}, ${lng}`);
      
      const marker = new google.maps.Marker({
        position: { lat, lng },
        map: this.map,
        title: title || 'Test Marker',
        animation: google.maps.Animation.DROP,
        icon: {
          url: 'https://maps.google.com/mapfiles/ms/icons/red-dot.png',
          scaledSize: new google.maps.Size(32, 32)
        }
      });
      
      const infoWindow = new google.maps.InfoWindow({
        content: `
          <div style="padding: 8px; min-width: 150px;">
            <div style="font-weight: bold; margin-bottom: 5px;">${title || 'Test Marker'}</div>
            <div style="color: #666; font-size: 12px;">${lat.toFixed(6)}, ${lng.toFixed(6)}</div>
          </div>
        `
      });
      
      // Open info window by default for test marker
      infoWindow.open(this.map, marker);
      
      // Also open on click
      marker.addListener('click', () => {
        infoWindow.open(this.map, marker);
      });
      
      debug('Test marker added successfully');
      return marker;
      
    } catch (error) {
      console.error('Error adding test marker:', error);
      return null;
    }
  }
  
  addMarkers(markersData) {
    if (!this.map || !Array.isArray(markersData)) return;
    
    debug(`Adding ${markersData.length} markers`);
    let markersAdded = 0;
    
    try {
      markersData.forEach((markerData, index) => {
        try {
          const position = {
            lat: parseFloat(markerData.lat),
            lng: parseFloat(markerData.lng)
          };
          
          if (isNaN(position.lat) || isNaN(position.lng)) {
            debug(`Skipping invalid marker at index ${index}: invalid coordinates`);
            return;
          }
          
          debug(`Creating marker at ${position.lat}, ${position.lng}`);
          
          const marker = new google.maps.Marker({
            position,
            map: this.map,
            title: markerData.name || 'Location',
            animation: google.maps.Animation.DROP,
            icon: {
              url: 'https://maps.google.com/mapfiles/ms/icons/blue-dot.png',
              scaledSize: new google.maps.Size(32, 32)
            }
          });
          
          if (markerData.name || markerData.address) {
            const content = `
              <div style="min-width: 200px; padding: 10px;">
                ${markerData.name ? `<div style="font-weight: bold; margin-bottom: 5px; font-size: 14px;">${markerData.name}</div>` : ''}
                ${markerData.address ? `<div style="color: #666; margin-bottom: 5px; font-size: 12px;">${markerData.address}</div>` : ''}
                ${markerData.rating ? `
                  <div style="font-size: 12px; color: #e67e22; margin-bottom: 5px;">
                    ${'★'.repeat(Math.round(markerData.rating))}${'☆'.repeat(5 - Math.round(markerData.rating))} (${markerData.rating}/5)
                  </div>` : ''}
                ${markerData.url ? `
                  <div style="margin-top: 8px;">
                    <a href="${markerData.url}" style="color: #1a73e8; text-decoration: none; font-size: 12px;">View Details →</a>
                  </div>` : ''}
              </div>
            `;
            
            const infoWindow = new google.maps.InfoWindow({ content });
            
            // Open first marker by default
            if (markersAdded === 0) {
              setTimeout(() => {
                infoWindow.open(this.map, marker);
              }, 500);
            }
            
            // Add click listener
            marker.addListener('click', () => {
              infoWindow.open(this.map, marker);
            });
          }
          
          markersAdded++;
          
        } catch (error) {
          console.error(`Error creating marker at index ${index}:`, error);
        }
      });
      
      debug(`Successfully added ${markersAdded} of ${markersData.length} markers`);
      
      // Fit bounds to show all markers
      if (markersAdded > 0) {
        this.fitMapToMarkers();
      }
      
    } catch (error) {
      console.error('Error adding markers:', error);
    }
  }
  
  fitMapToMarkers() {
    if (!this.map) {
      debug('Cannot fit map: map not initialized');
      return;
    }
    
    try {
      const bounds = new google.maps.LatLngBounds();
      
      // Find all markers on the map
      // This is a simple approach - in a real app, you'd track markers in an array
      const markers = [];
      
      // Add any existing markers to bounds
      markers.forEach(marker => {
        if (marker && marker.getPosition) {
          bounds.extend(marker.getPosition());
        }
      });
      
      // If we have markers, fit bounds
      if (!bounds.isEmpty()) {
        this.map.fitBounds(bounds);
        
        // Add some padding
        const boundsListener = google.maps.event.addListener(this.map, 'bounds_changed', () => {
          google.maps.event.removeListener(boundsListener);
          this.map.setZoom(Math.min(this.map.getZoom(), 15));
        });
      }
      
    } catch (error) {
      console.error('Error fitting map to markers:', error);
    }
  }
  
  showError(message) {
    console.error('Map Error:', message);
    
    if (this.debugOutput) {
      const errorDiv = document.createElement('div');
      errorDiv.style.color = '#dc3545';
      errorDiv.style.marginTop = '10px';
      errorDiv.style.padding = '10px';
      errorDiv.style.border = '1px solid #f5c6cb';
      errorDiv.style.borderRadius = '4px';
      errorDiv.style.backgroundColor = '#f8d7da';
      errorDiv.textContent = `Error: ${message}`;
      
      this.debugOutput.appendChild(errorDiv);
      this.debugOutput.scrollTop = this.debugOutput.scrollHeight;
    }
    
    if (this.mapElement) {
      this.mapElement.innerHTML = `
        <div style="
          position: absolute;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%);
          background: rgba(255, 255, 255, 0.9);
          border-left: 4px solid #dc3545;
          padding: 20px;
          max-width: 80%;
          box-shadow: 0 2px 10px rgba(0,0,0,0.1);
          z-index: 1000;
        ">
          <h4 style="margin-top: 0; color: #721c24;">⚠️ Map Error</h4>
          <p style="margin-bottom: 0;">${message}</p>
        </div>
      `;
    }
  }
  
  disconnect() {
    // Clean up
    if (this.map) {
      google.maps.event.clearInstanceListeners(this.map);
    }
  }
}
