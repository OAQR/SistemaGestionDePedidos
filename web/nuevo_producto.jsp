<%-- 
    Document   : nuevo_producto
    Created on : 7 may. 2025, 20:12:43
    Author     : Matiasjobeth
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
    <head>
        <script src="sessionTimeout.js"></script>
        
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Nuevo Producto</title>
         <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="css/nuevo.css"/>
        <!-- Incluir este script en el <head> de tus páginas JSP que requieren autenticación -->
<script>
(function() {
    let isNavigating = false;
    let heartbeatInterval;
    let navigationTimeout;
    
    function cerrarSesionPorCierre() {
        navigator.sendBeacon('<%=request.getContextPath()%>/CerrarSesion', '');
    }
    
    function sendHeartbeat() {
        navigator.sendBeacon('<%=request.getContextPath()%>/heartbeat', '');
    }
    
    let lastActivity = Date.now();
    let activityTimeout;
    
    function registerActivity() {
        lastActivity = Date.now();
        if (activityTimeout) {
            clearTimeout(activityTimeout);
        }
        activityTimeout = setTimeout(function() {
            if (Date.now() - lastActivity < 25000) {
                sendHeartbeat();
            }
        }, 25000);
    }
    
    document.addEventListener('click', registerActivity);
    document.addEventListener('keypress', registerActivity);
    document.addEventListener('mousemove', registerActivity);
    document.addEventListener('scroll', registerActivity);
    
    function markAsNavigation() {
        isNavigating = true;
        if (navigationTimeout) {
            clearTimeout(navigationTimeout);
        }
        navigationTimeout = setTimeout(function() {
            isNavigating = false;
        }, 5000);
    }
    
    window.addEventListener('popstate', function(event) {
        markAsNavigation();
    });
    
    document.addEventListener('keydown', function(event) {
        if (event.altKey && (event.key === 'ArrowLeft' || event.key === 'ArrowRight')) {
            markAsNavigation();
        }
        if (event.key === 'F5' || (event.ctrlKey && event.key === 'r')) {
            markAsNavigation();
        }
        if (event.ctrlKey && event.key === 'l') {
            markAsNavigation();
        }
    });
    
    document.addEventListener('click', function(event) {
        const link = event.target.closest('a');
        const button = event.target.closest('button');
        
        if (link || button) {
            markAsNavigation();
        }
    });
    
    document.addEventListener('submit', function(event) {
        markAsNavigation();
    });
    
    window.addEventListener('blur', function() {
        markAsNavigation();
    });
    

    window.addEventListener('beforeunload', function(event) {
        if (!isNavigating) {
            cerrarSesionPorCierre();
        }
    });
    
    let visibilityTimeout;
    document.addEventListener('visibilitychange', function() {
        if (document.visibilityState === 'hidden') {
            if (!isNavigating) {
                visibilityTimeout = setTimeout(function() {
                    if (document.visibilityState === 'hidden' && !isNavigating) {
                        cerrarSesionPorCierre();
                    }
                }, 5000); 
            }
        } else {
            if (visibilityTimeout) {
                clearTimeout(visibilityTimeout);
                visibilityTimeout = null;
            }
        }
    });
    
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
    
    window.addEventListener('load', function() {
        markAsNavigation();
        setTimeout(function() {
            isNavigating = false;
        }, 2000);
    });
})();
</script>
    <%  
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");  
        if (session.getAttribute("user")==null){
            response.sendRedirect("login.jsp");
        }
    %>
    
    </head>
    <body>
       <div class="header-box">
            <h1>Insertar producto</h1>
             <a href="index.jsp" class="back-button">Volver al menú principal</a>
        </div> 
        <div class="main-content">
        <form action="ControlerProducto" method="post">   
            <table border="1">
                    <tr>
                        <td>Id Producto</td>
                        <td><input type="hidden" name="Id"></td>
                    </tr>
                    <tr>
                        <td>Descripción</td>
                        <td><input type="text" name="descripcion"></td>
                    </tr>
                    <tr>
                        <td>Costo</td>
                        <td><input type="text" name="costo"></td>
                    </tr>     
                    <tr>
                        <td>Precio</td>
                        <td><input type="text" name="precio"></td>
                    </tr>        
                    <tr>
                        <td>Cantidad</td>
                        <td><input type="text" name="cantidad"></td>
                    </tr>                 
            </table>
             <button type="submit" name="modificar"class="grabar-button"> Grabar</button>
        </form>
        </div>
        
    </body>
</html>
