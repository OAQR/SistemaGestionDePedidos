<%-- 
    Document   : usuarios
    Created on : 1 jun. 2025, 16:09:31
    Author     : Matiasjobeth
--%>

<%@page import="Entidades.usuarios"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <script src="sessionTimeout.js"></script>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
        <meta http-equiv="Pragma" content="no-cache">
        <meta http-equiv="Expires" content="0">
        
        <title>Gestión de Usuarios</title>
        <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="css/usuario.css"/>
        <script>
            function confirmarEliminacion(usuario, esAdmin) {
                if (esAdmin === 1) {
                    alert('No se puede eliminar un usuario administrador.');
                    return false;
                }
                if (confirm('¿Estás seguro de que deseas eliminar el usuario "' + usuario + '"? Esta acción no se puede deshacer.')) {
                    document.getElementById('eliminarForm_' + usuario).submit();
                    return true;
                }
                return false;
            }
            
            function togglePassword(inputId, buttonId) {
                var input = document.getElementById(inputId);
                var button = document.getElementById(buttonId);
                
                if (input.type === "password") {
                    input.type = "text";
                    button.innerHTML = "👁️‍🗨️";
                    button.title = "Ocultar contraseña";
                } else {
                    input.type = "password";
                    button.innerHTML = "👁️";
                    button.title = "Mostrar contraseña";
                }
            }
            
            function togglePasswordDisplay(elementId) {
                var element = document.getElementById(elementId);
                var currentText = element.innerHTML;
                
                if (currentText.includes('•')) {
                    element.innerHTML = element.getAttribute('data-password');
                } else {
                    element.innerHTML = '••••••••';
                }
            }

            // CRÍTICO: Manejo mejorado del historial del navegador
            window.onload = function() {
                // Prevenir caché del navegador
                if (window.performance && window.performance.navigation.type === 2) {
                    // Si viene del botón atrás, recargar la página
                    window.location.reload();
                }
                
                // Limpiar formularios después de operaciones exitosas
                var urlParams = new URLSearchParams(window.location.search);
                if (urlParams.has('mensaje') || urlParams.has('error')) {
                    // Limpiar el formulario de agregar usuario
                    var formAgregar = document.querySelector('form[action="UsuariosServlet"]');
                    if (formAgregar && formAgregar.querySelector('input[name="accion"][value="agregar"]')) {
                        formAgregar.reset();
                    }
                    
                    // Quitar parámetros de la URL después de mostrar el mensaje
                    setTimeout(function() {
                        var newUrl = window.location.pathname + '?accion=listar&_t=' + new Date().getTime();
                        window.history.replaceState({}, document.title, newUrl);
                    }, 3000);
                }
                
                // Manejo del botón atrás del navegador
                window.addEventListener('popstate', function(event) {
                    // Si el usuario presiona atrás, ir al menú principal
                    var currentUrl = window.location.href;
                    if (currentUrl.includes('UsuariosServlet') || currentUrl.includes('usuarios.jsp')) {
                        window.location.href = 'index.jsp';
                    }
                });
                
                // Agregar entrada al historial para manejo correcto del botón atrás
                if (window.location.search.includes('accion=listar')) {
                    history.pushState({page: 'usuarios'}, 'Gestión de Usuarios', window.location.href);
                }
            };
            
            // Función para manejar envío de formularios
            function enviarFormulario(form) {
                // Mostrar indicador de carga
                var submitButton = form.querySelector('button[type="submit"]');
                if (submitButton) {
                    submitButton.disabled = true;
                    submitButton.innerHTML = 'Procesando...';
                }
                
                // Enviar formulario
                form.submit();
                
                // Prevenir envíos múltiples
                setTimeout(function() {
                    if (submitButton) {
                        submitButton.disabled = false;
                        submitButton.innerHTML = submitButton.getAttribute('data-original-text') || 'Enviar';
                    }
                }, 3000);
            }
        </script>
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
        <%  
            if (session.getAttribute("user")==null){
                response.sendRedirect("login.jsp");
                return;
            }
            
            Boolean esAdmin = (Boolean) session.getAttribute("esAdmin");
            if (esAdmin == null || !esAdmin) {
                session.setAttribute("mensaje", "Acceso denegado. Solo los administradores pueden gestionar usuarios.");
                response.sendRedirect("index.jsp");
                return;
            }
            
            usuarios usuarioActual = (usuarios) session.getAttribute("user");
        %>
        
        <div class="container">
            <div class="header-box">
                <h1>Panel de Administración - Gestión de Usuarios</h1>
                <p>Acceso exclusivo para: <%= usuarioActual.getIdUsuario() %></p>
                <a href="index.jsp" class="btn btn-secondary">Volver al Menú Principal</a>
            </div>
            
            <% if (request.getAttribute("mensaje") != null) { %>
                <div class="message success">
                    <%= request.getAttribute("mensaje") %>
                </div>
            <% } %>
            
            <% if (request.getAttribute("error") != null) { %>
                <div class="message error">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>
            
            <% 
                usuarios usuarioEditar = (usuarios) request.getAttribute("usuarioEditar");
                if (usuarioEditar != null) {
            %>
            <!-- MODO EDICIÓN: Solo mostrar formulario de edición -->
            <div class="edit-form">
                <h3>Modificar Usuario: <%= usuarioEditar.getIdUsuario() %></h3>
                
                <div class="form-group">
                    <div class="password-label">Contraseña actual:</div>
                    <div class="password-display" id="currentPassword<%= usuarioEditar.getIdUsuario() %>" 
                         data-password="<%= usuarioEditar.getPassword() %>">
                        ••••••••
                    </div>
                    <span class="show-password" 
                          onclick="togglePasswordDisplay('currentPassword<%= usuarioEditar.getIdUsuario() %>')">
                         Mostrar/Ocultar contraseña actual
                    </span>
                </div>
                        
                <div class="main-content">
                    <form action="UsuariosServlet" method="post" onsubmit="enviarFormulario(this); return true;">
                        <input type="hidden" name="accion" value="modificar">
                        <input type="hidden" name="idOriginal" value="<%= usuarioEditar.getIdUsuario() %>">
                        
                        <div class="form-group">
                            <label for="txtUsuarioEdit">ID Usuario:</label>
                            <input type="text" id="txtUsuarioEdit" name="txtUsuario" class="input-id" 
                                   value="<%= usuarioEditar.getIdUsuario() %>" 
                                   required maxlength="50">
                        </div>
                        
                        <div class="form-group">
                            <label for="txtPasswordEdit">Nueva Contraseña:</label>
                            <div class="password-container">
                                <input type="password" id="txtPasswordEdit" name="txtPassword" 
                                       value="<%= usuarioEditar.getPassword() %>" required>
                                <button type="button" class="password-toggle" id="toggleBtnEdit" 
                                        onclick="togglePassword('txtPasswordEdit', 'toggleBtnEdit')" 
                                        title="Mostrar contraseña">👁️</button>
                            </div>
                            <small style="color: #666;">Puede mantener la contraseña actual o establecer una nueva</small>
                        </div>
                        
                        <div class="form-group">
                            <label for="esAdminEdit">Tipo de Usuario:</label>
                            <select id="esAdminEdit" name="esAdmin" required>
                                <option value="0" <%= usuarioEditar.getEsAdmin() == 0 ? "selected" : "" %>>Usuario Normal</option>
                                <option value="1" <%= usuarioEditar.getEsAdmin() == 1 ? "selected" : "" %>>Administrador</option>
                            </select>
                        </div>
                        
                        <div style="text-align: center; margin-top: 20px;">
                            <button type="submit" class="btn btn-warning" data-original-text="Guardar Cambios">Guardar Cambios</button>
                            <a href="UsuariosServlet?accion=listar" class="btn btn-secondary">Cancelar</a>
                        </div>
                    </form>
                </div>
            </div>
            
            <% } else { %>
            <!-- MODO NORMAL: Mostrar formulario de agregar y lista completa -->
            <div class="form-section">
                <h3>Agregar Nuevo Usuario</h3>
                <form action="UsuariosServlet" method="post" onsubmit="enviarFormulario(this); return true;">
                    <input type="hidden" name="accion" value="agregar">
                    
                    <div class="form-group">
                        <label for="txtUsuario">ID Usuario:</label>
                        <input type="text" id="txtUsuario" name="txtUsuario" required maxlength="50">
                    </div>
                    
                    <div class="form-group">
                        <label for="txtPassword">Contraseña:</label>
                        <div class="password-container">
                            <input type="password" id="txtPassword" name="txtPassword" required>
                            <button type="button" class="password-toggle" id="toggleBtn" 
                                    onclick="togglePassword('txtPassword', 'toggleBtn')" 
                                    title="Mostrar contraseña">👁️</button>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="esAdmin">Tipo de Usuario:</label>
                        <select id="esAdmin" name="esAdmin" required>
                            <option value="0" selected>Usuario Normal</option>
                            <option value="1">Administrador</option>
                        </select>
                    </div>
                    
                    <button type="submit" class="btn btn-primary" data-original-text="Agregar Usuario">Agregar Usuario</button>
                </form>
            </div>
            <% } %>
            
            <h3>Lista de Usuarios</h3>
            <% 
                List<usuarios> listaUsuarios = (List<usuarios>) request.getAttribute("usuarios");
                if (listaUsuarios != null && !listaUsuarios.isEmpty()) {
            %>
                <table>
                    <thead>
                        <tr>
                            <th>ID Usuario</th>
                            <th>Contraseña</th>
                            <th>Tipo</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (usuarios user : listaUsuarios) { 
                            boolean esUsuarioAdmin = user.getEsAdmin() == 1;
                        %>
                        <tr class="<%= esUsuarioAdmin ? "admin-user" : "" %>">
                            <td>
                                <%= user.getIdUsuario() %>
                                <%= esUsuarioAdmin ? " 👑" : "" %>
                            </td>
                            <td>
                                <span id="password<%= user.getIdUsuario() %>" 
                                      data-password="<%= user.getPassword() %>">••••••••</span>
                                <span class="show-password" 
                                      onclick="togglePasswordDisplay('password<%= user.getIdUsuario() %>')">
                                    👁️
                                </span>
                            </td>
                            <td>
                                <%= esUsuarioAdmin ? "Administrador" : "Usuario Normal" %>
                            </td>
                            <td>
                                <a href="UsuariosServlet?accion=editar&id=<%= user.getIdUsuario() %>" 
                                   class="btn btn-warning">
                                    Modificar
                                </a>
                                <% if (!esUsuarioAdmin) { %>
                                    <!-- Formulario oculto para eliminación -->
                                    <form id="eliminarForm_<%= user.getIdUsuario() %>" 
                                          action="UsuariosServlet" 
                                          method="post" 
                                          style="display: none;">
                                        <input type="hidden" name="accion" value="eliminar">
                                        <input type="hidden" name="id" value="<%= user.getIdUsuario() %>">
                                    </form>
                                    
                                    <button type="button" 
                                            class="btn btn-danger"
                                            onclick="confirmarEliminacion('<%= user.getIdUsuario() %>', <%= user.getEsAdmin() %>)">
                                        Eliminar
                                    </button>
                                <% } else { %>
                                    <span style="color: #666; font-style: italic;">Administrador</span>
                                <% } %>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } else { %>
                <div class="message">
                    No hay usuarios registrados en el sistema.
                </div>
            <% } %>
            
            <div style="margin-top: 30px; text-align: center;">
            
            </div>
        </div>
            
    </body>
</html>