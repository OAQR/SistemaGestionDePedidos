<%-- 
    Document   : nuevoPedido
    Created on : 8 jun. 2025, 17:46:54
    Author     : Matiasjobeth
--%>
<%-- 
    Document   : nuevoPedido
    Created on : 8 jun. 2025, 17:46:54
    Author     : Matiasjobeth
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.ArrayList"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
        <script src="sessionTimeout.js"></script>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Nuevo Pedido</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
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
    <div class="container mt-4">
        <h2>Crear Nuevo Pedido</h2>
        
        <!-- Buscar Cliente -->
        <div class="card mb-4">
            <div class="card-header">
                <h5>1. Buscar Cliente</h5>
            </div>
            <div class="card-body">
                <form method="GET" action="ControlerPedido">
                    <input type="hidden" name="Op" value="BuscarCliente">
                    <div class="input-group">
                        <input type="text" class="form-control" name="idCliente" 
                               placeholder="Ingrese ID del cliente" required>
                        <button class="btn btn-primary" type="submit">Buscar Cliente</button>
                    </div>
                </form>
                
                <!-- Mostrar información del cliente encontrado -->
                <c:if test="${not empty ClienteEncontrado}">
                    <div class="row mt-3">
                        <!-- Información del Cliente -->
                        <div class="col-md-8">
                            <div class="alert alert-success">
                                <h6>Cliente Encontrado:</h6>
                                <p><strong>ID:</strong> ${ClienteEncontrado[0]}</p>
                                <p><strong>Nombre:</strong> ${ClienteEncontrado[2]} ${ClienteEncontrado[1]}</p>
                                <p><strong>Dirección:</strong> 
                                    <c:choose>
                                        <c:when test="${not empty ClienteEncontrado[3] and ClienteEncontrado[3] ne 'null' and ClienteEncontrado[3] ne ''}">
                                            ${ClienteEncontrado[3]}
                                        </c:when>
                                        <c:otherwise>
                                            No disponible
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                                <p><strong>DNI:</strong> 
                                    <c:choose>
                                        <c:when test="${not empty ClienteEncontrado[4] and ClienteEncontrado[4] ne 'null' and ClienteEncontrado[4] ne ''}">
                                            ${ClienteEncontrado[4]}
                                        </c:when>
                                        <c:otherwise>
                                            No disponible
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                                <p><strong>Teléfono:</strong> 
                                    <c:choose>
                                        <c:when test="${not empty ClienteEncontrado[5] and ClienteEncontrado[5] ne 'null' and ClienteEncontrado[5] ne ''}">
                                            ${ClienteEncontrado[5]}
                                        </c:when>
                                        <c:otherwise>
                                            No disponible
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                                <p><strong>Móvil:</strong> 
                                    <c:choose>
                                        <c:when test="${not empty ClienteEncontrado[6] and ClienteEncontrado[6] ne 'null' and ClienteEncontrado[6] ne ''}">
                                            ${ClienteEncontrado[6]}
                                        </c:when>
                                        <c:otherwise>
                                            No disponible
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                            </div>
                        </div>
                        
                        <!-- Información del Pedido -->
                        <div class="col-md-4">
                            <div class="alert alert-info">
                                <h6>📋 Información del Pedido</h6>
                                <p><strong>Nro. Pedido:</strong> ${NuevoPedidoId}</p>
                                <small class="text-muted">(Autogenerado)</small>
                                <hr>
                                <p><strong>Fecha Pedido:</strong><br>
                                <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></p>
                                <small class="text-muted">Se asigna automáticamente al crear el pedido</small>
                                <hr>
                                <!-- NUEVO: Cantidad de líneas -->
                                <p><strong>Cant. Líneas:</strong><br>
                                <span id="cantLineas" class="badge bg-primary fs-6">0</span></p>
                                <small class="text-muted">Productos diferentes seleccionados</small>
                                <hr>
                                <!-- NUEVO: Estado del pedido -->
                                <p><strong>Estado:</strong><br>
                                <span id="estadoPedido" class="badge bg-warning fs-6">Pendiente</span></p>
                                <small class="text-muted">Cambiará a "Aceptado" al crear el pedido</small>
                            </div>
                        </div>
                    </div>
                </c:if>
                
                <!-- Mostrar error si no se encuentra el cliente -->
                <c:if test="${not empty ErrorCliente}">
                    <div class="alert alert-danger mt-3">
                        ${ErrorCliente}
                    </div>
                </c:if>
            </div>
        </div>

        <!-- Selección de Productos (solo si hay cliente encontrado) -->
        <c:if test="${not empty ClienteEncontrado}">
            <form method="POST" action="ControlerPedido" id="formPedido">
                <input type="hidden" name="Op" value="Crear">
                <input type="hidden" name="Id_Cliente" value="${ClienteEncontrado[0]}">
                <input type="hidden" name="Id_Pedido_Generado" value="${NuevoPedidoId}">
                <!-- NUEVO: Campo oculto para cantidad de líneas -->
                <input type="hidden" name="CantLineas" id="inputCantLineas" value="0">
                
                <div class="card mb-4">
                    <div class="card-header">
                        <h5>2. Seleccionar Productos</h5>
                    </div>
                    <div class="card-body">
                        <c:if test="${not empty Productos}">
                            <div class="table-responsive">
                                <table class="table table-striped">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Producto</th>
                                            <th>Precio</th>
                                            <th>Stock</th>
                                            <th>Cantidad</th>
                                            <th>IGV (18%)</th>
                                            <th>Subtotal</th>
                                        </tr>
                                    </thead>
                                    <tbody id="productosBody">
                                        <c:forEach var="producto" items="${Productos}" varStatus="status">
                                            <tr>
                                                <td>
                                                    <small class="text-muted">${producto[0]}</small>
                                                    <input type="hidden" name="productos[]" value="${producto[0]}">
                                                </td>
                                                <td>
                                                    ${producto[1]}
                                                </td>
                                                <td>
                                                    S/. ${producto[2]}
                                                    <input type="hidden" name="precios[]" value="${producto[2]}" class="precio">
                                                </td>
                                                <td>
                                                    <span class="badge bg-secondary">${producto[3]}</span>
                                                </td>
                                                <td>
                                                    <input type="number" class="form-control cantidad" 
                                                           name="cantidades[]" min="0" max="${producto[3]}" 
                                                           value="0" onchange="calcularSubtotal(this)" style="width: 80px;">
                                                </td>
                                                <td>
                                                    <span class="igv-fila text-success">S/. 0.00</span>
                                                </td>
                                                <td>
                                                    <span class="subtotal font-weight-bold">S/. 0.00</span>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:if>
                        
                        <c:if test="${not empty ErrorProductos}">
                            <div class="alert alert-danger">
                                ${ErrorProductos}
                            </div>
                        </c:if>
                    </div>
                </div>

                <!-- Totales -->
                <div class="card mb-4">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-8"></div>
                            <div class="col-md-4">
                                <div class="row">
                                    <div class="col-6"><strong>Subtotal:</strong></div>
                                    <div class="col-6 text-end">
                                        <span id="subtotalGeneral">S/. 0.00</span>
                                        <input type="hidden" name="SubTotal" id="inputSubtotal" value="0">
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-6"><strong>IGV (18%):</strong></div>
                                    <div class="col-6 text-end">
                                        <span id="igvGeneral">S/. 0.00</span>
                                    </div>
                                </div>
                                <hr>
                                <div class="row">
                                    <div class="col-6"><strong>Total:</strong></div>
                                    <div class="col-6 text-end">
                                        <strong><span id="totalGeneral">S/. 0.00</span></strong>
                                        <input type="hidden" name="TotalVenta" id="inputTotal" value="0">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Botones -->
                <div class="text-center">
                    <button type="submit" class="btn btn-success btn-lg">Crear Pedido</button>
                    <a href="ControlerPedido?Op=Listar" class="btn btn-secondary btn-lg ms-2">Cancelar</a>
                </div>
            </form>
        </c:if>
    </div>

    <script>
        function calcularSubtotal(input) {
            const fila = input.closest('tr');
            const precio = parseFloat(fila.querySelector('.precio').value);
            const cantidad = parseFloat(input.value) || 0;
            const subtotalSinIgv = precio * cantidad;
            const igvFila = subtotalSinIgv * 0.18;
            const subtotalConIgv = subtotalSinIgv + igvFila;
            
            // Actualizar IGV de la fila
            fila.querySelector('.igv-fila').textContent = 'S/. ' + igvFila.toFixed(2);
            
            // Actualizar subtotal de la fila (precio sin IGV)
            fila.querySelector('.subtotal').textContent = 'S/. ' + subtotalSinIgv.toFixed(2);
            
            calcularTotales();
            actualizarCantLineas(); // NUEVO: Actualizar cantidad de líneas
        }

        function calcularTotales() {
            let subtotalGeneral = 0;
            
            document.querySelectorAll('.cantidad').forEach(function(input) {
                const fila = input.closest('tr');
                const precio = parseFloat(fila.querySelector('.precio').value);
                const cantidad = parseFloat(input.value) || 0;
                subtotalGeneral += precio * cantidad;
            });
            
            const igv = subtotalGeneral * 0.18;
            const total = subtotalGeneral + igv;
            
            document.getElementById('subtotalGeneral').textContent = 'S/. ' + subtotalGeneral.toFixed(2);
            document.getElementById('igvGeneral').textContent = 'S/. ' + igv.toFixed(2);
            document.getElementById('totalGeneral').textContent = 'S/. ' + total.toFixed(2);
            
            document.getElementById('inputSubtotal').value = subtotalGeneral.toFixed(2);
            document.getElementById('inputTotal').value = total.toFixed(2);
        }

        // NUEVA FUNCIÓN: Actualizar cantidad de líneas (productos diferentes)
        function actualizarCantLineas() {
            let cantLineas = 0;
            
            document.querySelectorAll('.cantidad').forEach(function(input) {
                const cantidad = parseFloat(input.value) || 0;
                if (cantidad > 0) {
                    cantLineas++;
                }
            });
            
            // Actualizar en la interfaz
            document.getElementById('cantLineas').textContent = cantLineas;
            document.getElementById('inputCantLineas').value = cantLineas;
            
            // NUEVO: Actualizar color del badge según cantidad
            const badge = document.getElementById('cantLineas');
            if (cantLineas === 0) {
                badge.className = 'badge bg-secondary fs-6';
            } else if (cantLineas <= 3) {
                badge.className = 'badge bg-primary fs-6';
            } else if (cantLineas <= 6) {
                badge.className = 'badge bg-info fs-6';
            } else {
                badge.className = 'badge bg-success fs-6';
            }
        }

        // Validar que al menos un producto tenga cantidad > 0
        document.getElementById('formPedido').addEventListener('submit', function(e) {
            let tieneProductos = false;
            document.querySelectorAll('.cantidad').forEach(function(input) {
                if (parseFloat(input.value) > 0) {
                    tieneProductos = true;
                }
            });
            
            if (!tieneProductos) {
                e.preventDefault();
                alert('Debe seleccionar al menos un producto con cantidad mayor a 0');
                return false;
            }
            
            // NUEVO: Cambiar estado a "Procesando..." al enviar
            const estadoBadge = document.getElementById('estadoPedido');
            estadoBadge.textContent = 'Procesando...';
            estadoBadge.className = 'badge bg-info fs-6';
            
            // Deshabilitar el botón para evitar doble envío
            const submitBtn = e.target.querySelector('button[type="submit"]');
            submitBtn.disabled = true;
            submitBtn.textContent = 'Creando Pedido...';
        });

        // NUEVO: Inicializar al cargar la página
        document.addEventListener('DOMContentLoaded', function() {
            // Si hay cliente encontrado, inicializar contadores
            if (document.getElementById('cantLineas')) {
                actualizarCantLineas();
            }
        });
    </script>
</body>
</html>