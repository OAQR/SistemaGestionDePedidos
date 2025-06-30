<<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%-- 
    Document   : index
    Created on : 19/11/2021, 07:15:10 PM
    Author     : javie
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Iniciar Sesión</title>
        <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="css/login.css"/>
    </head>
    <body>
        <div class="login-container">
            <h1>Iniciar Sesión</h1>
            
            <%-- Manejo de errores por atributo (método anterior) --%>
            <% if (request.getAttribute("error") != null) { %>
                <div class="error-message">
                    ⚠️ <%= request.getAttribute("error") %>
                </div>
            <% } %>
            
            <%-- Manejo de errores por parámetro URL (método nuevo con PRG) --%>
            <% 
                String errorParam = request.getParameter("error");
                if ("1".equals(errorParam)) {
            %>
                <div class="error-message">
                    ⚠️ Usuario o contraseña incorrectos
                </div>
            <% } %>
            
            <form action="ValidarLogin" method="post">
                <div class="form-group">
                    <label for="txtUsuario">Usuario:</label>
                    <input type="text" 
                           id="txtUsuario" 
                           name="txtUsuario" 
                           placeholder="Ingrese su usuario"
                           required 
                           autofocus>
                </div>
                
                <div class="form-group">
                    <label for="txtClave">Contraseña:</label>
                    <input type="password" 
                           id="txtClave" 
                           name="txtClave" 
                           placeholder="Ingrese su contraseña"
                           required>
                </div>
                
                <button type="submit" class="btn-login">
                    Iniciar Sesión
                </button>
            </form>
            
        </div>
    </body>
</html>