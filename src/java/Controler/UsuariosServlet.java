/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Controler;

import Entidades.usuarios;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "UsuariosServlet", urlPatterns = {"/UsuariosServlet"})
public class UsuariosServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        
        // Agregar headers para prevenir caché en todas las respuestas
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
        
        String accion = request.getParameter("accion");
        
        // Separar operaciones GET (mostrar) de POST (procesar)
        if ("GET".equals(request.getMethod())) {
            handleGetRequest(request, response, accion);
        } else {
            handlePostRequest(request, response, accion);
        }
    }
    
    private void handleGetRequest(HttpServletRequest request, HttpServletResponse response, String accion)
            throws ServletException, IOException {

        UsuariosDAO usuariosDAO = new UsuariosDAO();

        try {
            if (accion == null || accion.trim().isEmpty()) {
                accion = "listar";
            }

            switch (accion) {
                case "listar":
                    listarUsuarios(request, response, usuariosDAO);
                    break;

                case "editar":
                    mostrarFormularioEdicion(request, response, usuariosDAO);
                    break;

                default:
                    listarUsuarios(request, response, usuariosDAO);
                    break;
            }
        } finally {
            usuariosDAO.cerrarConexion();
        }
    }

    private void handlePostRequest(HttpServletRequest request, HttpServletResponse response, String accion)
            throws ServletException, IOException {
        
        UsuariosDAO usuariosDAO = new UsuariosDAO();
        HttpSession session = request.getSession();
        
        try {
            switch (accion) {
                case "agregar":
                    agregarUsuario(request, response, usuariosDAO, session);
                    break;
                    
                case "eliminar":
                    eliminarUsuario(request, response, usuariosDAO, session);
                    break;
                    
                case "modificar":
                    modificarUsuario(request, response, usuariosDAO, session);
                    break;
                    
                default:
                    response.sendRedirect("UsuariosServlet?accion=listar");
                    break;
            }
        } finally {
            usuariosDAO.cerrarConexion();
        }
    }
    
    private void listarUsuarios(HttpServletRequest request, HttpServletResponse response, UsuariosDAO usuariosDAO)
            throws ServletException, IOException {
        
        List<usuarios> listaUsuarios = usuariosDAO.listarUsuarios();
        request.setAttribute("usuarios", listaUsuarios);
        
        // Verificar si hay mensajes en la URL
        String mensaje = request.getParameter("mensaje");
        String error = request.getParameter("error");
        
        if (mensaje != null) {
            request.setAttribute("mensaje", mensaje);
        }
        if (error != null) {
            request.setAttribute("error", error);
        }
        
        request.getRequestDispatcher("usuarios.jsp").forward(request, response);
    }
    
    private void agregarUsuario(HttpServletRequest request, HttpServletResponse response, 
                               UsuariosDAO usuariosDAO, HttpSession session)
            throws ServletException, IOException {
        
        String idUsuario = request.getParameter("txtUsuario");
        String password = request.getParameter("txtPassword");
        String esAdminStr = request.getParameter("esAdmin");
        
        if (idUsuario != null && !idUsuario.trim().isEmpty() && 
            password != null && !password.trim().isEmpty()) {
            
            usuarios nuevoUsuario = new usuarios();
            nuevoUsuario.setIdUsuario(idUsuario.trim());
            nuevoUsuario.setPassword(password.trim());
            
            // Establecer si es admin (0 por defecto, 1 si se marca como admin)
            int esAdmin = 0;
            if (esAdminStr != null && "1".equals(esAdminStr)) {
                esAdmin = 1;
            }
            nuevoUsuario.setEsAdmin(esAdmin);
            
            boolean resultado = usuariosDAO.agregarUsuario(nuevoUsuario);
            
            if (resultado) {
                // CRÍTICO: Usar sendRedirect para evitar reenvío del formulario
                response.sendRedirect("UsuariosServlet?accion=listar&mensaje=Usuario agregado exitosamente&_t=" + System.currentTimeMillis());
            } else {
                response.sendRedirect("UsuariosServlet?accion=listar&error=Error al agregar usuario&_t=" + System.currentTimeMillis());
            }
        } else {
            response.sendRedirect("UsuariosServlet?accion=listar&error=Todos los campos son obligatorios&_t=" + System.currentTimeMillis());
        }
    }
    
    private void eliminarUsuario(HttpServletRequest request, HttpServletResponse response, 
                                UsuariosDAO usuariosDAO, HttpSession session)
            throws ServletException, IOException {
        
        String idUsuario = request.getParameter("id");
        
        if (idUsuario != null && !idUsuario.trim().isEmpty()) {
            // Verificar si el usuario a eliminar es administrador
            usuarios usuarioAEliminar = usuariosDAO.obtenerUsuario(idUsuario);
            
            if (usuarioAEliminar != null && usuarioAEliminar.isAdmin()) {
                // Contar cuántos administradores hay en total
                List<usuarios> todosUsuarios = usuariosDAO.listarUsuarios();
                long cantidadAdmins = todosUsuarios.stream()
                    .filter(u -> u.isAdmin())
                    .count();
                
                if (cantidadAdmins <= 1) {
                    response.sendRedirect("UsuariosServlet?accion=listar&error=No se puede eliminar el último administrador del sistema&_t=" + System.currentTimeMillis());
                    return;
                }
            }
            
            boolean resultado = usuariosDAO.eliminarUsuario(idUsuario);
            
            if (resultado) {
                response.sendRedirect("UsuariosServlet?accion=listar&mensaje=Usuario eliminado exitosamente&_t=" + System.currentTimeMillis());
            } else {
                response.sendRedirect("UsuariosServlet?accion=listar&error=Error al eliminar usuario&_t=" + System.currentTimeMillis());
            }
        } else {
            response.sendRedirect("UsuariosServlet?accion=listar&error=ID de usuario no válido&_t=" + System.currentTimeMillis());
        }
    }
    
    private void mostrarFormularioEdicion(HttpServletRequest request, HttpServletResponse response, UsuariosDAO usuariosDAO)
            throws ServletException, IOException {
        
        String idUsuario = request.getParameter("id");
        
        if (idUsuario != null && !idUsuario.trim().isEmpty()) {
            usuarios usuario = usuariosDAO.obtenerUsuario(idUsuario);
            
            if (usuario != null) {
                request.setAttribute("usuarioEditar", usuario);
                List<usuarios> listaUsuarios = usuariosDAO.listarUsuarios();
                request.setAttribute("usuarios", listaUsuarios);
                request.getRequestDispatcher("usuarios.jsp").forward(request, response);
            } else {
                response.sendRedirect("UsuariosServlet?accion=listar&error=Usuario no encontrado&_t=" + System.currentTimeMillis());
            }
        } else {
            response.sendRedirect("UsuariosServlet?accion=listar&error=ID de usuario no válido&_t=" + System.currentTimeMillis());
        }
    }
    
    private void modificarUsuario(HttpServletRequest request, HttpServletResponse response, 
                                 UsuariosDAO usuariosDAO, HttpSession session)
            throws ServletException, IOException {
        
        String idUsuarioOriginal = request.getParameter("idOriginal");
        String nuevoIdUsuario = request.getParameter("txtUsuario");
        String nuevaPassword = request.getParameter("txtPassword");
        String esAdminStr = request.getParameter("esAdmin");
        
        if (idUsuarioOriginal != null && !idUsuarioOriginal.trim().isEmpty() &&
            nuevoIdUsuario != null && !nuevoIdUsuario.trim().isEmpty() &&
            nuevaPassword != null && !nuevaPassword.trim().isEmpty()) {
            
            // Obtener el usuario original para verificar si es admin
            usuarios usuarioOriginal = usuariosDAO.obtenerUsuario(idUsuarioOriginal);
            
            // Establecer si es admin
            int esAdmin = 0;
            if (esAdminStr != null && "1".equals(esAdminStr)) {
                esAdmin = 1;
            }
            
            // Verificar si estamos quitando privilegios de admin al último administrador
            if (usuarioOriginal != null && usuarioOriginal.isAdmin() && esAdmin == 0) {
                List<usuarios> todosUsuarios = usuariosDAO.listarUsuarios();
                long cantidadAdmins = todosUsuarios.stream()
                    .filter(u -> u.isAdmin())
                    .count();
                
                if (cantidadAdmins <= 1) {
                    response.sendRedirect("UsuariosServlet?accion=listar&error=No se pueden quitar privilegios de administrador al último admin del sistema&_t=" + System.currentTimeMillis());
                    return;
                }
            }
            
            if (!idUsuarioOriginal.equals(nuevoIdUsuario) && 
                usuariosDAO.existeUsuario(nuevoIdUsuario, idUsuarioOriginal)) {
                response.sendRedirect("UsuariosServlet?accion=listar&error=El nuevo ID de usuario ya existe&_t=" + System.currentTimeMillis());
            } else {
                usuarios usuarioModificado = new usuarios();
                usuarioModificado.setIdUsuario(nuevoIdUsuario.trim());
                usuarioModificado.setPassword(nuevaPassword.trim());
                usuarioModificado.setEsAdmin(esAdmin);
                
                boolean resultado = usuariosDAO.modificarUsuario(idUsuarioOriginal, usuarioModificado);
                
                if (resultado) {
                    // Actualizar sesión si el usuario modificado es el actual
                    usuarios usuarioSesion = (usuarios) session.getAttribute("user");
                    if (usuarioSesion != null && usuarioSesion.getIdUsuario().equals(idUsuarioOriginal)) {
                        usuarioSesion.setIdUsuario(nuevoIdUsuario);
                        usuarioSesion.setPassword(nuevaPassword);
                        usuarioSesion.setEsAdmin(esAdmin);
                        session.setAttribute("user", usuarioSesion);
                        session.setAttribute("esAdmin", esAdmin == 1);
                    }
                    
                    response.sendRedirect("UsuariosServlet?accion=listar&mensaje=Usuario modificado exitosamente&_t=" + System.currentTimeMillis());
                } else {
                    response.sendRedirect("UsuariosServlet?accion=listar&error=Error al modificar usuario&_t=" + System.currentTimeMillis());
                }
            }
        } else {
            response.sendRedirect("UsuariosServlet?accion=listar&error=Todos los campos son obligatorios&_t=" + System.currentTimeMillis());
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }
}