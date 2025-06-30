<%-- 
    Document   : modificar_producto
    Created on : 7 may. 2025, 20:12:57
    Author     : Matiasjobeth
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
    <head>
        <script src="sessionTimeout.js"></script>
        
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Modificar Producto</title>
        <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="css/modificar.css"/>
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
            <h1>Modificar producto</h1>
             <a href="index.jsp" class="back-button">Volver al menú principal</a>
        </div> 
        
        <!-- Mostrar mensajes de error o éxito -->
        <c:if test="${not empty error}">
            <div style="color: red; margin: 10px 0;">${error}</div>
        </c:if>
        <c:if test="${not empty mensaje}">
            <div style="color: green; margin: 10px 0;">${mensaje}</div>
        </c:if>
        
        <form action="ControlerProducto" method="post">   
            <table border="1">
                <c:forEach var="campo" items="${Lista}">
                    <tr>
                        <td>Id Producto</td>
                        <td>
                            ${campo.id}
                            <input type="hidden" name="Id" value="${campo.id}">
                        </td>
                    </tr>
                    <tr>
                        <td>Descripción</td>
                        <td><input type="text" name="descripcion" value="${campo.descripcion}" required></td>
                    </tr>
                    <tr>
                        <td>Costo</td>
                        <td><input type="number" step="0.01" name="costo" value="${campo.costo}" required></td>
                    </tr>     
                    <tr>
                        <td>Precio</td>
                        <td><input type="number" step="0.01" name="precio" value="${campo.precio}" required></td>
                    </tr>        
                    <tr>
                        <td>Cantidad</td>
                        <td><input type="number" name="cantidad" value="${campo.cantidad}" required></td>
                    </tr>
                </c:forEach>                    
            </table>
            <br>
            <input type="submit" name="modificar" value="Grabar"> 
            <a href="ControlerProducto?Op=Listar">Cancelar</a>
        </form>
        
        <!-- Debug: Mostrar información de la lista (puedes comentar esto después) -->
        <c:if test="${empty Lista}">
            <div style="color: red; margin-top: 20px;">
                <strong>ERROR:</strong> No se encontraron datos del producto para modificar.
                <br><a href="ControlerProducto?Op=Listar">Volver a la lista de productos</a>
            </div>
        </c:if>
        
    </body>
</html>