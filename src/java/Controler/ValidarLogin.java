/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Controler;
import Entidades.usuarios;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "ValidarLogin", urlPatterns = {"/ValidarLogin"})
public class ValidarLogin extends HttpServlet {
    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        
        String user = request.getParameter("txtUsuario");
        String pass = request.getParameter("txtClave");
        
        UsuariosDAO usuariosDAO = new UsuariosDAO();
        usuarios usuarioValidado = usuariosDAO.validarLogin(user, pass);
        
        if (usuarioValidado != null) {
            HttpSession session = request.getSession();
            session.setAttribute("user", usuarioValidado);
            
            // Usar el campo esAdmin de la base de datos en lugar de verificar el nombre
            boolean esAdmin = usuarioValidado.isAdmin(); // usa el método isAdmin() que verifica si esAdmin == 1
            session.setAttribute("esAdmin", esAdmin);
            
            // CAMBIO: Usar redirect en lugar de forward después de POST exitoso
            response.sendRedirect("index.jsp");
        } else {
            // CAMBIO: Usar redirect con parámetro de error
            response.sendRedirect("login.jsp?error=1");
        }
        
        usuariosDAO.cerrarConexion();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Solo permitir GET para mostrar formularios, no para procesar
        response.sendRedirect("login.jsp");
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }
}