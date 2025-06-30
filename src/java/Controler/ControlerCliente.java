/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Controler;
import Entidades.cliente;
import Entidades.usuarios;
import conexion.conexionBD;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "ControlerCliente", urlPatterns = {"/ControlerCliente"})
public class ControlerCliente extends HttpServlet {

@Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    HttpSession session=request.getSession();
    usuarios user=(usuarios)session.getAttribute("user");
    if(user==null){
        request.getRequestDispatcher("login.jsp").forward(request, response);
        return;
    }
    
    String Op = request.getParameter("Op");
    
    String mensaje = request.getParameter("mensaje");
    String error = request.getParameter("error");
    if(mensaje != null) {
        request.setAttribute("mensaje", mensaje);
    }
    if(error != null) {
        request.setAttribute("error", error);
    }
    
    ArrayList<cliente> Lista= new ArrayList<cliente>();
    conexionBD conBD = new conexionBD();
    Connection conn = conBD.Connected();
    PreparedStatement ps;
    ResultSet rs;
    
    switch(Op){
        case "Listar":
            try{
                String sql="SELECT * FROM t_cliente";
                ps= conn.prepareStatement(sql);
                rs= ps.executeQuery();
                while(rs.next()){
                    cliente client=new cliente();
                    client.setId(rs.getString("Id_Cliente"));
                    client.setApellidos(rs.getString("Apellidos"));
                    client.setNombres(rs.getString("Nombres"));
                    client.setDNI(rs.getString("DNI"));
                    client.setDireccion(rs.getString("Direccion"));
                    client.setTelefono(rs.getString("Telefono"));
                    client.setMovil(rs.getString("Movil"));
                    Lista.add(client);
                }
                request.setAttribute("Lista", Lista);
                request.getRequestDispatcher("listar.jsp").forward(request, response);
            }catch(SQLException ex){
                System.out.println("Error de SQL..."+ex.getMessage());
            } finally{
                conBD.Disconnect();
            }
            break;
            
        case "Consultar":
            try{
                String Id=request.getParameter("Id");
                String sql="select * from t_cliente where Id_Cliente=?";
                ps= conn.prepareStatement(sql);
                ps.setString(1, Id);
                rs= ps.executeQuery();
                cliente client=new cliente();
                while(rs.next()){
                    client.setId(rs.getString("Id_Cliente"));
                    client.setApellidos(rs.getString("Apellidos"));
                    client.setNombres(rs.getString("Nombres"));
                    client.setDNI(rs.getString("DNI"));
                    client.setDireccion(rs.getString("Direccion"));
                    client.setTelefono(rs.getString("Telefono"));
                    client.setMovil(rs.getString("Movil"));
                    Lista.add(client);
                }
                request.setAttribute("Lista", Lista);
                request.getRequestDispatcher("consultar.jsp").forward(request, response);
            }catch(SQLException ex){
                System.out.println("Error de SQL..."+ex.getMessage());
            } finally{
                conBD.Disconnect();
            }                
            break;    
            
        case "Modificar":
            try{
                String Id=request.getParameter("Id");
                String sql="select * from t_cliente where Id_Cliente=?";
                ps= conn.prepareStatement(sql);
                ps.setString(1, Id);
                rs= ps.executeQuery();
                cliente client=new cliente();
                while(rs.next()){
                    client.setId(rs.getString("Id_Cliente"));
                    client.setApellidos(rs.getString("Apellidos"));
                    client.setNombres(rs.getString("Nombres"));
                    client.setDNI(rs.getString("DNI"));
                    client.setDireccion(rs.getString("Direccion"));
                    client.setTelefono(rs.getString("Telefono"));
                    client.setMovil(rs.getString("Movil"));
                    Lista.add(client);
                }
                request.setAttribute("Lista", Lista);
                request.getRequestDispatcher("modificar.jsp").forward(request, response);
            }catch(SQLException ex){
                System.out.println("Error de SQL..."+ex.getMessage());
            } finally{
                conBD.Disconnect();
            }                 
            break;
            
        case "Eliminar":
            try{
                String Id=request.getParameter("Id");
                String sql="delete from t_cliente where Id_Cliente=?";
                ps= conn.prepareStatement(sql);
                ps.setString(1, Id);
                int resultado = ps.executeUpdate();
                
                if(resultado > 0) {
                    response.sendRedirect("ControlerCliente?Op=Listar&mensaje=eliminado");
                } else {
                    response.sendRedirect("ControlerCliente?Op=Listar&error=noeliminado");
                }
                
            }catch(SQLException ex){
                System.out.println("Error de SQL..."+ex.getMessage());
                response.sendRedirect("ControlerCliente?Op=Listar&error=sql");
            } finally{
                conBD.Disconnect();
            }                          
            break;
            
 case "Nuevo":
    request.getRequestDispatcher("nuevo.jsp").forward(request, response);
    break;
        default:
            response.sendRedirect("Clientes.jsp");
            break;
    }        
}

@Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    
    String Id = request.getParameter("Id");       
    String Apellidos = request.getParameter("apellidos"); 
    String Nombres = request.getParameter("nombres"); 
    String DNI = request.getParameter("DNI");
    String Direccion = request.getParameter("direccion"); 
    String Telefono = request.getParameter("telefono"); 
    String Movil = request.getParameter("movil"); 
    
    if(Apellidos == null || Apellidos.trim().isEmpty()) {
        response.sendRedirect("ControlerCliente?Op=Nuevo&error=apellidos_requeridos");
        return;
    }
    if(Nombres == null || Nombres.trim().isEmpty()) {
        response.sendRedirect("ControlerCliente?Op=Nuevo&error=nombres_requeridos");
        return;
    }
    if(DNI == null || DNI.trim().isEmpty()) {
        response.sendRedirect("ControlerCliente?Op=Nuevo&error=dni_requerido");
        return;
    }
    
    cliente client = new cliente();
    client.setId(Id);
    client.setApellidos(Apellidos.trim());
    client.setNombres(Nombres.trim());
    client.setDNI(DNI.trim());
    client.setDireccion(Direccion != null ? Direccion.trim() : "");
    client.setTelefono(Telefono != null ? Telefono.trim() : "");
    client.setMovil(Movil != null ? Movil.trim() : "");     
    
    conexionBD conBD = new conexionBD();
    Connection conn = conBD.Connected();
    PreparedStatement ps = null;
    ResultSet rs = null;        
    
    if(Id == null || Id.trim().isEmpty()){
        try{
            String sqlCheck = "SELECT COUNT(*) as cantidad FROM t_cliente WHERE DNI = ?";
            ps = conn.prepareStatement(sqlCheck);
            ps.setString(1, client.getDNI());
            rs = ps.executeQuery();
            
            if(rs.next() && rs.getInt("cantidad") > 0) {
                response.sendRedirect("ControlerCliente?Op=Nuevo&error=dni_existe");
                return;
            }
            
            String sql_new = "SELECT COALESCE(MAX(Id_Cliente), 'C00000') as Id_Cliente FROM t_cliente";
            ps = conn.prepareStatement(sql_new);
            rs = ps.executeQuery();
            
            String Id_Cliente = "C00001"; // Valor por defecto
            if(rs.next()){
                String maxId = rs.getString("Id_Cliente");
                Id_Cliente = newCod(maxId);
            }
            
            String sql = "INSERT INTO t_cliente(Id_Cliente, apellidos, nombres, DNI, direccion, telefono, movil) VALUES(?, ?, ?, ?, ?, ?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setString(1, Id_Cliente);
            ps.setString(2, client.getApellidos());
            ps.setString(3, client.getNombres());
            ps.setString(4, client.getDNI());
            ps.setString(5, client.getDireccion());
            ps.setString(6, client.getTelefono());
            ps.setString(7, client.getMovil());
            
            int resultado = ps.executeUpdate();
            
            if(resultado > 0) {
                response.sendRedirect("ControlerCliente?Op=Listar&mensaje=creado");
            } else {
                response.sendRedirect("ControlerCliente?Op=Nuevo&error=noguardado");
            }
            
        }catch(SQLException ex){
            System.out.println("Error insertando cliente: " + ex.getMessage());
            ex.printStackTrace(); 
            response.sendRedirect("ControlerCliente?Op=Nuevo&error=sql");
        } finally{
            try {
                if(rs != null) rs.close();
                if(ps != null) ps.close();
            } catch(SQLException e) {
                e.printStackTrace();
            }
            conBD.Disconnect();
        }               
    } else {
        try{
            String sqlCheck = "SELECT COUNT(*) as cantidad FROM t_cliente WHERE DNI = ? AND Id_Cliente != ?";
            ps = conn.prepareStatement(sqlCheck);
            ps.setString(1, client.getDNI());
            ps.setString(2, client.getId());
            rs = ps.executeQuery();
            
            if(rs.next() && rs.getInt("cantidad") > 0) {
                response.sendRedirect("ControlerCliente?Op=Modificar&Id=" + Id + "&error=dni_existe");
                return;
            }
            
            String sql = "UPDATE t_cliente SET apellidos=?, nombres=?, DNI=?, direccion=?, telefono=?, movil=? WHERE Id_Cliente=?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, client.getApellidos());
            ps.setString(2, client.getNombres());
            ps.setString(3, client.getDNI());
            ps.setString(4, client.getDireccion());
            ps.setString(5, client.getTelefono());
            ps.setString(6, client.getMovil());
            ps.setString(7, client.getId());
            
            int resultado = ps.executeUpdate();
            
            if(resultado > 0) {
                response.sendRedirect("ControlerCliente?Op=Listar&mensaje=actualizado");
            } else {
                response.sendRedirect("ControlerCliente?Op=Modificar&Id=" + Id + "&error=noactualizado");
            }
            
        }catch(SQLException ex){
            System.out.println("Error actualizando cliente: " + ex.getMessage());
            ex.printStackTrace(); 
            response.sendRedirect("ControlerCliente?Op=Modificar&Id=" + Id + "&error=sql");
        } finally{
            try {
                if(rs != null) rs.close();
                if(ps != null) ps.close();
            } catch(SQLException e) {
                e.printStackTrace();
            }
            conBD.Disconnect();
        }               
    }
}

private String newCod(String pCodigo) {
    try {
        int Numero;
        if(pCodigo == null || pCodigo.equals("C00000")) {
            return "C00001";
        }
        
        String numeroStr = pCodigo.substring(1);
        Numero = Integer.parseInt(numeroStr);
        Numero = Numero + 1;
        
        String nuevoCodigo = String.format("C%05d", Numero);
        return nuevoCodigo;
        
    } catch(Exception e) {
        System.out.println("Error generando código: " + e.getMessage());
        return "C00001"; 
    }
}
}