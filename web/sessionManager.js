/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */


// sessionManager.js - Manejo de sesión por cierre de pestaña

// Variable para controlar si la página se está recargando
let isReloading = false;
let heartbeatInterval;

// Función para enviar heartbeat al servidor
function sendHeartbeat() {
    navigator.sendBeacon('/PractSem04/heartbeat', '');
}

// Función para cerrar sesión
function cerrarSesionPorCierre() {
    // Usar sendBeacon para garantizar que la petición se envíe incluso al cerrar la pestaña
    navigator.sendBeacon('/PractSem04/CerrarSesion', '');
}

// Detectar cuando la página se está descargando
window.addEventListener('beforeunload', function(event) {
    // Solo cerrar sesión si no es una recarga
    if (!isReloading) {
        cerrarSesionPorCierre();
    }
});

// Detectar cuando la página se está recargando
window.addEventListener('beforeunload', function(event) {
    // Marcar como recarga si el usuario presiona F5 o Ctrl+R
    if (event.ctrlKey || event.key === 'F5') {
        isReloading = true;
    }
});

// Detectar navegación interna (enlaces dentro de la aplicación)
document.addEventListener('click', function(event) {
    const link = event.target.closest('a');
    if (link && link.href && link.href.includes(window.location.origin)) {
        isReloading = true;
    }
});

// Detectar envío de formularios
document.addEventListener('submit', function(event) {
    isReloading = true;
});

// Alternativa más robusta: usar Page Visibility API
document.addEventListener('visibilitychange', function() {
    if (document.visibilityState === 'hidden') {
        // La pestaña se está ocultando
        setTimeout(function() {
            if (document.visibilityState === 'hidden') {
                // Si después de 2 segundos sigue oculta, cerrar sesión
                cerrarSesionPorCierre();
            }
        }, 2000);
    }
});

// Inicializar heartbeat cada 30 segundos para mantener la sesión activa
// durante el uso normal
heartbeatInterval = setInterval(sendHeartbeat, 30000);

// Limpiar interval al descargar la página
window.addEventListener('unload', function() {
    clearInterval(heartbeatInterval);
});