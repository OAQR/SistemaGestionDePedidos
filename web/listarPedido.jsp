<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%-- 
    Document   : listar
    Created on : 17/09/2022, 10:54:58 AM
    Author     : javie
--%>
<%@page import="java.util.List"%>
<%@page import="Entidades.pedido"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    List<pedido> Lista = (List<pedido>) request.getAttribute("Lista");
%>
<!DOCTYPE html>
<html>
<head>
    <script src="sessionTimeout.js"></script>
    
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Listado de Pedidos</title>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700&display=swap" rel="stylesheet">
    <<link rel="stylesheet" href="css/lista.css"/>>
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
    <div class="container">
         <div class="header-box">
            <h1>Listado de clientes</h1>
             <a href="index.jsp" class="back-button">Volver al menú principal</a>
        </div> 

        <div class="menu-buttons">
            <a href="Pedidos.jsp" class="menu-btn">Menú Principal</a>
            <a href="ControlerPedido?Op=Nuevo" class="menu-btn">Nuevo Pedido</a>
        </div>

        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Cliente</th>
                    <th>Apellidos</th>
                    <th>Nombres</th>
                    <th>Fecha</th>
                    <th>Estado</th>
                    <th>Total</th>
                    <th>Acciones</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="campo" items="${Lista}">
                <tr>
                    <td><strong>${campo.getId_Pedido()}</strong></td>
                    <td>${campo.getId_Cliente()}</td>
                    <td>${campo.getApellidos()}</td>
                    <td>${campo.getNombres()}</td>
                    <td>${campo.getFecha()}</td>
                    <td>
                        <c:choose>
                            <c:when test="${campo.getEstado() == 'Activo' || campo.getEstado() == null}">
                                <span class="status status-activo">Activo</span>
                            </c:when>
                            <c:when test="${campo.getEstado() == 'Pendiente'}">
                                <span class="status status-pendiente">Pendiente</span>
                            </c:when>
                            <c:when test="${campo.getEstado() == 'Completado'}">
                                <span class="status status-completado">Completado</span>
                            </c:when>
                            <c:when test="${campo.getEstado() == 'Entregado'}">
                                <span class="status status-entregado">Entregado</span>
                            </c:when>
                            <c:when test="${campo.getEstado() == 'Anulado'}">
                                <span class="status status-anulado">Anulado</span>
                            </c:when>
                            <c:otherwise>
                                <span class="status status-activo">${campo.getEstado()}</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td class="total-amount">S/. ${String.format("%.2f", campo.getTotalVenta())}</td>
                    <td>
                        <a href="ControlerPedido?Op=Consultar&Id=${campo.getId_Pedido()}" 
                           class="btn btn-info" title="Ver detalles">
                             Consultar
                        </a>
                        <a href="ControlerPedido?Op=Modificar&Id=${campo.getId_Pedido()}" 
                           class="btn btn-warning" title="Modificar pedido">
                             Modificar
                        </a>
                        <c:if test="${campo.getEstado() != 'Anulado'}">
                            <a href="ControlerPedido?Op=Eliminar&Id=${campo.getId_Pedido()}" 
                               class="btn btn-danger" title="Anular pedido"
                               onclick="return confirm('¿Está seguro de anular este pedido?')">
                                Anular
                            </a>
                        </c:if>
                    </td>
                </tr>
                </c:forEach>
            </tbody>
        </table>

        <c:if test="${empty Lista}">
            <div style="text-align: center; padding: 50px; color: #666;">
                <h3>📭 No hay pedidos registrados</h3>
                <p>Comience creando un nuevo pedido</p>
                <a href="ControlerPedido?Op=Nuevo" class="menu-btn">Crear Primer Pedido</a>
            </div>
        </c:if>
    </div>

    <script>
        // Confirmar eliminación
        function confirmarEliminacion(id) {
            if (confirm('¿Está seguro de que desea anular el pedido ' + id + '?')) {
                window.location.href = 'ControlerPedido?Op=Eliminar&Id=' + id;
            }
        }

        // Resaltar filas según estado
        document.addEventListener('DOMContentLoaded', function() {
            const rows = document.querySelectorAll('tbody tr');
            rows.forEach(row => {
                const statusCell = row.querySelector('.status');
                if (statusCell) {
                    if (statusCell.textContent.includes('Anulado')) {
                        row.style.opacity = '0.6';
                    }
                }
            });
        });
    </script>
    
</body>
</html>
