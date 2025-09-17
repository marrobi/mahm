// Accessibility Settings JavaScript - NHS compliant implementation
// This script applies accessibility settings based on user preferences

(function() {
    'use strict';

    // Apply accessibility settings when page loads
    document.addEventListener('DOMContentLoaded', function() {
        applyAccessibilitySettings();
        initializeKeyboardNavigation();
        respectSystemPreferences();
    });

    function applyAccessibilitySettings() {
        // Get settings from data attributes (these would be set by the server)
        const body = document.body;
        const settings = getSettingsFromPage();

        // Apply text size
        if (settings.textSize === 'large') {
            body.classList.add('text-size-large');
        } else if (settings.textSize === 'extra-large') {
            body.classList.add('text-size-extra-large');
        }

        // Apply bold text
        if (settings.boldText === 'enabled') {
            body.classList.add('bold-text-enabled');
        }

        // Apply enhanced button labels
        if (settings.buttonLabels === 'enabled') {
            body.classList.add('button-labels-enabled');
            enhanceButtonLabels();
        }

        // Apply reduce motion
        if (settings.reduceMotion === 'enabled') {
            body.classList.add('reduce-motion-enabled');
        }

        // Apply easy read format
        if (settings.communicationSupport && settings.communicationSupport.includes('easy-read')) {
            body.classList.add('easy-read-enabled');
        }

        // Apply BSL interpretation
        if (settings.communicationSupport && settings.communicationSupport.includes('sign-language')) {
            body.classList.add('bsl-interpretation-enabled');
        }

        // Apply language setting
        if (settings.language && settings.language !== 'en') {
            body.setAttribute('lang', settings.language);
            body.setAttribute('dir', isRTLLanguage(settings.language) ? 'rtl' : 'ltr');
        }
    }

    function getSettingsFromPage() {
        // In a real implementation, these would come from server-side data
        // For now, we'll simulate getting them from localStorage
        return {
            textSize: localStorage.getItem('mybp-text-size') || 'standard',
            boldText: localStorage.getItem('mybp-bold-text') || '',
            buttonLabels: localStorage.getItem('mybp-button-labels') || '',
            reduceMotion: localStorage.getItem('mybp-reduce-motion') || '',
            language: localStorage.getItem('mybp-language') || 'en',
            communicationSupport: JSON.parse(localStorage.getItem('mybp-communication-support') || '[]')
        };
    }

    function enhanceButtonLabels() {
        // Add better ARIA labels to buttons
        const buttons = document.querySelectorAll('.nhsuk-button');
        buttons.forEach(function(button) {
            if (!button.getAttribute('aria-label')) {
                const text = button.textContent.trim();
                if (text) {
                    button.setAttribute('aria-label', text + ' button');
                }
            }
        });

        // Enhance links with context
        const links = document.querySelectorAll('.nhsuk-link');
        links.forEach(function(link) {
            if (!link.getAttribute('aria-label') && link.getAttribute('href')) {
                const text = link.textContent.trim();
                const context = link.closest('.nhsuk-card, .nhsuk-summary-list__row');
                if (context && text) {
                    const contextText = context.querySelector('.nhsuk-card__heading, .nhsuk-summary-list__key');
                    if (contextText) {
                        link.setAttribute('aria-label', text + ' for ' + contextText.textContent.trim());
                    }
                }
            }
        });
    }

    function initializeKeyboardNavigation() {
        // Ensure proper tab order and focus management
        const interactiveElements = document.querySelectorAll('a, button, input, select, textarea, [tabindex]');
        
        interactiveElements.forEach(function(element, index) {
            // Add skip link functionality
            element.addEventListener('keydown', function(e) {
                // Allow Escape to move focus back to main content
                if (e.key === 'Escape' && element.closest('.nhsuk-notification-banner, .nhsuk-details')) {
                    const mainContent = document.querySelector('main, #main-content, .nhsuk-main-wrapper');
                    if (mainContent) {
                        mainContent.focus();
                    }
                }
            });
        });

        // Add focus indicators for custom components
        const customInteractive = document.querySelectorAll('.nhsuk-card[href], .voice-readable');
        customInteractive.forEach(function(element) {
            element.setAttribute('tabindex', '0');
            element.addEventListener('focus', function() {
                this.style.outline = '3px solid #ffb81c';
                this.style.outlineOffset = '0';
            });
            element.addEventListener('blur', function() {
                this.style.outline = '';
                this.style.outlineOffset = '';
            });
        });
    }

    function respectSystemPreferences() {
        // Respect prefers-reduced-motion
        if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
            document.body.classList.add('reduce-motion-enabled');
        }

        // Respect prefers-contrast
        if (window.matchMedia('(prefers-contrast: high)').matches) {
            document.body.classList.add('high-contrast-system');
        }

        // Listen for changes in system preferences
        window.matchMedia('(prefers-reduced-motion: reduce)').addEventListener('change', function(e) {
            if (e.matches) {
                document.body.classList.add('reduce-motion-enabled');
            } else {
                // Only remove if not explicitly set by user
                const userSetting = localStorage.getItem('mybp-reduce-motion');
                if (!userSetting) {
                    document.body.classList.remove('reduce-motion-enabled');
                }
            }
        });
    }

    function isRTLLanguage(language) {
        const rtlLanguages = ['ar', 'he', 'fa', 'ur'];
        return rtlLanguages.includes(language);
    }

    // Save settings to localStorage when form is submitted
    document.addEventListener('submit', function(e) {
        if (e.target.id === 'accessibility-settings-form') {
            const formData = new FormData(e.target);
            
            // Save to localStorage for immediate application
            localStorage.setItem('mybp-text-size', formData.get('text-size') || 'standard');
            localStorage.setItem('mybp-bold-text', formData.get('bold-text') || '');
            localStorage.setItem('mybp-button-labels', formData.get('button-labels') || '');
            localStorage.setItem('mybp-reduce-motion', formData.get('reduce-motion') || '');
            localStorage.setItem('mybp-language', formData.get('language') || 'en');
            
            // Handle multiple values for communication support
            const communicationSupport = formData.getAll('communication-support');
            localStorage.setItem('mybp-communication-support', JSON.stringify(communicationSupport));
        }
    });

    // Apply settings from localStorage on every page load
    window.addEventListener('load', function() {
        // Re-apply settings after any dynamic content loads
        setTimeout(function() {
            applyAccessibilitySettings();
        }, 100);
    });

    // Announce important changes to screen readers
    function announceToScreenReader(message) {
        const announcement = document.createElement('div');
        announcement.setAttribute('aria-live', 'polite');
        announcement.setAttribute('aria-atomic', 'true');
        announcement.className = 'nhsuk-u-visually-hidden';
        announcement.textContent = message;
        
        document.body.appendChild(announcement);
        
        // Remove after announcement
        setTimeout(function() {
            document.body.removeChild(announcement);
        }, 1000);
    }

    // Export function for use in other scripts
    window.MyBPAccessibility = {
        applySettings: applyAccessibilitySettings,
        announce: announceToScreenReader
    };

})();