/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package conexion;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
/**
 * @author javie
 */
import java.sql.*;
public class conexionBD {
    static String driver = "com.mysql.cj.jdbc.Driver";
    
    static String host = "mainline.proxy.rlwy.net";
    static String port = "11789";
    static String database = "railway";
    static String url = "jdbc:mysql://" + host + ":" + port + "/" + database + 
                       "?useSSL=true&serverTimezone=UTC&allowPublicKeyRetrieval=true&createDatabaseIfNotExist=true";
    
    static String user = "root";
    static String pass = "QxZGiBNIPgHIbOTUWEPNDCKMDhlErkFJ";
    
    protected Connection conn = null;
    
    public conexionBD() {
        try {
            Class.forName(driver);
            conn = DriverManager.getConnection(url, user, pass);
            System.out.println("✅ Conexión a Railway realizada exitosamente");
            verificarBaseDatos();
        } catch (SQLException ex) {
            System.out.println("❌ Error de conexión SQL: " + ex.getMessage());
            ex.printStackTrace();
        } catch (ClassNotFoundException ex) {
            System.out.println("❌ Driver MySQL no encontrado: " + ex.getMessage());
            ex.printStackTrace();
        }
    }
    
    private void verificarBaseDatos() {
        try {
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT DATABASE()");
            if (rs.next()) {
                String dbName = rs.getString(1);
                System.out.println("📊 Base de datos activa: " + (dbName != null ? dbName : "ninguna"));
            }
            rs.close();
            stmt.close();
        } catch (SQLException ex) {
            System.out.println("⚠️ No se pudo verificar la base de datos: " + ex.getMessage());
        }
    }
    
    public Connection Connected() {
        return conn;
    }
    
    public void Disconnect() {
        try {
            if (conn != null && !conn.isClosed()) {
                conn.close();
                System.out.println("🔌 Conexión cerrada correctamente");
            }
        } catch (SQLException ex) {
            System.out.println("❌ Error al cerrar conexión: " + ex.getMessage());
        }
    }
    
    public boolean isConnected() {
        try {
            return conn != null && !conn.isClosed() && conn.isValid(2);
        } catch (SQLException ex) {
            return false;
        }
    }
    
    public void testConnection() {
        if (isConnected()) {
            System.out.println("✅ Conexión activa y funcionando");
        } else {
            System.out.println("❌ Conexión no disponible");
        }
    }
}