/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Controler;
import Entidades.usuarios;
import conexion.conexionBD;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UsuariosDAO {
    private conexionBD conexion;
    
    public UsuariosDAO() {
        this.conexion = new conexionBD();
    }
    
    public usuarios validarLogin(String idUsuario, String password) {
        usuarios usuario = null;
        String sql = "SELECT * FROM t_usuario WHERE IdUsuario = ? AND Passwd = ?";
        
        try {
            Connection conn = conexion.Connected();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, idUsuario);
            ps.setString(2, password);
            
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                usuario = new usuarios();
                usuario.setIdUsuario(rs.getString("IdUsuario"));
                usuario.setPassword(rs.getString("Passwd"));
                
                // Verificar si la columna esAdmin existe y obtener su valor
                try {
                    usuario.setEsAdmin(rs.getInt("esAdmin"));
                } catch (SQLException e) {
                    // Si la columna no existe, asignar 0 por defecto
                    usuario.setEsAdmin(0);
                }
                
                // Obtener otros campos si existen
                try {
                    usuario.setEstado(rs.getString("Estado"));
                } catch (SQLException e) {
                    usuario.setEstado("Activo");
                }
                
                try {
                    usuario.setFechaRegistro(rs.getTimestamp("FechaRegistro"));
                } catch (SQLException e) {
                    usuario.setFechaRegistro(null);
                }
                
                try {
                    usuario.setUltimoAcceso(rs.getTimestamp("UltimoAcceso"));
                } catch (SQLException e) {
                    usuario.setUltimoAcceso(null);
                }
            }
            
            rs.close();
            ps.close();
            
        } catch (SQLException e) {
            System.out.println("Error al validar login: " + e.getMessage());
            e.printStackTrace();
        }
        
        return usuario;
    }
    
    public List<usuarios> listarUsuarios() {
        List<usuarios> listaUsuarios = new ArrayList<>();
        String sql = "SELECT * FROM t_usuario";
        
        try {
            Connection conn = conexion.Connected();
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                usuarios usuario = new usuarios();
                usuario.setIdUsuario(rs.getString("IdUsuario"));
                usuario.setPassword(rs.getString("Passwd"));
                
                // Verificar si la columna esAdmin existe y obtener su valor
                try {
                    usuario.setEsAdmin(rs.getInt("esAdmin"));
                } catch (SQLException e) {
                    // Si la columna no existe, asignar 0 por defecto
                    usuario.setEsAdmin(0);
                }
                
                // Obtener otros campos si existen
                try {
                    usuario.setEstado(rs.getString("Estado"));
                } catch (SQLException e) {
                    usuario.setEstado("Activo");
                }
                
                try {
                    usuario.setFechaRegistro(rs.getTimestamp("FechaRegistro"));
                } catch (SQLException e) {
                    usuario.setFechaRegistro(null);
                }
                
                try {
                    usuario.setUltimoAcceso(rs.getTimestamp("UltimoAcceso"));
                } catch (SQLException e) {
                    usuario.setUltimoAcceso(null);
                }
                
                listaUsuarios.add(usuario);
            }
            
            rs.close();
            ps.close();
            
        } catch (SQLException e) {
            System.out.println("Error al listar usuarios: " + e.getMessage());
            e.printStackTrace();
        }
        
        return listaUsuarios;
    }
    
    public usuarios obtenerUsuario(String idUsuario) {
        usuarios usuario = null;
        String sql = "SELECT * FROM t_usuario WHERE IdUsuario = ?";
        
        try {
            Connection conn = conexion.Connected();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, idUsuario);
            
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                usuario = new usuarios();
                usuario.setIdUsuario(rs.getString("IdUsuario"));
                usuario.setPassword(rs.getString("Passwd"));
                
                // Verificar si la columna esAdmin existe y obtener su valor
                try {
                    usuario.setEsAdmin(rs.getInt("esAdmin"));
                } catch (SQLException e) {
                    // Si la columna no existe, asignar 0 por defecto
                    usuario.setEsAdmin(0);
                }
                
                // Obtener otros campos si existen
                try {
                    usuario.setEstado(rs.getString("Estado"));
                } catch (SQLException e) {
                    usuario.setEstado("Activo");
                }
                
                try {
                    usuario.setFechaRegistro(rs.getTimestamp("FechaRegistro"));
                } catch (SQLException e) {
                    usuario.setFechaRegistro(null);
                }
                
                try {
                    usuario.setUltimoAcceso(rs.getTimestamp("UltimoAcceso"));
                } catch (SQLException e) {
                    usuario.setUltimoAcceso(null);
                }
            }
            
            rs.close();
            ps.close();
            
        } catch (SQLException e) {
            System.out.println("Error al obtener usuario: " + e.getMessage());
            e.printStackTrace();
        }
        
        return usuario;
    }
    
    public boolean agregarUsuario(usuarios usuario) {
        String sql = "INSERT INTO t_usuario (IdUsuario, Passwd, esAdmin) VALUES (?, ?, ?)";
        
        try {
            Connection conn = conexion.Connected();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, usuario.getIdUsuario());
            ps.setString(2, usuario.getPassword());
            ps.setInt(3, usuario.getEsAdmin());
            
            int resultado = ps.executeUpdate();
            ps.close();
            
            return resultado > 0;
            
        } catch (SQLException e) {
            System.out.println("Error al agregar usuario: " + e.getMessage());
            return false;
        }
    }
    
    public boolean modificarUsuario(String idUsuarioOriginal, usuarios usuarioModificado) {
        String sql = "UPDATE t_usuario SET IdUsuario = ?, Passwd = ?, esAdmin = ? WHERE IdUsuario = ?";
        
        try {
            Connection conn = conexion.Connected();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, usuarioModificado.getIdUsuario());
            ps.setString(2, usuarioModificado.getPassword());
            ps.setInt(3, usuarioModificado.getEsAdmin());
            ps.setString(4, idUsuarioOriginal);
            
            int resultado = ps.executeUpdate();
            ps.close();
            
            return resultado > 0;
            
        } catch (SQLException e) {
            System.out.println("Error al modificar usuario: " + e.getMessage());
            return false;
        }
    }
    
    public boolean existeUsuario(String idUsuario, String idUsuarioOriginal) {
        String sql = "SELECT COUNT(*) FROM t_usuario WHERE IdUsuario = ? AND IdUsuario != ?";
        
        try {
            Connection conn = conexion.Connected();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, idUsuario);
            ps.setString(2, idUsuarioOriginal);
            
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                int count = rs.getInt(1);
                rs.close();
                ps.close();
                return count > 0;
            }
            
            rs.close();
            ps.close();
            
        } catch (SQLException e) {
            System.out.println("Error al verificar existencia de usuario: " + e.getMessage());
        }
        
        return false;
    }
    
    public boolean eliminarUsuario(String idUsuario) {
        String sql = "DELETE FROM t_usuario WHERE IdUsuario = ?";
        
        try {
            Connection conn = conexion.Connected();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, idUsuario);
            
            int resultado = ps.executeUpdate();
            ps.close();
            
            return resultado > 0;
            
        } catch (SQLException e) {
            System.out.println("Error al eliminar usuario: " + e.getMessage());
            return false;
        }
    }
    
    // Método para verificar si un usuario es administrador
    public boolean esAdministrador(String idUsuario) {
        String sql = "SELECT esAdmin FROM t_usuario WHERE IdUsuario = ?";
        
        try {
            Connection conn = conexion.Connected();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, idUsuario);
            
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                int esAdmin = rs.getInt("esAdmin");
                rs.close();
                ps.close();
                return esAdmin == 1;
            }
            
            rs.close();
            ps.close();
            
        } catch (SQLException e) {
            System.out.println("Error al verificar administrador: " + e.getMessage());
        }
        
        return false;
    }
    
    public void cerrarConexion() {
        if (conexion != null) {
            conexion.Disconnect();
        }
    }
}