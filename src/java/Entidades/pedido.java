/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package Entidades;

import java.sql.Date;

/**
 * Clase Pedido actualizada con nuevos atributos
 * @author javie
 */
public class pedido {
    private String Id_Pedido;
    private String Id_Cliente;
    private String Apellidos;
    private String Nombres;
    private Date Fecha;
    private double SubTotal;
    private double TotalVenta;
    
    // Nuevos atributos añadidos
    private String Estado;
    private Date FechaEntrega;
    private String Observaciones;
    private String DireccionEntrega;
    private String TelefonoContacto;

    public pedido() {
        this.Id_Pedido = "";
        this.Id_Cliente = "";
        this.Apellidos = "";
        this.Nombres = "";
        this.Fecha = null;
        this.SubTotal = 0;
        this.TotalVenta = 0;
        this.Estado = "Activo";
        this.FechaEntrega = null;
        this.Observaciones = "";
        this.DireccionEntrega = "";
        this.TelefonoContacto = "";
    }

    // Getters y Setters existentes
    public String getId_Pedido() {
        return Id_Pedido;
    }

    public void setId_Pedido(String Id_Pedido) {
        this.Id_Pedido = Id_Pedido;
    }

    public String getId_Cliente() {
        return Id_Cliente;
    }

    public void setId_Cliente(String Id_Cliente) {
        this.Id_Cliente = Id_Cliente;
    }

    public String getApellidos() {
        return Apellidos;
    }

    public void setApellidos(String Apellidos) {
        this.Apellidos = Apellidos;
    }

    public String getNombres() {
        return Nombres;
    }

    public void setNombres(String Nombres) {
        this.Nombres = Nombres;
    }

    public Date getFecha() {
        return Fecha;
    }

    public void setFecha(Date Fecha) {
        this.Fecha = Fecha;
    }

    public double getSubTotal() {
        return SubTotal;
    }

    public void setSubTotal(double SubTotal) {
        this.SubTotal = SubTotal;
    }

    public double getTotalVenta() {
        return TotalVenta;
    }

    public void setTotalVenta(double TotalVenta) {
        this.TotalVenta = TotalVenta;
    }

    // Nuevos Getters y Setters
    public String getEstado() {
        return Estado;
    }

    public void setEstado(String Estado) {
        this.Estado = Estado;
    }

    public Date getFechaEntrega() {
        return FechaEntrega;
    }

    public void setFechaEntrega(Date FechaEntrega) {
        this.FechaEntrega = FechaEntrega;
    }

    public String getObservaciones() {
        return Observaciones;
    }

    public void setObservaciones(String Observaciones) {
        this.Observaciones = Observaciones;
    }

    public String getDireccionEntrega() {
        return DireccionEntrega;
    }

    public void setDireccionEntrega(String DireccionEntrega) {
        this.DireccionEntrega = DireccionEntrega;
    }

    public String getTelefonoContacto() {
        return TelefonoContacto;
    }

    public void setTelefonoContacto(String TelefonoContacto) {
        this.TelefonoContacto = TelefonoContacto;
    }
}
