// ============================================================================
// GDRG Field Magnifier - Business Central Accessibility Extension
// ============================================================================
// Creates a floating magnified view of field content on hover
// No visual magnifying glass - just enlarged text in a styled popup div

// Global state
var magnifierDiv = null;
var targetDocument = null;

// ============================================================================
// STATE MANAGEMENT
// ============================================================================

function GetSharedState() {
    var parentWin = window.parent || window;
    if (!parentWin.GDRGMagnifierState) {
        parentWin.GDRGMagnifierState = {
            enabled: true,
            zoomLevel: 3
        };
    }
    return parentWin.GDRGMagnifierState;
}

function EnableMagnifier() {
    GetSharedState().enabled = true;
}

function DisableMagnifier() {
    GetSharedState().enabled = false;
    HideMagnifier();
}

function SetZoomLevel(level) {
    GetSharedState().zoomLevel = level;
    HideMagnifier();
}

// ============================================================================
// INITIALIZATION
// ============================================================================

function InitMagnifier() {
    try {
        if (window.parent && window.parent.document) {
            targetDocument = window.parent.document;
        } else if (window.top && window.top.document) {
            targetDocument = window.top.document;
        } else {
            targetDocument = document;
        }
    } catch (e) {
        targetDocument = document;
    }
    
    targetDocument.addEventListener('mouseover', function(e) {
        var state = GetSharedState();
        if (!state.enabled) return;
        
        var target = e.target;
        if (IsFieldElement(target)) {
            ShowMagnifier(target);
        }
    }, true);

    targetDocument.addEventListener('mouseout', function(e) {
        var target = e.target;
        if (IsFieldElement(target)) {
            HideMagnifier();
        }
    }, true);

    if (typeof Microsoft !== 'undefined' && Microsoft.Dynamics && Microsoft.Dynamics.NAV) {
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnMagnifierReady', []);
    }
}

// ============================================================================
// MAGNIFICATION LOGIC
// ============================================================================
// Core functionality: Extract field data and display it in a floating div
// with enlarged font size. The "magnifier" is just a styled popup, not a lens.

function ShowMagnifier(field) {
    var value = '';
    var ariaLabel = field.getAttribute('aria-label');
    var parentCell = field.closest('td[role="gridcell"]');
    
    if (field.classList && field.classList.contains('booleancontrol-toggle-switch')) {
        var isOn = !field.classList.contains('toggle-off');
        value = isOn ? 'Yes' : 'No';
    }
    else if (field.classList && field.classList.contains('booleancontrol-read') && field.type === 'checkbox') {
        value = field.checked ? 'Yes' : 'No';
    }
    else if (field.tagName === 'SELECT' && field.selectedIndex >= 0) {
        value = field.options[field.selectedIndex].text;
    }
    else if (parentCell && ariaLabel && ariaLabel.trim() !== '') {
        value = ariaLabel;
        if (value === '(Blank)') {
            value = '(empty)';
        }
    }
    else {
        value = field.value || field.textContent || field.innerText;
        if (!value || value.replace(/[\s\u00A0]+/g, '') === '') {
            value = '(empty)';
        }
    }

    HideMagnifier();

    var label = GetFieldLabel(field);

    magnifierDiv = document.createElement('div');
    magnifierDiv.className = 'gdrg-magnifier';
    magnifierDiv.style.cssText = 'position: fixed; background-color: white; color: #1f1f1f; padding: 16px 20px; border-radius: 0; box-shadow: 0 6.4px 14.4px 0 rgba(0,0,0,0.132), 0 1.2px 3.6px 0 rgba(0,0,0,0.108); z-index: 999999; pointer-events: none; border: 1px solid rgba(0,0,0,0.1); max-width: 600px; word-wrap: break-word; font-family: "Segoe UI", "Segoe WP", Segoe, Tahoma, Helvetica, Arial, sans-serif;';
    
    var baseSize = 14;
    var baseLabelSize = 12;
    var computedStyle = window.getComputedStyle(field);
    if (computedStyle && computedStyle.fontSize) {
        baseSize = parseInt(computedStyle.fontSize) || 14;
    }
    var state = GetSharedState();
    var finalValueSize = Math.floor(baseSize * state.zoomLevel);
    var finalLabelSize = Math.floor(baseLabelSize * (state.zoomLevel / 2));
    
    if (label) {
        var labelSpan = document.createElement('div');
        labelSpan.className = 'gdrg-magnifier-label';
        labelSpan.style.cssText = 'opacity: 0.7; font-weight: 600; margin-bottom: 6px; color: #008489; letter-spacing: 0.5px;';
        labelSpan.style.fontSize = finalLabelSize + 'px';
        labelSpan.textContent = label;
        magnifierDiv.appendChild(labelSpan);
    }
    
    var valueSpan = document.createElement('div');
    valueSpan.className = 'gdrg-magnifier-value';
    valueSpan.style.cssText = 'font-weight: 400; color: #1f1f1f; line-height: 1.4;';
    valueSpan.style.fontSize = finalValueSize + 'px';
    valueSpan.textContent = value;
    magnifierDiv.appendChild(valueSpan);

    var targetBody = window.parent ? window.parent.document.body : document.body;
    targetBody.appendChild(magnifierDiv);
    
    var rect = field.getBoundingClientRect();
    var left = rect.left;
    var top = rect.bottom + 5;
    
    var magnifierRect = magnifierDiv.getBoundingClientRect();
    if (left + magnifierRect.width > window.innerWidth) {
        left = window.innerWidth - magnifierRect.width - 10;
    }
    if (top + magnifierRect.height > window.innerHeight) {
        top = rect.top - magnifierRect.height - 5;
    }
    
    magnifierDiv.style.left = left + 'px';
    magnifierDiv.style.top = top + 'px';
}

function HideMagnifier() {
    if (magnifierDiv && magnifierDiv.parentNode) {
        magnifierDiv.parentNode.removeChild(magnifierDiv);
        magnifierDiv = null;
    }
    
    var parentDoc = window.parent ? window.parent.document : document;
    var existingMagnifiers = parentDoc.querySelectorAll('.gdrg-magnifier');
    for (var i = 0; i < existingMagnifiers.length; i++) {
        existingMagnifiers[i].parentNode.removeChild(existingMagnifiers[i]);
    }
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

// Detects if an element is a Business Central input field
function IsFieldElement(element) {
    if (!element || !element.tagName) return false;
    
    if (element.tagName === 'IMG' || element.tagName === 'BUTTON') {
        return false;
    }
    
    var classList = element.className || '';
    
    if (element.tagName === 'A' && !classList.includes('stringcontrol-read') && !classList.includes('numericcontrol-read')) {
        return false;
    }
    
    return element.tagName === 'INPUT' || 
           element.tagName === 'TEXTAREA' || 
           element.tagName === 'SELECT' ||
           classList.includes('stringcontrol-edit') ||
           classList.includes('stringcontrol-read') ||
           classList.includes('numericcontrol-edit') ||
           classList.includes('numericcontrol-read') ||
           classList.includes('enumerationcontrol-edit') ||
           classList.includes('booleancontrol-toggle-switch') ||
           classList.includes('booleancontrol-read') ||
           classList.includes('ms-nav-stack-number') ||
           classList.includes('ms-TextField-field') ||
           classList.includes('fui-Input') ||
           element.getAttribute('role') === 'textbox' ||
           element.getAttribute('role') === 'combobox';
}

// Extracts the field label from various BC DOM structures
function GetFieldLabel(field) {
    var labelledBy = field.getAttribute('aria-labelledby');
    if (labelledBy) {
        var labelIds = labelledBy.split(' ');
        for (var i = 0; i < labelIds.length; i++) {
            var labelId = labelIds[i].trim();
            if (labelId && labelId !== field.id) {
                var labelElement = (field.ownerDocument || document).getElementById(labelId);
                if (labelElement && labelElement.textContent.trim()) {
                    return labelElement.textContent.trim();
                }
            }
        }
    }
    
    var ariaLabel = field.getAttribute('aria-label') || field.getAttribute('title');
    if (ariaLabel) return ariaLabel;
    
    var labelElement = field.closest('div[class*="field"]');
    if (labelElement) {
        var labelNode = labelElement.querySelector('label, [class*="label"]');
        if (labelNode) return labelNode.textContent.trim();
    }
    
    var id = field.id;
    if (id) {
        var labelFor = document.querySelector('label[for="' + id + '"]');
        if (labelFor) return labelFor.textContent.trim();
    }
    
    if (field.classList && field.classList.contains('ms-nav-stack-number')) {
        var container = field.closest('.ms-nav-stack-image-number-container');
        if (container && container.parentElement) {
            var captionContainer = container.parentElement.querySelector('.ms-nav-stack-caption-container .ms-nav-stack-caption');
            if (captionContainer && captionContainer.textContent) {
                return captionContainer.textContent.trim();
            }
        }
    }
    
    return null;
}

// ============================================================================
// BOOTSTRAP
// ============================================================================

if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', InitMagnifier);
} else {
    InitMagnifier();
}
