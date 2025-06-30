<%-- 
    Document   : modificarPedido
    Created on : 8 jun. 2025, 17:27:06
    Author     : Matiasjobeth
--%>

<%@page import="Entidades.pedido"%>
<%@page import="Entidades.detallePedido"%>
<%@page import="java.util.ArrayList"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    pedido Pedido = (pedido) request.getAttribute("Pedido");
    ArrayList<detallePedido> ListaDetalle = (ArrayList<detallePedido>) request.getAttribute("ListaDetalle");
%>
<!DOCTYPE html>
<html>
    
<head>
    
    <script src="sessionTimeout.js"></script>
    
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Modificar Pedido</title>
   <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="css/modificarPedi.css"/>
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
            <h1>Modificar pedido</h1>
             <a href="index.jsp" class="back-button">Volver al menú principal</a>
            <p>Actualizar información del pedido N° <%= Pedido.getId_Pedido() %></p>
        </div>

        <form action="ControlerPedido" method="post">
            <input type="hidden" name="Op" value="Actualizar">
            <input type="hidden" name="Id_Pedido" value="<%= Pedido.getId_Pedido() %>">
            
            <!-- Información del Pedido -->
            <div class="form-section">
                <div class="section-title">Información del Pedido</div>
                
                <div class="form-row">
                    <label>Nro. Pedido:</label>
                    <input type="text" value="<%= Pedido.getId_Pedido() %>" class="readonly" readonly>
                </div>
                
                <div class="form-row">
                    <label>Cliente:</label>
                    <input type="text" value="<%= Pedido.getId_Cliente() %> - <%= Pedido.getNombres() %> <%= Pedido.getApellidos() %>" class="readonly" readonly>
                </div>
                
                <div class="form-row">
                    <label>Fecha Pedido:</label>
                    <input type="date" value="<%= Pedido.getFecha() %>" class="readonly" readonly>
                </div>
            </div>

            <!-- Productos del Pedido -->
            <div class="form-section">
                <div class="section-title">Productos del Pedido</div>
                
                <% if (ListaDetalle != null && !ListaDetalle.isEmpty()) { %>
                    <div class="table-container">
                        <table class="productos-table">
                            <thead>
                                <tr>
                                    <th>Código</th>
                                    <th>Producto</th>
                                    <th>Precio Unit.</th>
                                    <th>Cantidad</th>
                                    <th>Total</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (detallePedido detalle : ListaDetalle) { %>
                                    <tr>
                                        <td><%= detalle.getId_Prod() %></td>
                                        <td><%= detalle.getDescripcion() %></td>
                                        <td>S/. <%= String.format("%.2f", detalle.getPrecio()) %></td>
                                        <td>
                                            <input type="number" 
                                                   name="cantidad_<%= detalle.getId_Prod() %>" 
                                                   value="<%= String.format("%.0f", detalle.getCantidad()) %>" 
                                                   min="0" 
                                                   step="1"
                                                   data-precio="<%= detalle.getPrecio() %>"
                                                   class="cantidad-input"
                                                   onchange="calcularTotal(this)">
                                        </td>
                                        <td class="total-producto">S/. <%= String.format("%.2f", detalle.getTotalDeta()) %></td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                    
                    <!-- Resumen de Totales -->
                    <div class="totales-resumen">
                        <div class="total-row">
                            <label>Sub Total:</label>
                            <span id="subtotal-display">S/. <%= String.format("%.2f", Pedido.getSubTotal()) %></span>
                        </div>
                        <div class="total-row">
                            <label>IGV (18%):</label>
                            <span id="igv-display">S/. <%= String.format("%.2f", Pedido.getTotalVenta() - Pedido.getSubTotal()) %></span>
                        </div>
                        <div class="total-row total-final">
                            <label>Total Venta:</label>
                            <span id="total-display">S/. <%= String.format("%.2f", Pedido.getTotalVenta()) %></span>
                        </div>
                    </div>
                <% } else { %>
                    <p>No hay productos en este pedido.</p>
                <% } %>
            </div>

            <!-- Estado y Seguimiento -->
            <div class="form-section">
                <div class="section-title">Estado y Seguimiento</div>
                
                <div class="form-row">
                    <label>Estado:</label>
                    <select name="Estado" required>
                        <option value="Pendiente" <%= "Pendiente".equals(Pedido.getEstado()) ? "selected" : "" %>>Pendiente</option>
                        <option value="En Proceso" <%= "En Proceso".equals(Pedido.getEstado()) ? "selected" : "" %>>En Proceso</option>
                        <option value="Completado" <%= "Completado".equals(Pedido.getEstado()) ? "selected" : "" %>>Completado</option>
                        <option value="Entregado" <%= "Entregado".equals(Pedido.getEstado()) ? "selected" : "" %>>Entregado</option>
                        <option value="Anulado" <%= "Anulado".equals(Pedido.getEstado()) ? "selected" : "" %>>Anulado</option>
                    </select>
                </div>
                
                <div class="form-row">
                    <label>Fecha Entrega:</label>
                    <input type="date" name="FechaEntrega" 
                           value="<%= Pedido.getFechaEntrega() != null ? Pedido.getFechaEntrega().toString() : "" %>">
                </div>
            </div>

            <!-- Información de Entrega -->
            <div class="form-section">
                <div class="section-title">Información de Entrega</div>
                
                <div class="form-row">
                    <label>Dirección:</label>
                    <input type="text" name="DireccionEntrega" 
                           value="<%= Pedido.getDireccionEntrega() != null ? Pedido.getDireccionEntrega() : "" %>"
                           placeholder="Ingrese dirección de entrega">
                </div>
                
                <div class="form-row">
                    <label>Teléfono:</label>
                    <input type="text" name="TelefonoContacto" 
                           value="<%= Pedido.getTelefonoContacto() != null ? Pedido.getTelefonoContacto() : "" %>"
                           placeholder="Ingrese teléfono de contacto">
                </div>
            </div>

            <!-- Botones -->
            <div class="buttons">
                <button type="submit" class="btn btn-primary">
                    Guardar Cambios
                </button>
                <a href="ControlerPedido?Op=Listar" class="btn btn-secondary">
                    Volver al Listado
                </a>
            </div>
        </form>
    </div>

    <script>
        // Función para calcular el total de cada producto
        function calcularTotal(input) {
            const precio = parseFloat(input.getAttribute('data-precio'));
            const cantidad = parseFloat(input.value) || 0;
            const total = precio * cantidad;
            
            // Actualizar el total en la fila
            const totalCell = input.closest('tr').querySelector('.total-producto');
            totalCell.textContent = 'S/. ' + total.toFixed(2);
            
            // Recalcular el total general
            calcularTotalGeneral();
        }
        
        // Función para calcular el total general del pedido
        function calcularTotalGeneral() {
            let subTotal = 0;
            
            document.querySelectorAll('.cantidad-input').forEach(function(input) {
                const precio = parseFloat(input.getAttribute('data-precio'));
                const cantidad = parseFloat(input.value) || 0;
                subTotal += precio * cantidad;
            });
            
            const igv = subTotal * 0.18;
            const totalVenta = subTotal + igv;
            
            // Actualizar los campos de totales
            document.getElementById('subtotal-display').textContent = 'S/. ' + subTotal.toFixed(2);
            document.getElementById('igv-display').textContent = 'S/. ' + igv.toFixed(2);
            document.getElementById('total-display').textContent = 'S/. ' + totalVenta.toFixed(2);
        }

        // Validación de fecha de entrega
        document.querySelector('input[name="FechaEntrega"]').addEventListener('change', function() {
            const fechaPedido = new Date('<%= Pedido.getFecha() %>');
            const fechaEntrega = new Date(this.value);
            
            if (fechaEntrega < fechaPedido) {
                alert('La fecha de entrega no puede ser anterior a la fecha del pedido');
                this.value = '';
            }
        });

        // Cambio de color según estado
        document.querySelector('select[name="Estado"]').addEventListener('change', function() {
            this.className = '';
            switch(this.value) {
                case 'Completado':
                case 'Entregado':
                    this.className = 'status-active';
                    break;
                case 'Pendiente':
                case 'En Proceso':
                    this.className = 'status-pending';
                    break;
                case 'Anulado':
                    this.className = 'status-cancelled';
                    break;
            }
        });

        // Validación antes de enviar el formulario (permitir cantidades de 0)
        document.querySelector('form').addEventListener('submit', function(e) {
            // Verificar que hay al menos un producto con cantidad mayor a 0
            let hayProductos = false;
            document.querySelectorAll('.cantidad-input').forEach(function(input) {
                const cantidad = parseFloat(input.value);
                if (cantidad > 0) {
                    hayProductos = true;
                }
            });
            
            if (!hayProductos) {
                e.preventDefault();
                alert('Debe haber al menos un producto con cantidad mayor a 0');
                return false;
            }
        });

        // Trigger inicial para establecer el color del estado
        document.querySelector('select[name="Estado"]').dispatchEvent(new Event('change'));
        
        // Calcular total inicial
        calcularTotalGeneral();
    </script>
    
</body>

</html> 