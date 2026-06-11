document.body.style.margin = '0';
document.body.style.padding = '0';
document.body.style.overflow = 'hidden';
document.body.style.backgroundColor = '#ffffff';
document.body.style.colorScheme = 'light';
document.body.innerHTML = '';

var host = document.createElement('div');
host.style.width = '100%';
host.style.height = '420px';
host.style.boxSizing = 'border-box';
host.style.overflow = 'hidden';
host.style.backgroundColor = '#ffffff';
host.style.colorScheme = 'light';

var iframe = document.createElement('iframe');
iframe.src = 'https://sportscore.com/embed/fixtures/football/competition/fifa-world-cup/';
iframe.setAttribute('width', '320');
iframe.setAttribute('height', '420');
iframe.title = 'Sportscore FIFA World Cup Widget';
iframe.style.width = '100%';
iframe.style.height = '100%';
iframe.style.border = '1px solid #e5e7ef';
iframe.style.borderRadius = '8px';
iframe.style.overflow = 'hidden';
iframe.style.display = 'block';
iframe.style.backgroundColor = '#ffffff';
iframe.style.colorScheme = 'light';
iframe.loading = 'lazy';
iframe.referrerPolicy = 'no-referrer-when-downgrade';

iframe.onerror = function () {
	host.innerHTML = '<div style="padding:16px;font-family:Segoe UI,sans-serif;color:#a4262c;">No se pudo cargar el widget de Sportscore dentro del iframe.</div>';
};

host.appendChild(iframe);
document.body.appendChild(host);