// Accessibility Settings JavaScript
// This script applies accessibility settings based on user preferences

(function() {
    'use strict';

    // Apply accessibility settings when page loads
    document.addEventListener('DOMContentLoaded', function() {
        applyAccessibilitySettings();
        initializeVoiceReadback();
    });

    function applyAccessibilitySettings() {
        // Get settings from data attributes (these would be set by the server)
        const body = document.body;
        const settings = getSettingsFromPage();

        // Apply large text
        if (settings.largeText === 'enabled') {
            body.classList.add('large-text-enabled');
        }

        // Apply high contrast
        if (settings.highContrast === 'enabled') {
            body.classList.add('high-contrast-enabled');
        }

        // Apply voice readback
        if (settings.voiceReadback === 'enabled') {
            body.classList.add('voice-readback-enabled');
            enableVoiceReadback();
        }

        // Apply EasyRead mode
        if (settings.easyRead === 'enabled') {
            body.classList.add('easy-read-enabled');
        }

        // Apply BSL videos
        if (settings.bslVideos === 'enabled') {
            body.classList.add('bsl-videos-enabled');
        }

        // Apply language setting (this would typically trigger content changes)
        if (settings.language && settings.language !== 'en') {
            body.setAttribute('lang', settings.language);
        }
    }

    function getSettingsFromPage() {
        // In a real implementation, these would come from server-side data
        // For now, we'll simulate getting them from localStorage or meta tags
        return {
            largeText: localStorage.getItem('mybp-large-text') || '',
            highContrast: localStorage.getItem('mybp-high-contrast') || '',
            voiceReadback: localStorage.getItem('mybp-voice-readback') || '',
            easyRead: localStorage.getItem('mybp-easy-read') || '',
            bslVideos: localStorage.getItem('mybp-bsl-videos') || '',
            language: localStorage.getItem('mybp-language') || 'en'
        };
    }

    function enableVoiceReadback() {
        // Make text elements clickable for voice readback
        const readableElements = document.querySelectorAll('p, h1, h2, h3, h4, h5, h6, .nhsuk-lede-text, .nhsuk-card__heading, .nhsuk-card__description');
        
        readableElements.forEach(function(element) {
            element.classList.add('voice-readable');
            element.setAttribute('tabindex', '0');
            element.setAttribute('role', 'button');
            element.setAttribute('aria-label', 'Click to read aloud: ' + element.textContent.trim());
            
            element.addEventListener('click', function() {
                readTextAloud(element.textContent);
            });
            
            element.addEventListener('keydown', function(e) {
                if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault();
                    readTextAloud(element.textContent);
                }
            });
        });
    }

    function initializeVoiceReadback() {
        // Check if browser supports speech synthesis
        if (!('speechSynthesis' in window)) {
            console.warn('Speech synthesis not supported in this browser');
            return;
        }

        // Stop any ongoing speech when page unloads
        window.addEventListener('beforeunload', function() {
            speechSynthesis.cancel();
        });
    }

    function readTextAloud(text) {
        if (!('speechSynthesis' in window)) {
            alert('Voice readback is not supported in your browser.');
            return;
        }

        // Cancel any ongoing speech
        speechSynthesis.cancel();

        // Create speech utterance
        const utterance = new SpeechSynthesisUtterance(text);
        utterance.rate = 0.8; // Slightly slower for clarity
        utterance.pitch = 1;
        utterance.volume = 1;

        // Add visual feedback
        const readingElements = document.querySelectorAll('.reading');
        readingElements.forEach(el => el.classList.remove('reading'));

        // Find the element being read and highlight it
        const readableElements = document.querySelectorAll('.voice-readable');
        readableElements.forEach(function(element) {
            if (element.textContent.trim() === text.trim()) {
                element.classList.add('reading');
                
                utterance.onend = function() {
                    element.classList.remove('reading');
                };
                
                utterance.onerror = function() {
                    element.classList.remove('reading');
                };
            }
        });

        // Speak the text
        speechSynthesis.speak(utterance);
    }

    // Save settings to localStorage when form is submitted
    document.addEventListener('submit', function(e) {
        if (e.target.id === 'accessibility-settings-form') {
            const formData = new FormData(e.target);
            
            // Save to localStorage for immediate application
            localStorage.setItem('mybp-large-text', formData.get('large-text') || '');
            localStorage.setItem('mybp-high-contrast', formData.get('high-contrast') || '');
            localStorage.setItem('mybp-voice-readback', formData.get('voice-readback') || '');
            localStorage.setItem('mybp-easy-read', formData.get('easy-read') || '');
            localStorage.setItem('mybp-bsl-videos', formData.get('bsl-videos') || '');
            localStorage.setItem('mybp-language', formData.get('language') || 'en');
        }
    });

    // Apply settings from localStorage on every page load
    // This simulates server-side session persistence
    window.addEventListener('load', function() {
        const settings = getSettingsFromPage();
        
        // Re-apply settings after any dynamic content loads
        setTimeout(function() {
            applyAccessibilitySettings();
        }, 100);
    });

})();