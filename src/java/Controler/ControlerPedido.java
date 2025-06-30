/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Controler;

import Entidades.detallePedido;
import Entidades.pedido;
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

@WebServlet(name = "ControlerPedido", urlPatterns = {"/ControlerPedido"})
public class ControlerPedido extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ControlerPedido</title>");            
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ControlerPedido at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String Op = request.getParameter("Op");
        ArrayList<pedido> Lista = new ArrayList<pedido>();
        ArrayList<detallePedido> ListaDet = new ArrayList<detallePedido>();
        conexionBD conBD = new conexionBD();
        Connection conn = conBD.Connected();
        PreparedStatement ps;
        ResultSet rs;
        
        switch(Op){
            case "Listar":
                try{
                    // SQL actualizado con los nuevos campos
                    String sql = "SELECT Id_Pedido, A.Id_Cliente, B.Apellidos, B.Nombres, A.Fecha, " +
                               "A.SubTotal, A.TotalVenta, A.Estado, A.FechaEntrega, A.Observaciones, " +
                               "A.DireccionEntrega, A.TelefonoContacto " +
                               "FROM t_pedido A INNER JOIN t_cliente B ON A.Id_Cliente=B.Id_Cliente " +
                               "ORDER BY A.Id_Pedido DESC";
                    
                    ps = conn.prepareStatement(sql);
                    rs = ps.executeQuery();
                    
                    while(rs.next()){
                        pedido Pedido = new pedido();
                        Pedido.setId_Pedido(rs.getString(1));
                        Pedido.setId_Cliente(rs.getString(2));
                        Pedido.setApellidos(rs.getString(3));
                        Pedido.setNombres(rs.getString(4));
                        Pedido.setFecha(rs.getDate(5));
                        Pedido.setSubTotal(rs.getDouble(6));
                        Pedido.setTotalVenta(rs.getDouble(7));
                        // Nuevos campos
                        Pedido.setEstado(rs.getString(8));
                        Pedido.setFechaEntrega(rs.getDate(9));
                        Pedido.setObservaciones(rs.getString(10));
                        Pedido.setDireccionEntrega(rs.getString(11));
                        Pedido.setTelefonoContacto(rs.getString(12));
                        
                        Lista.add(Pedido);
                    }
                    request.setAttribute("Lista", Lista);
                    request.getRequestDispatcher("listarPedido.jsp").forward(request, response);
                    
                }catch(SQLException ex){
                    System.out.println("Error de SQL al listar pedidos..."+ex.getMessage());
                }finally{
                    conBD.Disconnect();
                }
                break;
                
        case "Consultar":
    try{
        String Id = request.getParameter("Id");
        
        // 1. PRIMERO: Obtener información completa del pedido CON TODOS LOS DATOS DEL CLIENTE
        String sqlPedido = "SELECT P.Id_Pedido, P.Id_Cliente, C.Apellidos, C.Nombres, P.Fecha, " +
                          "P.SubTotal, P.TotalVenta, P.Estado, P.FechaEntrega, P.Observaciones, " +
                          "P.DireccionEntrega, P.TelefonoContacto, P.CantLineas, " +
                          "C.DNI, C.Direccion, C.Telefono, C.Movil " +  // AGREGAMOS MÁS CAMPOS DEL CLIENTE
                          "FROM t_pedido P INNER JOIN t_cliente C ON P.Id_Cliente = C.Id_Cliente " +
                          "WHERE P.Id_Pedido = ?";
        
        ps = conn.prepareStatement(sqlPedido);
        ps.setString(1, Id);
        rs = ps.executeQuery();
        
        pedido Pedido = null;
        if(rs.next()){
            Pedido = new pedido();
            Pedido.setId_Pedido(rs.getString("Id_Pedido"));
            Pedido.setId_Cliente(rs.getString("Id_Cliente"));
            Pedido.setApellidos(rs.getString("Apellidos"));
            Pedido.setNombres(rs.getString("Nombres"));
            Pedido.setFecha(rs.getDate("Fecha"));
            Pedido.setSubTotal(rs.getDouble("SubTotal"));
            Pedido.setTotalVenta(rs.getDouble("TotalVenta"));
            Pedido.setEstado(rs.getString("Estado"));
            Pedido.setFechaEntrega(rs.getDate("FechaEntrega"));
            Pedido.setObservaciones(rs.getString("Observaciones"));
            
            // PRIORIDAD: Si DireccionEntrega está vacía, usar la dirección del cliente
            String direccionEntrega = rs.getString("DireccionEntrega");
            if (direccionEntrega == null || direccionEntrega.trim().isEmpty()) {
                direccionEntrega = rs.getString("Direccion"); // Dirección del cliente
            }
            Pedido.setDireccionEntrega(direccionEntrega);
            
            // PRIORIDAD: Si TelefonoContacto está vacío, usar teléfono del cliente
            String telefonoContacto = rs.getString("TelefonoContacto");
            if (telefonoContacto == null || telefonoContacto.trim().isEmpty()) {
                String telefonoCliente = rs.getString("Telefono");
                String movilCliente = rs.getString("Movil");
                
                // Usar móvil si existe, sino teléfono fijo
                if (movilCliente != null && !movilCliente.trim().isEmpty()) {
                    telefonoContacto = movilCliente;
                } else if (telefonoCliente != null && !telefonoCliente.trim().isEmpty()) {
                    telefonoContacto = telefonoCliente;
                }
            }
            Pedido.setTelefonoContacto(telefonoContacto);
            
            // Debug: Imprimir información para verificar
            System.out.println("=== DEBUG CONSULTA PEDIDO ===");
            System.out.println("ID Pedido: " + Pedido.getId_Pedido());
            System.out.println("ID Cliente: " + Pedido.getId_Cliente());
            System.out.println("Cliente: " + Pedido.getNombres() + " " + Pedido.getApellidos());
            System.out.println("Dirección Entrega: " + Pedido.getDireccionEntrega());
            System.out.println("Teléfono Contacto: " + Pedido.getTelefonoContacto());
            System.out.println("Estado: " + Pedido.getEstado());
            System.out.println("================================");
        } else {
            System.out.println("ERROR: No se encontró el pedido con ID: " + Id);
        }
        
        // 2. SEGUNDO: Obtener detalles de productos del pedido
        String sqlDetalle = "SELECT D.Id_Pedido, D.Id_Prod, P.Descripcion, D.Cantidad, D.Precio, D.TotalDeta " +
                           "FROM t_detalle_pedido D INNER JOIN t_producto P ON D.Id_Prod = P.Id_Prod " +
                           "WHERE D.Id_Pedido = ? ORDER BY P.Descripcion";
        
        ps = conn.prepareStatement(sqlDetalle);
        ps.setString(1, Id);
        rs = ps.executeQuery();
        
        while(rs.next()){
            detallePedido DetaPed = new detallePedido();
            DetaPed.setId_Pedido(rs.getString("Id_Pedido"));
            DetaPed.setId_Prod(rs.getString("Id_Prod"));
            DetaPed.setDescripcion(rs.getString("Descripcion"));
            DetaPed.setCantidad(rs.getDouble("Cantidad"));
            DetaPed.setPrecio(rs.getDouble("Precio"));
            DetaPed.setTotalDeta(rs.getDouble("TotalDeta"));
            ListaDet.add(DetaPed);
        }
        
        System.out.println("Cantidad de productos encontrados: " + ListaDet.size());
        
        // 3. Enviar ambos objetos al JSP
        request.setAttribute("Pedido", Pedido);  // INFORMACIÓN DEL PEDIDO
        request.setAttribute("Lista", ListaDet);  // DETALLES DE PRODUCTOS
        request.getRequestDispatcher("consultarPedido.jsp").forward(request, response);
        
    }catch(SQLException ex){
        System.out.println("Error de SQL al consultar pedido..."+ex.getMessage());
        ex.printStackTrace();
        response.sendRedirect("ControlerPedido?Op=Listar&error=consultar");
    } finally{
        conBD.Disconnect();
    }                
    break;
                
            case "Eliminar":
                try{
                    String Id = request.getParameter("Id");
                    // Cambiar estado en lugar de eliminar físicamente
                    String sql = "UPDATE t_pedido SET Estado='Anulado' WHERE Id_Pedido=?";
                    ps = conn.prepareStatement(sql);
                    ps.setString(1, Id);
                    int resultado = ps.executeUpdate();
                    
                    if(resultado > 0){
                        response.sendRedirect("ControlerPedido?Op=Listar&mensaje=anulado");
                    } else {
                        response.sendRedirect("ControlerPedido?Op=Listar&error=anular");
                    }
                    
                }catch(SQLException ex){
                    System.out.println("Error de SQL al anular pedido..."+ex.getMessage());
                    response.sendRedirect("ControlerPedido?Op=Listar&error=sql");
                }finally{
                    conBD.Disconnect();
                }
                break;
                
            case "Modificar":
    try{
        String Id = request.getParameter("Id");
        
        // 1. Obtener información del pedido
        String sqlPedido = "SELECT P.*, C.Nombres, C.Apellidos FROM t_pedido P " +
                          "INNER JOIN t_cliente C ON P.Id_Cliente = C.Id_Cliente " +
                          "WHERE P.Id_Pedido = ?";
        
        ps = conn.prepareStatement(sqlPedido);
        ps.setString(1, Id);
        rs = ps.executeQuery();
        
        if(rs.next()){
            pedido Pedido = new pedido();
            Pedido.setId_Pedido(rs.getString("Id_Pedido"));
            Pedido.setId_Cliente(rs.getString("Id_Cliente"));
            Pedido.setNombres(rs.getString("Nombres"));
            Pedido.setApellidos(rs.getString("Apellidos"));
            Pedido.setFecha(rs.getDate("Fecha"));
            Pedido.setSubTotal(rs.getDouble("SubTotal"));
            Pedido.setTotalVenta(rs.getDouble("TotalVenta"));
            Pedido.setEstado(rs.getString("Estado"));
            Pedido.setFechaEntrega(rs.getDate("FechaEntrega"));
            Pedido.setObservaciones(rs.getString("Observaciones"));
            Pedido.setDireccionEntrega(rs.getString("DireccionEntrega"));
            Pedido.setTelefonoContacto(rs.getString("TelefonoContacto"));
            
            request.setAttribute("Pedido", Pedido);
            
            // 2. Obtener detalles de productos del pedido
            String sqlDetalle = "SELECT D.Id_Pedido, D.Id_Prod, P.Descripcion, D.Cantidad, D.Precio, D.TotalDeta " +
                               "FROM t_detalle_pedido D INNER JOIN t_producto P ON D.Id_Prod = P.Id_Prod " +
                               "WHERE D.Id_Pedido = ? ORDER BY P.Descripcion";
            
            PreparedStatement psDetalle = conn.prepareStatement(sqlDetalle);
            psDetalle.setString(1, Id);
            ResultSet rsDetalle = psDetalle.executeQuery();
            
            ArrayList<detallePedido> ListaDetalle = new ArrayList<detallePedido>();
            while(rsDetalle.next()){
                detallePedido DetaPed = new detallePedido();
                DetaPed.setId_Pedido(rsDetalle.getString("Id_Pedido"));
                DetaPed.setId_Prod(rsDetalle.getString("Id_Prod"));
                DetaPed.setDescripcion(rsDetalle.getString("Descripcion"));
                DetaPed.setCantidad(rsDetalle.getDouble("Cantidad"));
                DetaPed.setPrecio(rsDetalle.getDouble("Precio"));
                DetaPed.setTotalDeta(rsDetalle.getDouble("TotalDeta"));
                ListaDetalle.add(DetaPed);
            }
            
            request.setAttribute("ListaDetalle", ListaDetalle);
            rsDetalle.close();
            psDetalle.close();
            
            request.getRequestDispatcher("modificarPedido.jsp").forward(request, response);
        } else {
            response.sendRedirect("ControlerPedido?Op=Listar&error=noencontrado");
        }
        
    }catch(SQLException ex){
        System.out.println("Error de SQL al cargar pedido para modificar..."+ex.getMessage());
        ex.printStackTrace();
        response.sendRedirect("ControlerPedido?Op=Listar&error=sql");
    }finally{
        conBD.Disconnect();
    }
    break;
    
case "BuscarCliente":
    try{
        String idCliente = request.getParameter("idCliente");
        System.out.println("Buscando cliente con ID: " + idCliente); // Debug
        
        String sql = "SELECT * FROM t_cliente WHERE Id_Cliente = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, idCliente);
        rs = ps.executeQuery();
        
        if(rs.next()) {
            // Crear array con datos del cliente, manejando nulls correctamente
            String[] cliente = new String[7];
            cliente[0] = rs.getString("Id_Cliente") != null ? rs.getString("Id_Cliente") : "";
            cliente[1] = rs.getString("Apellidos") != null ? rs.getString("Apellidos") : "";
            cliente[2] = rs.getString("Nombres") != null ? rs.getString("Nombres") : "";  
            cliente[3] = rs.getString("Direccion") != null ? rs.getString("Direccion") : "";
            cliente[4] = rs.getString("DNI") != null ? rs.getString("DNI") : "";
            cliente[5] = rs.getString("Telefono") != null ? rs.getString("Telefono") : "";
            cliente[6] = rs.getString("Movil") != null ? rs.getString("Movil") : "";
            
            // Debug: imprimir información del cliente encontrado
            System.out.println("Cliente encontrado: " + cliente[1] + ", " + cliente[2]);
            
            request.setAttribute("ClienteEncontrado", cliente);
            
            // NUEVO: Generar el próximo ID de pedido
            String proximoPedidoId = generarProximoIdPedido(conn);
            request.setAttribute("NuevoPedidoId", proximoPedidoId);
            
        } else {
            System.out.println("Cliente no encontrado con ID: " + idCliente); // Debug
            request.setAttribute("ErrorCliente", "Cliente no encontrado con ID: " + idCliente);
        }
        
    }catch(SQLException ex){
        System.out.println("Error buscando cliente: " + ex.getMessage());
        ex.printStackTrace(); // Para ver el stack trace completo
        request.setAttribute("ErrorCliente", "Error en la búsqueda del cliente: " + ex.getMessage());
    }
    
    // Cargar productos también
    try{
        ArrayList<String[]> productos = new ArrayList<>();
        String sqlProductos = "SELECT Id_Prod, Descripcion, Precio, Cantidad FROM t_producto WHERE Cantidad > 0 ORDER BY Descripcion";
        ps = conn.prepareStatement(sqlProductos);
        rs = ps.executeQuery();
        
        while(rs.next()) {
            String[] producto = new String[4];
            producto[0] = rs.getString("Id_Prod");
            producto[1] = rs.getString("Descripcion");
            producto[2] = String.valueOf(rs.getDouble("Precio"));
            producto[3] = String.valueOf(rs.getInt("Cantidad"));
            productos.add(producto);
        }
        request.setAttribute("Productos", productos);
        
    }catch(SQLException ex){
        System.out.println("Error cargando productos: " + ex.getMessage());
        request.setAttribute("ErrorProductos", "Error al cargar productos");
    }finally{
        conBD.Disconnect();
    }
    
    request.getRequestDispatcher("nuevoPedido.jsp").forward(request, response);
    break;
       
case "Nuevo":
    try{
        // Cargar lista de productos disponibles
        ArrayList<String[]> productos = new ArrayList<>();
        String sqlProductos = "SELECT Id_Prod, Descripcion, Precio, Cantidad FROM t_producto WHERE Cantidad > 0 ORDER BY Descripcion";
        ps = conn.prepareStatement(sqlProductos);
        rs = ps.executeQuery();
        
        while(rs.next()) {
            String[] producto = new String[4];
            producto[0] = rs.getString("Id_Prod");
            producto[1] = rs.getString("Descripcion");
            producto[2] = String.valueOf(rs.getDouble("Precio"));
            producto[3] = String.valueOf(rs.getInt("Cantidad"));
            productos.add(producto);
        }
        request.setAttribute("Productos", productos);
        
    }catch(SQLException ex){
        System.out.println("Error cargando productos: " + ex.getMessage());
        request.setAttribute("ErrorProductos", "Error al cargar productos");
    }finally{
        conBD.Disconnect();
    }
    request.getRequestDispatcher("nuevoPedido.jsp").forward(request, response);
    break;
        }}
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String Op = request.getParameter("Op");
        conexionBD conBD = new conexionBD();
        Connection conn = conBD.Connected();
        PreparedStatement ps;
        
        switch(Op){
            case "Actualizar":
    try{
        String idPedido = request.getParameter("Id_Pedido");
        
        // 1. Actualizar información básica del pedido
        String sqlPedido = "UPDATE t_pedido SET Estado=?, FechaEntrega=?, " +
                          "DireccionEntrega=?, TelefonoContacto=? WHERE Id_Pedido=?";
        
        ps = conn.prepareStatement(sqlPedido);
        ps.setString(1, request.getParameter("Estado"));
        
        // Manejar la fecha de entrega de forma segura
        String fechaEntregaStr = request.getParameter("FechaEntrega");
        if (fechaEntregaStr != null && !fechaEntregaStr.trim().isEmpty()) {
            try {
                ps.setDate(2, java.sql.Date.valueOf(fechaEntregaStr));
            } catch (IllegalArgumentException e) {
                System.out.println("Formato de fecha inválido: " + fechaEntregaStr);
                ps.setDate(2, null);
            }
        } else {
            ps.setDate(2, null);
        }
        
        ps.setString(3, request.getParameter("DireccionEntrega"));
        ps.setString(4, request.getParameter("TelefonoContacto"));
        ps.setString(5, idPedido);
        
        int resultadoPedido = ps.executeUpdate();
        
        if(resultadoPedido > 0){
            // 2. Actualizar cantidades de productos en el detalle
            actualizarDetallesPedido(conn, idPedido, request);
            
            // 3. Recalcular totales del pedido
            recalcularTotalesPedido(conn, idPedido);
            
            response.sendRedirect("ControlerPedido?Op=Listar&mensaje=actualizado");
        } else {
            response.sendRedirect("ControlerPedido?Op=Listar&error=actualizar");
        }
        
    }catch(SQLException ex){
        System.out.println("Error de SQL al actualizar pedido..."+ex.getMessage());
        ex.printStackTrace();
        response.sendRedirect("ControlerPedido?Op=Listar&error=sql");
    }finally{
        conBD.Disconnect();
    }
    break;
                
case "Crear":
    try{
        String idPedido = generarIdPedido(conn);
        
        // NUEVO: Obtener cantidad de líneas
        String cantLineasStr = request.getParameter("CantLineas");
        int cantLineas = 0;
        if (cantLineasStr != null && !cantLineasStr.trim().isEmpty()) {
            try {
                cantLineas = Integer.parseInt(cantLineasStr);
            } catch (NumberFormatException e) {
                System.out.println("Error al parsear CantLineas: " + cantLineasStr);
            }
        }
        
        // MODIFICADO: SQL actualizado con CantLineas
        String sql = "INSERT INTO t_pedido (Id_Pedido, Id_Cliente, Fecha, SubTotal, TotalVenta, " +
                   "Estado, FechaEntrega, Observaciones, DireccionEntrega, TelefonoContacto, CantLineas) " +
                   "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        ps = conn.prepareStatement(sql);
        ps.setString(1, idPedido);
        ps.setString(2, request.getParameter("Id_Cliente"));
        
        // Usar fecha actual automáticamente
        ps.setDate(3, new java.sql.Date(System.currentTimeMillis()));
        
        ps.setDouble(4, Double.parseDouble(request.getParameter("SubTotal")));
        ps.setDouble(5, Double.parseDouble(request.getParameter("TotalVenta")));
        
        // MODIFICADO: Estado inicial "Aceptado" en lugar de "Pendiente"
        ps.setString(6, "Aceptado"); // Cambiado de "Pendiente" a "Aceptado"
        
        String fechaEntregaStr = request.getParameter("FechaEntrega");
        if (fechaEntregaStr != null && !fechaEntregaStr.trim().isEmpty()) {
            try {
                ps.setDate(7, java.sql.Date.valueOf(fechaEntregaStr));
            } catch (IllegalArgumentException e) {
                System.out.println("Formato de fecha inválido: " + fechaEntregaStr);
                ps.setDate(7, null);
            }
        } else {
            ps.setDate(7, null);
        }
        
        ps.setString(8, request.getParameter("Observaciones"));
        ps.setString(9, request.getParameter("DireccionEntrega"));
        ps.setString(10, request.getParameter("TelefonoContacto"));
        
        // NUEVO: Establecer cantidad de líneas
        ps.setInt(11, cantLineas);
        
        int resultado = ps.executeUpdate();
        
        if (resultado > 0) {
            // Insertar detalles del pedido
            insertarDetallesPedido(conn, idPedido, request);
            
            // NUEVO: Mensaje de éxito con información adicional
            System.out.println("Pedido creado exitosamente:");
            System.out.println("- ID: " + idPedido);
            System.out.println("- Cliente: " + request.getParameter("Id_Cliente"));
            System.out.println("- Cantidad de líneas: " + cantLineas);
            System.out.println("- Total: " + request.getParameter("TotalVenta"));
            System.out.println("- Estado: Aceptado");
            
            response.sendRedirect("ControlerPedido?Op=Listar&mensaje=creado&id=" + idPedido);
        } else {
            response.sendRedirect("ControlerPedido?Op=Nuevo&error=crear");
        }
        
    }catch(SQLException | NumberFormatException ex){
        System.out.println("Error creando pedido: " + ex.getMessage());
        ex.printStackTrace(); // Para debug completo
        response.sendRedirect("ControlerPedido?Op=Nuevo&error=sql");
    }finally{
        conBD.Disconnect();
    }
    break;
                
            default:
                response.sendRedirect("ControlerPedido?Op=Listar");
                break;
        }
    }
    
    /**
     * Método auxiliar para generar ID único del pedido
     * @param conn Conexión a la base de datos
     * @return String con el ID generado
     */
    private String generarProximoIdPedido(Connection conn) {
    String proximoId = "P0001";
    try {
        // Buscar el último número de pedido válido
        String sql = "SELECT Id_Pedido FROM t_pedido WHERE Id_Pedido REGEXP '^P[0-9]{4}$' ORDER BY CAST(SUBSTRING(Id_Pedido, 2) AS UNSIGNED) DESC LIMIT 1";
        PreparedStatement ps = conn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            String ultimoId = rs.getString("Id_Pedido");
            // Extraer el número (sin la P)
            String numeroStr = ultimoId.substring(1);
            int ultimoNumero = Integer.parseInt(numeroStr);
            
            // Generar el siguiente número
            int siguienteNumero = ultimoNumero + 1;
            proximoId = String.format("P%04d", siguienteNumero);
        }
        
        rs.close();
        ps.close();
        
        System.out.println("Próximo ID de pedido generado: " + proximoId);
        
    } catch (SQLException | NumberFormatException e) {
        System.out.println("Error generando próximo ID: " + e.getMessage());
        // En caso de error, usar un timestamp para garantizar unicidad
        long timestamp = System.currentTimeMillis();
        proximoId = "P" + String.format("%04d", (int)(timestamp % 10000));
    }
    return proximoId;
}

/**
 * Método auxiliar para generar ID único del pedido (usado al crear)
 * @param conn Conexión a la base de datos
 * @return String con el ID generado
 */
private String generarIdPedido(Connection conn) {
    return generarProximoIdPedido(conn); // Reutilizar la misma lógica
}
private void actualizarDetallesPedido(Connection conn, String idPedido, HttpServletRequest request) throws SQLException {
    // Obtener todos los parámetros que empiecen con "cantidad_"
    java.util.Map<String, String[]> parametros = request.getParameterMap();
    
    for (String nombreParam : parametros.keySet()) {
        if (nombreParam.startsWith("cantidad_")) {
            // Extraer el ID del producto del nombre del parámetro
            String idProducto = nombreParam.substring("cantidad_".length());
            String cantidadStr = request.getParameter(nombreParam);
            
            if (cantidadStr != null && !cantidadStr.trim().isEmpty()) {
                try {
                    double nuevaCantidad = Double.parseDouble(cantidadStr);
                    
                    if (nuevaCantidad >= 0) { // Permitir cantidad 0
                        if (nuevaCantidad == 0) {
                            // Si la cantidad es 0, eliminar el producto del pedido
                            String sqlEliminar = "DELETE FROM t_detalle_pedido WHERE Id_Pedido=? AND Id_Prod=?";
                            PreparedStatement psEliminar = conn.prepareStatement(sqlEliminar);
                            psEliminar.setString(1, idPedido);
                            psEliminar.setString(2, idProducto);
                            
                            int resultado = psEliminar.executeUpdate();
                            
                            if (resultado > 0) {
                                System.out.println("Producto eliminado del pedido: " + idProducto);
                            }
                            
                            psEliminar.close();
                        } else {
                            // Actualizar la cantidad y recalcular el total
                            String sql = "UPDATE t_detalle_pedido SET Cantidad=?, TotalDeta=Precio*? " +
                                       "WHERE Id_Pedido=? AND Id_Prod=?";
                            
                            PreparedStatement ps = conn.prepareStatement(sql);
                            ps.setDouble(1, nuevaCantidad);
                            ps.setDouble(2, nuevaCantidad);
                            ps.setString(3, idPedido);
                            ps.setString(4, idProducto);
                            
                            int resultado = ps.executeUpdate();
                            
                            if (resultado > 0) {
                                System.out.println("Actualizada cantidad para producto " + idProducto + ": " + nuevaCantidad);
                            }
                            
                            ps.close();
                        }
                    }
                } catch (NumberFormatException e) {
                    System.out.println("Error al parsear cantidad para producto " + idProducto + ": " + cantidadStr);
                }
            }
        }
    }
}



private void recalcularTotalesPedido(Connection conn, String idPedido) throws SQLException {
    // Calcular el nuevo subtotal sumando todos los totales de detalle
    String sqlCalcular = "SELECT SUM(TotalDeta) as SubTotal FROM t_detalle_pedido WHERE Id_Pedido=?";
    PreparedStatement ps = conn.prepareStatement(sqlCalcular);
    ps.setString(1, idPedido);
    ResultSet rs = ps.executeQuery();
    
    if (rs.next()) {
        double nuevoSubTotal = rs.getDouble("SubTotal");
        double nuevoTotalVenta = nuevoSubTotal * 1.18; // Incluir IGV del 18%
        
        // Actualizar los totales en la tabla de pedidos
        String sqlActualizar = "UPDATE t_pedido SET SubTotal=?, TotalVenta=? WHERE Id_Pedido=?";
        PreparedStatement psActualizar = conn.prepareStatement(sqlActualizar);
        psActualizar.setDouble(1, nuevoSubTotal);
        psActualizar.setDouble(2, nuevoTotalVenta);
        psActualizar.setString(3, idPedido);
        
        int resultado = psActualizar.executeUpdate();
        
        if (resultado > 0) {
            System.out.println("Totales recalculados para pedido " + idPedido + 
                             " - SubTotal: " + nuevoSubTotal + ", Total: " + nuevoTotalVenta);
        }
        
        psActualizar.close();
    }
    
    rs.close();
    ps.close();
}
private void insertarDetallesPedido(Connection conn, String idPedido, HttpServletRequest request) throws SQLException {
    String[] productosIds = request.getParameterValues("productos[]");
    String[] cantidades = request.getParameterValues("cantidades[]");
    String[] precios = request.getParameterValues("precios[]");
    
    if (productosIds != null && cantidades != null && precios != null) {
        String sql = "INSERT INTO t_detalle_pedido (Id_Pedido, Id_Prod, Cantidad, Precio, TotalDeta) VALUES (?, ?, ?, ?, ?)";
        PreparedStatement ps = conn.prepareStatement(sql);
        
        for (int i = 0; i < productosIds.length; i++) {
            if (cantidades[i] != null && !cantidades[i].trim().isEmpty() && 
                Double.parseDouble(cantidades[i]) > 0) {
                
                double cantidad = Double.parseDouble(cantidades[i]);
                double precio = Double.parseDouble(precios[i]);
                double total = cantidad * precio;
                
                ps.setString(1, idPedido);
                ps.setString(2, productosIds[i]);
                ps.setDouble(3, cantidad);
                ps.setDouble(4, precio);
                ps.setDouble(5, total);
                ps.addBatch();
            }
        }
        ps.executeBatch();
        ps.close();
    }
}
    @Override
    public String getServletInfo() {
        return "Controlador para gestión de pedidos - Versión completa con CRUD";
    }
}