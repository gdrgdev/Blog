/**
 * MermaidVisualizer Control Add-in for Business Central
 * Implements Mermaid.js diagram rendering with theme and scaling controls
 * Based on official Mermaid.js v11 API documentation
 * Mermaid.js is loaded from CDN: https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js
 */

var isControlReady = false;
var currentTheme = 'default';
var currentScale = 1.0; // Store current scale to maintain it when changing themes (100%)

// Initialize control with container and status display
function initializeControl() {
    try {
        document.body.innerHTML = '';
        document.body.style.margin = '0';
        document.body.style.padding = '10px';
        document.body.style.fontFamily = 'Segoe UI, Arial, sans-serif';
        document.body.style.backgroundColor = '#ffffff';
        
        var container = document.createElement('div');
        container.id = 'mermaid-container';
        container.style.width = '100%';
        container.style.height = '100%';
        container.style.minHeight = '400px';
        container.style.overflow = 'auto';
        container.style.border = '1px solid #e0e0e0';
        container.style.borderRadius = '4px';
        container.style.backgroundColor = '#fafafa';
        
        // Create content area for diagrams
        var contentDiv = document.createElement('div');
        contentDiv.id = 'mermaid-content';
        contentDiv.style.padding = '20px';
        contentDiv.style.textAlign = 'center';
        contentDiv.innerHTML = `
            <div style="padding: 20px; text-align: center;">
                <h3 style="color: #333; margin-bottom: 10px;">Mermaid Visualizer</h3>
                <p style="color: #666; margin-bottom: 20px;">Ready to display diagrams</p>
                <div id="status-info" style="background: #e3f2fd; padding: 15px; border-radius: 4px; color: #1976d2;">
                    <strong>Status:</strong> Initializing...<br>
                    <strong>Mermaid:</strong> <span id="mermaid-status">Loading...</span><br>
                    <strong>Theme:</strong> ${currentTheme}
                </div>
            </div>
        `;
        
        container.appendChild(contentDiv);
        document.body.appendChild(container);
        
        // Wait for Mermaid to be available, then initialize
        waitForMermaid();
        
    } catch (error) {
        console.error('Error initializing control:', error);
        document.body.innerHTML = `<div style="padding: 20px; color: red;">Error: ${error.message}</div>`;
    }
}

// Wait for Mermaid library to be loaded
function waitForMermaid() {
    if (typeof mermaid !== 'undefined') {
        // Initialize Mermaid following official documentation
        mermaid.initialize({
            startOnLoad: false,  // We'll control rendering manually
            theme: currentTheme,
            securityLevel: 'loose',  // Allow HTML labels and interactions
            fontFamily: 'Segoe UI, Arial, sans-serif',
            // Configuration for more compact diagrams
            flowchart: {
                nodeSpacing: 30,
                rankSpacing: 40,
                curve: 'basis'
            },
            sequence: {
                actorMargin: 30,
                width: 120,
                height: 50
            }
            // No scale setting - will be at 100% by default
        });
        
        // Update status
        var statusElement = document.getElementById('mermaid-status');
        if (statusElement) {
            statusElement.innerHTML = 'Loaded (v11)';
        }
        
        isControlReady = true;
        
        // Notify Business Central that control is ready
        if (typeof Microsoft !== 'undefined' && Microsoft.Dynamics && Microsoft.Dynamics.NAV) {
            Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ControlReady', []);
        }
        
        console.log('Mermaid initialized successfully with official API');
        
    } else {
        // Keep trying every 100ms for up to 10 seconds
        setTimeout(waitForMermaid, 100);
    }
}

// Load and render Mermaid code using official API
function LoadMermaidCode(mermaidCode) {
    try {
        if (!isControlReady) {
            setTimeout(function() { LoadMermaidCode(mermaidCode); }, 200);
            return;
        }
        
        // Save the code for theme changes
        window.lastMermaidCode = mermaidCode;
        
        var contentDiv = document.getElementById('mermaid-content');
        if (!contentDiv) {
            console.error('Content div not found');
            return;
        }
        
        if (!mermaidCode || mermaidCode.trim() === '') {
            contentDiv.innerHTML = '<div style="padding: 20px; color: red;">Error: No Mermaid code provided</div>';
            window.lastMermaidCode = null;
            return;
        }
        
        contentDiv.innerHTML = '<div style="padding: 20px;">Generating diagram...</div>';
        
        if (typeof mermaid === 'undefined') {
            contentDiv.innerHTML = '<div style="padding: 20px; color: red;">Error: Mermaid is not available</div>';
            return;
        }
        
        // Use official Mermaid render API - v11 syntax
        var diagramId = 'diagram-' + Date.now();
        
        // Official API call following documentation
        mermaid.render(diagramId, mermaidCode)
            .then(function(result) {
                // result.svg contains the rendered SVG
                contentDiv.innerHTML = result.svg;
                
                // Style the SVG for better integration and proper sizing
                var svg = contentDiv.querySelector('svg');
                if (svg) {
                    // Control the size to match web portal experience
                    svg.style.maxWidth = '100%';  // Full width for Large (100%) display
                    svg.style.height = 'auto';
                    svg.style.display = 'block';
                    svg.style.margin = '10px auto';
                    svg.style.border = '1px solid #e0e0e0';
                    svg.style.borderRadius = '4px';
                    svg.style.backgroundColor = '#ffffff';
                    
                    // Apply current scaling transformation
                    svg.style.transform = 'scale(' + currentScale + ')';
                    svg.style.transformOrigin = 'center top';
                }
                
                console.log('Mermaid diagram rendered successfully using official API');
                
                // Notify Business Central of success
                if (typeof Microsoft !== 'undefined' && Microsoft.Dynamics && Microsoft.Dynamics.NAV) {
                    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('DiagramRendered', [true, '']);
                }
            })
            .catch(function(error) {
                console.error('Mermaid render error:', error);
                
                contentDiv.innerHTML = `
                    <div style="padding: 20px; color: red;">
                        <h4>Rendering Error</h4>
                        <p><strong>Message:</strong> ${error.message || 'Unknown error'}</p>
                        <details style="margin-top: 10px; text-align: left;">
                            <summary style="cursor: pointer;">View Mermaid code</summary>
                            <pre style="background: #f5f5f5; padding: 10px; white-space: pre-wrap; border-radius: 4px; margin-top: 10px;">${mermaidCode}</pre>
                        </details>
                        <div style="margin-top: 15px; padding: 10px; background: #fff3cd; border-radius: 4px; color: #856404; text-align: left;">
                            <strong>Possible causes:</strong><br>
                            • Incorrect Mermaid syntax<br>
                            • Unsupported diagram type<br>
                            • CDN connection error
                        </div>
                    </div>
                `;
                
                // Notify Business Central of error
                if (typeof Microsoft !== 'undefined' && Microsoft.Dynamics && Microsoft.Dynamics.NAV) {
                    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('DiagramRendered', [false, error.message || 'Unknown error']);
                }
            });
            
    } catch (error) {
        console.error('Error in LoadMermaidCode:', error);
        var contentDiv = document.getElementById('mermaid-content');
        if (contentDiv) {
            contentDiv.innerHTML = `<div style="padding: 20px; color: red;">Error: ${error.message}</div>`;
        }
    }
}

// Set theme using official API
function SetTheme(theme) {
    try {
        currentTheme = theme || 'default';
        
        if (typeof mermaid !== 'undefined' && isControlReady) {
            // Re-initialize with new theme and size configurations
            mermaid.initialize({
                startOnLoad: false,
                theme: currentTheme,
                securityLevel: 'loose',
                fontFamily: 'Segoe UI, Arial, sans-serif',
                // Maintain compact diagram configurations
                flowchart: {
                    nodeSpacing: 30,
                    rankSpacing: 40,
                    curve: 'basis'
                },
                sequence: {
                    actorMargin: 30,
                    width: 120,
                    height: 50
                }
                // Removed hardcoded scale - will be applied via CSS transform instead
            });
            
            console.log('Theme updated to:', currentTheme);
            
            // Update status display
            var statusInfo = document.getElementById('status-info');
            if (statusInfo) {
                statusInfo.innerHTML = `
                    <strong>Status:</strong> Control ready<br>
                    <strong>Mermaid:</strong> Loaded (v11)<br>
                    <strong>Theme:</strong> ${currentTheme}
                `;
            }
            
            // Re-render existing diagram with new theme if there's one
            var existingSvg = document.querySelector('#mermaid-content svg');
            if (existingSvg && window.lastMermaidCode) {
                console.log('Re-rendering diagram with new theme...');
                // Clear existing content first
                var contentDiv = document.getElementById('mermaid-content');
                if (contentDiv) {
                    contentDiv.innerHTML = '<div style="padding: 20px;">Applying theme: ' + currentTheme + '...</div>';
                }
                // Re-render with small delay to ensure theme is applied
                setTimeout(function() {
                    LoadMermaidCode(window.lastMermaidCode);
                }, 100);
            }
        }
    } catch (error) {
        console.error('Error setting theme:', error);
    }
}

// Export diagram using modern browser APIs
function ExportDiagram() {
    try {
        var svg = document.querySelector('#mermaid-content svg');
        if (!svg) {
            alert('No diagram to export');
            return;
        }
        
        // Get SVG content
        var svgData = new XMLSerializer().serializeToString(svg);
        
        // Add XML declaration and proper styling
        var fullSvg = '<?xml version="1.0" encoding="UTF-8"?>\n' + svgData;
        
        var blob = new Blob([fullSvg], { type: 'image/svg+xml;charset=utf-8' });
        var url = URL.createObjectURL(blob);
        
        var link = document.createElement('a');
        link.href = url;
        link.download = 'business-central-mermaid-diagram.svg';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(url);
        
        console.log('Diagram exported successfully');
        
    } catch (error) {
        console.error('Error exporting:', error);
        alert('Export error: ' + error.message);
    }
}

// Set diagram scale dynamically
function SetScale(scalePercentage) {
    try {
        var scale = (scalePercentage || 100) / 100; // Default to 100%
        currentScale = scale; // Store current scale
        
        var svg = document.querySelector('#mermaid-content svg');
        if (svg) {
            svg.style.transform = 'scale(' + scale + ')';
            svg.style.transformOrigin = 'center top';
            
            // Adjust container to prevent overflow
            var container = svg.parentElement;
            if (container) {
                container.style.overflow = 'visible';
                container.style.textAlign = 'center';
            }
            
            console.log('Diagram scale updated to:', scale);
        } else {
            console.log('No diagram found to scale - will apply when diagram loads');
        }
    } catch (error) {
        console.error('Error setting scale:', error);
    }
}

// Initialize when ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeControl);
} else {
    initializeControl();
}
