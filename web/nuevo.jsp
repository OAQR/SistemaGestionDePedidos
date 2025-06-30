<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Nuevo Cliente - Sistema de Gestión</title>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="css/panles.css"/>
    <link rel="stylesheet" href="css/nuevo-cliente.css"/>
    
    <!-- Sistema de Inactividad -->
    <script src="sessionTimeout.js"></script>
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
        <div class="header-box">
            <h1>Nuevo Cliente</h1>
            <a href="Clientes.jsp" class="back-button">Volver al menú de clientes</a>
        </div>
        
        <!-- Mostrar mensajes de error -->
        <% if(request.getParameter("error") != null) { %>
            <div class="alert alert-danger" role="alert">
                <% 
                String error = request.getParameter("error");
                if(error.equals("apellidos_requeridos")) {
                    out.print("Los apellidos son obligatorios");
                } else if(error.equals("nombres_requeridos")) {
                    out.print("Los nombres son obligatorios");
                } else if(error.equals("dni_requerido")) {
                    out.print("El DNI es obligatorio");
                } else if(error.equals("dni_existe")) {
                    out.print("Ya existe un cliente con ese DNI");
                } else if(error.equals("noguardado")) {
                    out.print("Error al guardar el cliente");
                } else if(error.equals("sql")) {
                    out.print("Error en la base de datos");
                } else {
                    out.print("Error desconocido");
                }
                %>
            </div>
        <% } %>
        
        <div class="card">
            <div class="card-header">
                <h5>Datos del Cliente</h5>
            </div>
            <div class="card-body">
                <form method="POST" action="ControlerCliente">
                    <div class="mb-3">
                        <label for="apellidos" class="form-label">Apellidos <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="apellidos" name="apellidos" 
                               value="<%= request.getParameter("apellidos") != null ? request.getParameter("apellidos") : "" %>" 
                               required>
                    </div>
                    
                    <div class="mb-3">
                        <label for="nombres" class="form-label">Nombres <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="nombres" name="nombres" 
                               value="<%= request.getParameter("nombres") != null ? request.getParameter("nombres") : "" %>" 
                               required>
                    </div>
                    
                    <div class="mb-3">
                        <label for="DNI" class="form-label">DNI <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="DNI" name="DNI" 
                               value="<%= request.getParameter("DNI") != null ? request.getParameter("DNI") : "" %>" 
                               required maxlength="8" pattern="[0-9]{8}" 
                               title="Ingrese 8 dígitos">
                    </div>
                    
                    <div class="mb-3">
                        <label for="direccion" class="form-label">Dirección</label>
                        <input type="text" class="form-control" id="direccion" name="direccion" 
                               value="<%= request.getParameter("direccion") != null ? request.getParameter("direccion") : "" %>">
                    </div>
                    
                    <div class="mb-3">
                        <label for="telefono" class="form-label">Teléfono</label>
                        <input type="text" class="form-control" id="telefono" name="telefono" 
                               value="<%= request.getParameter("telefono") != null ? request.getParameter("telefono") : "" %>">
                    </div>
                    
                    <div class="mb-3">
                        <label for="movil" class="form-label">Móvil</label>
                        <input type="text" class="form-control" id="movil" name="movil" 
                               value="<%= request.getParameter("movil") != null ? request.getParameter("movil") : "" %>">
                    </div>
                    
                    <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                        <a href="Clientes.jsp" class="btn btn-secondary me-md-2">Cancelar</a>
                        <button type="submit" class="btn btn-primary">Guardar Cliente</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        document.getElementById('DNI').addEventListener('input', function(e) {
            this.value = this.value.replace(/[^0-9]/g, '');
            if(this.value.length > 8) {
                this.value = this.value.slice(0, 8);
            }
        });
        
        document.querySelector('form').addEventListener('submit', function(e) {
            const apellidos = document.getElementById('apellidos').value.trim();
            const nombres = document.getElementById('nombres').value.trim();
            const dni = document.getElementById('DNI').value.trim();
            
            if(!apellidos) {
                alert('Los apellidos son obligatorios');
                e.preventDefault();
                return false;
            }
            
            if(!nombres) {
                alert('Los nombres son obligatorios');
                e.preventDefault();
                return false;
            }
            
            if(!dni || dni.length !== 8) {
                alert('El DNI debe tener exactamente 8 dígitos');
                e.preventDefault();
                return false;
            }
        });
    </script>
</body>
</html>