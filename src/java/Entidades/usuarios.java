/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
    package Entidades;
    import java.sql.Timestamp;

    /**
     * Clase Usuario actualizada con nuevos atributos incluyendo esAdmin
     * @author javie
     */
    public class usuarios {
        // Atributos existentes
        private String idUsuario;
        private String password;

        // Nuevos atributos añadidos
        private String Estado;
        private Timestamp FechaRegistro;
        private Timestamp UltimoAcceso;
        private int esAdmin; // 0 = usuario normal, 1 = administrador

        // Constructor vacío existente
        public usuarios() {
            this.Estado = "Activo";
            this.FechaRegistro = null;
            this.UltimoAcceso = null;
            this.esAdmin = 0; // Por defecto usuario normal
        }

        // Constructor existente con parámetros
        public usuarios(String idUsuario, String password) {
            this.idUsuario = idUsuario;
            this.password = password;
            this.Estado = "Activo";
            this.FechaRegistro = null;
            this.UltimoAcceso = null;
            this.esAdmin = 0; // Por defecto usuario normal
        }

        // Constructor completo con nuevos atributos
        public usuarios(String idUsuario, String password, String estado, Timestamp fechaRegistro, Timestamp ultimoAcceso, int esAdmin) {
            this.idUsuario = idUsuario;
            this.password = password;
            this.Estado = estado;
            this.FechaRegistro = fechaRegistro;
            this.UltimoAcceso = ultimoAcceso;
            this.esAdmin = esAdmin;
        }

        // Getters y Setters existentes
        public String getIdUsuario() { 
            return idUsuario; 
        }

        public void setIdUsuario(String idUsuario) { 
            this.idUsuario = idUsuario; 
        }

        public String getPassword() { 
            return password; 
        }

        public void setPassword(String password) { 
            this.password = password; 
        }

        // Nuevos Getters y Setters
        public String getEstado() {
            return Estado;
        }

        public void setEstado(String Estado) {
            this.Estado = Estado;
        }

        public Timestamp getFechaRegistro() {
            return FechaRegistro;
        }

        public void setFechaRegistro(Timestamp FechaRegistro) {
            this.FechaRegistro = FechaRegistro;
        }

        public Timestamp getUltimoAcceso() {
            return UltimoAcceso;
        }

        public void setUltimoAcceso(Timestamp UltimoAcceso) {
            this.UltimoAcceso = UltimoAcceso;
        }

        public int getEsAdmin() {
            return esAdmin;
        }

        public void setEsAdmin(int esAdmin) {
            this.esAdmin = esAdmin;
        }

        // Método de conveniencia para verificar si es admin
        public boolean isAdmin() {
            return esAdmin == 1;
        }
    }