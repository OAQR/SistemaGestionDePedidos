/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Controler;

import Entidades.producto;
import Entidades.usuarios;
import conexion.conexionBD;
import java.io.IOException;
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

/**
 *
 * @author javie
 */
@WebServlet(name = "ControlerProducto", urlPatterns = {"/ControlerProducto"})
public class ControlerProducto extends HttpServlet {

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
    
    // NUEVO: Capturar mensajes de éxito y error
    String mensaje = request.getParameter("mensaje");
    String error = request.getParameter("error");
    
    if (mensaje != null) {
        request.setAttribute("mensaje", mensaje);
    }
    if (error != null) {
        request.setAttribute("error", error);
    }
    
    ArrayList<producto> Lista= new ArrayList<producto>();
    conexionBD conBD = new conexionBD();
    Connection conn = conBD.Connected();
    PreparedStatement ps;
    ResultSet rs;
    
    switch(Op != null ? Op : "Listar"){
        case "Listar":
            try {
                String sql = "SELECT * FROM t_producto";
                ps = conn.prepareStatement(sql);
                rs = ps.executeQuery();
                while (rs.next()) {
                    producto prod = new producto();
                    prod.setId(rs.getString("Id_prod"));
                    prod.setDescripcion(rs.getString("Descripcion"));
                    prod.setCosto(rs.getDouble("costo"));
                    prod.setPrecio(rs.getDouble("precio"));
                    prod.setCantidad(rs.getInt("cantidad"));
                    Lista.add(prod);
                }
                request.setAttribute("Lista", Lista);
                request.getRequestDispatcher("listar_productos.jsp").forward(request, response);
            } catch (SQLException ex) {
                System.out.println("Error de SQL..." + ex.getMessage());
                request.setAttribute("error", "Error al cargar la lista de productos");
                request.getRequestDispatcher("listar_productos.jsp").forward(request, response);
            } finally {
                conBD.Disconnect();
            }
            break;

        case "Consultar":
            try {
                String Id = request.getParameter("Id");
                String sql = "select * from t_producto where Id_prod=?";
                ps = conn.prepareStatement(sql);
                ps.setString(1, Id);
                rs = ps.executeQuery();

                producto prod = null;
                if (rs.next()) {
                    prod = new producto();
                    prod.setId(rs.getString("Id_prod"));
                    prod.setDescripcion(rs.getString("Descripcion"));
                    prod.setCosto(rs.getDouble("costo"));
                    prod.setPrecio(rs.getDouble("precio"));
                    prod.setCantidad(rs.getInt("cantidad"));
                }
                request.setAttribute("producto", prod);
                request.getRequestDispatcher("consultar_producto.jsp").forward(request, response);

            } catch(SQLException ex) {
                System.out.println("Error de SQL..."+ex.getMessage());
                request.setAttribute("error", "Error al consultar producto");
                request.getRequestDispatcher("consultar_producto.jsp").forward(request, response);
            } finally {
                conBD.Disconnect();
            }
            break;

        case "Modificar":
            try{
                String Id=request.getParameter("Id");
                String sql="select * from t_producto where Id_prod=?";
                ps= conn.prepareStatement(sql);
                ps.setString(1, Id);
                rs= ps.executeQuery();
                producto prod=new producto();
                while(rs.next()){
                    prod.setId(rs.getString("Id_prod"));
                    prod.setDescripcion(rs.getString("Descripcion"));
                    prod.setCosto(rs.getDouble("costo"));
                    prod.setPrecio(rs.getDouble("precio"));
                    prod.setCantidad(rs.getInt("cantidad"));
                    Lista.add(prod);
                }
                request.setAttribute("Lista", Lista);
                request.getRequestDispatcher("modificar_producto.jsp").forward(request, response);
            }catch(SQLException ex){
                System.out.println("Error de SQL..."+ex.getMessage());
                request.setAttribute("error", "Error al cargar datos para modificar");
                request.getRequestDispatcher("modificar_producto.jsp").forward(request, response);
            } finally{
                conBD.Disconnect();
            }                 
            break;
            
        case "Eliminar":
            try{
                String Id=request.getParameter("Id");
                String sql="delete from t_producto where Id_prod=?";
                ps= conn.prepareStatement(sql);
                ps.setString(1, Id);
                int filasAfectadas = ps.executeUpdate();
                
                if (filasAfectadas > 0) {
                    response.sendRedirect("ControlerProducto?Op=Listar&mensaje=Producto eliminado exitosamente");
                } else {
                    response.sendRedirect("ControlerProducto?Op=Listar&error=No se pudo eliminar el producto");
                }
                // CORREGIDO: Eliminado el 'break' después del 'return'
                return; 
                
            }catch(SQLException ex){
                System.out.println("Error de SQL..."+ex.getMessage());
                response.sendRedirect("ControlerProducto?Op=Listar&error=Error al eliminar producto");
                // CORREGIDO: Eliminado el 'break' después del 'return'
                return;
            } finally{
                conBD.Disconnect();
            }                          
            // CORREGIDO: Eliminado el 'break' aquí también ya que hay 'return' arriba
            
        case "Nuevo":
            request.getRequestDispatcher("nuevo_producto.jsp").forward(request, response);
            break;
            
        default:
            response.sendRedirect("ControlerProducto?Op=Listar");
            break;
    }        
}

@Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    String Id = request.getParameter("Id");       
    String Descripcion = request.getParameter("descripcion"); 
    String CostoStr = request.getParameter("costo"); 
    String PrecioStr = request.getParameter("precio");
    String CantidadStr = request.getParameter("cantidad"); 
    
    double Costo = 0.0;
    double Precio = 0.0;
    int Cantidad = 0;
    
    try {
        Costo = Double.parseDouble(CostoStr);
        Precio = Double.parseDouble(PrecioStr);
        Cantidad = Integer.parseInt(CantidadStr);
    } catch (NumberFormatException e) {
        System.out.println("Error parsing numeric values: " + e.getMessage());
        response.sendRedirect("ControlerProducto?Op=Listar&error=Datos numéricos inválidos");
        return;
    }
    
    producto prod = new producto();
    
    prod.setId(Id);
    prod.setDescripcion(Descripcion);
    prod.setCosto(Costo);
    prod.setPrecio(Precio);
    prod.setCantidad(Cantidad);     
    
    conexionBD conBD = new conexionBD();
    Connection conn = conBD.Connected();
    PreparedStatement ps;
    ResultSet rs;        
    
    boolean operacionExitosa = false;
    String mensaje = "";
    
    // CORRECCIÓN: Verificar si Id es null O está vacío, y manejar ambos casos
    if(Id == null || Id.trim().isEmpty()){
        // Insertar nuevo producto
        String sql_new="select max(Id_prod) Id_prod from t_producto";
        String sql="insert into t_producto(Id_prod, Descripcion, costo, precio, cantidad) values(?, ?, ?, ?, ?)";

        try{
            String Id_Producto="";
            ps= conn.prepareStatement(sql_new);
            rs= ps.executeQuery();
            while(rs.next()){
                Id_Producto=rs.getString("Id_prod");
            }
            Id_Producto=newCod(Id_Producto);
            ps= conn.prepareStatement(sql);
            ps.setString(1, Id_Producto);
            ps.setString(2, prod.getDescripcion());
            ps.setDouble(3, prod.getCosto());
            ps.setDouble(4, prod.getPrecio());
            ps.setInt(5, prod.getCantidad());
            
            ps.executeUpdate();
            operacionExitosa = true;
            mensaje = "Producto agregado exitosamente";
        }catch(SQLException ex){
            System.out.println("Error insertando producto..."+ex.getMessage());
            mensaje = "Error al agregar producto";
        } finally{
            conBD.Disconnect();
        }               
    }else{
        // Actualizar producto existente
        String sql="update t_producto set Descripcion=?, costo=?, precio=?, cantidad=? where Id_prod=?";

        try{
            ps= conn.prepareStatement(sql);
            ps.setString(1, prod.getDescripcion());
            ps.setDouble(2, prod.getCosto());
            ps.setDouble(3, prod.getPrecio());
            ps.setInt(4, prod.getCantidad());
            ps.setString(5, prod.getId());
            
            int filasAfectadas = ps.executeUpdate();
            
            if(filasAfectadas > 0) {
                operacionExitosa = true;
                mensaje = "Producto modificado exitosamente";
            } else {
                mensaje = "No se encontró el producto para modificar";
            }
            
        }catch(SQLException ex){
            System.out.println("Error actualizando producto..."+ex.getMessage());
            mensaje = "Error al modificar producto: " + ex.getMessage();
        } finally{
            conBD.Disconnect();
        }               
    }
    
    if (operacionExitosa) {
        response.sendRedirect("ControlerProducto?Op=Listar&mensaje=" + java.net.URLEncoder.encode(mensaje, "UTF-8"));
    } else {
        response.sendRedirect("ControlerProducto?Op=Listar&error=" + java.net.URLEncoder.encode(mensaje, "UTF-8"));
    }
}

    @Override
    public String getServletInfo() {
        return "Short description";
    }
    
    private String newCod(java.lang.String pCodigo) {
        int Numero;
        if(pCodigo == null) {
            return "P00001";
        }
        Numero=Integer.parseInt(pCodigo.substring(1));
        Numero=Numero+1;
        pCodigo=String.valueOf(Numero);
        while (pCodigo.length()<5){
            pCodigo='0'+ pCodigo;
        }
        pCodigo='P'+pCodigo;        
        return (pCodigo);
    }
}