<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%-- 
    Document   : index
    Created on : 19/11/2021, 07:15:10 PM
    Author     : javie
--%>
<%@page import="java.util.List"%>
<%@page import="Entidades.detallePedido"%>
<%@page import="Entidades.pedido"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    List<detallePedido> Lista = (List<detallePedido>) request.getAttribute("Lista");
    pedido Pedido = (pedido) request.getAttribute("Pedido");
%>
<!DOCTYPE html>
<html>
<head>
    <script src="sessionTimeout.js"></script>
    
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Consultar Pedido</title>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/consultpedidos.css"/>
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
            <h1>Consultar Pedido</h1>
            <a href="index.jsp" class="back-button">Volver al menú principal</a>
            <p>Información completa del pedido N° <strong>${Pedido.id_Pedido}</strong></p>
        </div>

        <!-- Información del Pedido y Cliente -->
        <c:if test="${not empty Pedido}">
            <div class="info-sections">
                <!-- Información General del Pedido -->
                <div class="form-section">
                    <div class="section-title">📋 Información del Pedido</div>
                    
                    <div class="info-grid">
                        <div class="info-item">
                            <label>Nro. Pedido:</label>
                            <span class="value">${Pedido.getId_Pedido()}</span>
                        </div>
                        
                        <div class="info-item">
                            <label>Fecha Pedido:</label>
                            <span class="value">
                                <c:choose>
                                    <c:when test="${not empty Pedido.getFecha()}">
                                        ${Pedido.getFecha()}
                                    </c:when>
                                    <c:otherwise>No disponible</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        
                        <div class="info-item">
                            <label>Estado:</label>
                            <span class="status-badge status-${Pedido.getEstado().toLowerCase().replace(' ', '-')}">
                                <c:choose>
                                    <c:when test="${not empty Pedido.getEstado()}">
                                        ${Pedido.getEstado()}
                                    </c:when>
                                    <c:otherwise>Pendiente</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        
                        <div class="info-item">
                            <label>Fecha Entrega:</label>
                            <span class="value">
                                <c:choose>
                                    <c:when test="${not empty Pedido.getFechaEntrega()}">
                                        ${Pedido.getFechaEntrega()}
                                    </c:when>
                                    <c:otherwise>No programada</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Información del Cliente -->
                <div class="form-section">
                    <div class="section-title">👤 Información del Cliente</div>
                    
                    <div class="info-grid">
                        <div class="info-item">
                            <label>ID Cliente:</label>
                            <span class="value">${Pedido.getId_Cliente()}</span>
                        </div>
                        
                        <div class="info-item">
                            <label>Cliente:</label>
                            <span class="value">
                                <c:choose>
                                    <c:when test="${not empty Pedido.getNombres() and not empty Pedido.getApellidos()}">
                                        ${Pedido.getNombres()} ${Pedido.getApellidos()}
                                    </c:when>
                                    <c:otherwise>Información no disponible</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        
                        <div class="info-item">
                            <label>Dirección Entrega:</label>
                            <span class="value">
                                <c:choose>
                                    <c:when test="${not empty Pedido.getDireccionEntrega()}">
                                        ${Pedido.getDireccionEntrega()}
                                    </c:when>
                                    <c:otherwise>No especificada</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        
                        <div class="info-item">
                            <label>Teléfono Contacto:</label>
                            <span class="value">
                                <c:choose>
                                    <c:when test="${not empty Pedido.getTelefonoContacto()}">
                                        ${Pedido.getTelefonoContacto()}
                                    </c:when>
                                    <c:otherwise>No disponible</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Observaciones -->
                <c:if test="${not empty Pedido.getObservaciones()}">
                    <div class="form-section">
                        <div class="section-title">📝 Observaciones</div>
                        <div class="observaciones-box">
                            ${Pedido.getObservaciones()}
                        </div>
                    </div>
                </c:if>
            </div>
        </c:if>

        <!-- Detalle de Productos -->
        <div class="form-section">
            <div class="section-title">🛒 Detalle de Productos</div>
            
            <c:choose>
                <c:when test="${not empty Lista}">
                    <div class="table-responsive">
                        <table class="productos-table">
                            <thead>
                                <tr>
                                    <th>ID Producto</th>
                                    <th>Descripción</th>
                                    <th>Cantidad</th>
                                    <th>Precio Unit.</th>
                                    <th>IGV (18%)</th>
                                    <th>Subtotal</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="detalle" items="${Lista}">
                                    <tr>
                                        <td><strong>${detalle.getId_Prod()}</strong></td>
                                        <td>${detalle.getDescripcion()}</td>
                                        <td class="text-center">
                                            <span class="cantidad-badge">${detalle.getCantidad()}</span>
                                        </td>
                                        <td class="text-right">S/. ${String.format("%.2f", detalle.getPrecio())}</td>
                                        <td class="text-right igv-text">
                                            S/. ${String.format("%.2f", detalle.getTotalDeta() * 0.18)}
                                        </td>
                                        <td class="text-right total-producto">
                                            <strong>S/. ${String.format("%.2f", detalle.getTotalDeta())}</strong>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <!-- Totales del Pedido -->
                    <div class="totales-section">
                        <div class="totales-box">
                            <%
                                double subtotalGeneral = 0;
                                if (Lista != null) {
                                    for (detallePedido detalle : Lista) {
                                        subtotalGeneral += detalle.getTotalDeta();
                                    }
                                }
                                double igvGeneral = subtotalGeneral * 0.18;
                                double totalGeneral = subtotalGeneral + igvGeneral;
                            %>
                            
                            <div class="total-row">
                                <span class="total-label">Subtotal:</span>
                                <span class="total-value">S/. <%= String.format("%.2f", subtotalGeneral) %></span>
                            </div>
                            
                            <div class="total-row">
                                <span class="total-label">IGV (18%):</span>
                                <span class="total-value igv-text">S/. <%= String.format("%.2f", igvGeneral) %></span>
                            </div>
                            
                            <hr class="total-divider">
                            
                            <div class="total-row total-final">
                                <span class="total-label">Total General:</span>
                                <span class="total-value">S/. <%= String.format("%.2f", totalGeneral) %></span>
                            </div>
                            
                            <!-- Información adicional -->
                            <div class="info-adicional">
                                <small class="text-muted">
                                    Cantidad de líneas: <strong><%= Lista != null ? Lista.size() : 0 %></strong> producto(s)
                                </small>
                            </div>
                        </div>
                    </div>
                </c:when>
                
                <c:otherwise>
                    <div class="no-productos">
                        <div class="empty-state">
                            <h3>📦 Sin productos</h3>
                            <p>Este pedido no tiene productos asociados</p>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

<!-- Botones de Acción -->
<div class="action-buttons">
    <a href="ControlerPedido?Op=Modificar&Id=${Pedido.id_Pedido}" 
       class="btn btn-warning">
        ✏️ Modificar Pedido
    </a>
    
    <a href="ControlerPedido?Op=Listar" class="btn btn-primary">
        📋 Volver al Listado
    </a>
    
    <button onclick="window.print()" class="btn btn-info">
        🖨️ Imprimir
    </button>
</div>

    <script>
        // Resaltar el estado del pedido
        document.addEventListener('DOMContentLoaded', function() {
            const statusBadge = document.querySelector('.status-badge');
            if (statusBadge) {
                const status = statusBadge.textContent.trim().toLowerCase();
                statusBadge.classList.add('status-' + status.replace(' ', '-'));
            }
        });

        // Función para imprimir solo el contenido relevante
        function imprimirPedido() {
            const contenido = document.querySelector('.container').innerHTML;
            const ventanaImpresion = window.open('', '_blank');
            ventanaImpresion.document.write(`
                <html>
                <head>
                    <title>Pedido ${Lista != null && !Lista.isEmpty() ? Lista.get(0).getId_Pedido() : ""}</title>
                    <style>
                        body { font-family: Arial, sans-serif; margin: 20px; }
                        .header-box h1 { color: #333; border-bottom: 2px solid #007bff; }
                        .form-section { margin-bottom: 20px; }
                        .section-title { font-weight: bold; color: #007bff; margin-bottom: 10px; }
                        table { width: 100%; border-collapse: collapse; }
                        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
                        th { background-color: #f8f9fa; }
                        .totales-box { border: 1px solid #ddd; padding: 15px; margin-top: 20px; }
                        .action-buttons { display: none; }
                        .back-button { display: none; }
                    </style>
                </head>
                <body>${contenido}</body>
                </html>
            `);
            ventanaImpresion.document.close();
            ventanaImpresion.print();
        }
    </script>
</body>
</html>
