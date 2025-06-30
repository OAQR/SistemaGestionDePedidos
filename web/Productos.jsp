<%-- 
    Document   : Productos
    Created on : 12/10/2022, 05:11:07 PM
    Author     : javie
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Productos - Sistema de Gestión</title>
        <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700&display=swap" rel="stylesheet">
        <<link rel="stylesheet" href="css/panles.css"/>>
        <!-- Sistema de Inactividad -->
        <script src="sessionTimeout.js"></script>
        <!-- Incluir este script en el <head> de tus páginas JSP que requieren autenticación -->
<script>
// Código JavaScript integrado para manejo de sesión
(function() {
    let isNavigating = false;
    let heartbeatInterval;
    let navigationTimeout;
    
    // Función para cerrar sesión por cierre de pestaña
    function cerrarSesionPorCierre() {
        navigator.sendBeacon('<%=request.getContextPath()%>/CerrarSesion', '');
    }
    
    // Función para enviar heartbeat solo con actividad del usuario
    function sendHeartbeat() {
        // Solo enviar heartbeat si hay actividad real del usuario
        navigator.sendBeacon('<%=request.getContextPath()%>/heartbeat', '');
    }
    
    // Variables para tracking de actividad
    let lastActivity = Date.now();
    let activityTimeout;
    
    // Función para registrar actividad del usuario
    function registerActivity() {
        lastActivity = Date.now();
        // Cancelar cualquier timeout de heartbeat previo
        if (activityTimeout) {
            clearTimeout(activityTimeout);
        }
        // Enviar heartbeat después de 25 segundos de esta actividad
        // (antes de que expire la sesión de 30 segundos)
        activityTimeout = setTimeout(function() {
            // Solo enviar si ha pasado menos de 25 segundos desde la última actividad
            if (Date.now() - lastActivity < 25000) {
                sendHeartbeat();
            }
        }, 25000);
    }
    
    // Detectar actividad del usuario
    document.addEventListener('click', registerActivity);
    document.addEventListener('keypress', registerActivity);
    document.addEventListener('mousemove', registerActivity);
    document.addEventListener('scroll', registerActivity);
    
    // Marcar como navegación interna
    function markAsNavigation() {
        isNavigating = true;
        // Limpiar cualquier timeout previo
        if (navigationTimeout) {
            clearTimeout(navigationTimeout);
        }
        // Resetear después de 5 segundos por si algo sale mal
        navigationTimeout = setTimeout(function() {
            isNavigating = false;
        }, 5000);
    }
    
    // Detectar navegación hacia atrás/adelante
    window.addEventListener('popstate', function(event) {
        markAsNavigation();
    });
    
    // Detectar teclas de navegación
    document.addEventListener('keydown', function(event) {
        // Alt + Flecha izquierda/derecha (navegación)
        if (event.altKey && (event.key === 'ArrowLeft' || event.key === 'ArrowRight')) {
            markAsNavigation();
        }
        // F5 o Ctrl+R (recarga)
        if (event.key === 'F5' || (event.ctrlKey && event.key === 'r')) {
            markAsNavigation();
        }
        // Ctrl+L (barra de direcciones)
        if (event.ctrlKey && event.key === 'l') {
            markAsNavigation();
        }
    });
    
    // Detectar clics en botones del navegador y enlaces
    document.addEventListener('click', function(event) {
        const link = event.target.closest('a');
        const button = event.target.closest('button');
        
        // Si es un enlace interno o botón de formulario
        if (link || button) {
            markAsNavigation();
        }
    });
    
    // Detectar envío de formularios
    document.addEventListener('submit', function(event) {
        markAsNavigation();
    });
    
    // Detectar cuando se enfoca la barra de direcciones
    window.addEventListener('blur', function() {
        markAsNavigation();
    });
    
    // Detectar cierre real de pestaña
    window.addEventListener('beforeunload', function(event) {
        // Solo cerrar sesión si NO es navegación interna
        if (!isNavigating) {
            cerrarSesionPorCierre();
        }
    });
    
    // Page Visibility API como respaldo MÁS SELECTIVO
    let visibilityTimeout;
    document.addEventListener('visibilitychange', function() {
        if (document.visibilityState === 'hidden') {
            // Solo si no estamos navegando
            if (!isNavigating) {
                visibilityTimeout = setTimeout(function() {
                    // Verificar nuevamente si sigue oculta y no navegando
                    if (document.visibilityState === 'hidden' && !isNavigating) {
                        cerrarSesionPorCierre();
                    }
                }, 5000); // Aumentar a 5 segundos
            }
        } else {
            // Si vuelve a ser visible, cancelar el timeout
            if (visibilityTimeout) {
                clearTimeout(visibilityTimeout);
                visibilityTimeout = null;
            }
        }
    });
    
    // NO iniciar heartbeat automático para respetar el timeout por inactividad
    // heartbeatInterval = setInterval(sendHeartbeat, 30000);
    
    // Limpiar al descargar
    window.addEventListener('unload', function() {
        if (navigationTimeout) {
            clearTimeout(navigationTimeout);
        }
        if (visibilityTimeout) {
            clearTimeout(visibilityTimeout);
        }
        if (activityTimeout) {
            clearTimeout(activityTimeout);
        }
    });
    
    // Marcar como navegación al cargar la página (para evitar problemas iniciales)
    window.addEventListener('load', function() {
        markAsNavigation();
        // Resetear después de 2 segundos
        setTimeout(function() {
            isNavigating = false;
        }, 2000);
    });
})();
</script>
    </head>
        <%  
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");  
        if (session.getAttribute("user")==null){
            response.sendRedirect("login.jsp");
        }
    %>
    
    <body>
        <div class="header-box">
            <h1>Menú de productos</h1>
              <a href="index.jsp" class="back-button">Volver al menú principal</a>
        </div>
            <a href="ControlerProducto?Op=Listar" class="menu-item">Listar productos</a>
            <a href="ControlerProducto?Op=Nuevo" class="menu-item">Nuevo producto</a>
            
          
    </body>
</html>