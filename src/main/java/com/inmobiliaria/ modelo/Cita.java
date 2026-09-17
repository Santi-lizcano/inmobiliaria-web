package com.inmobiliaria.modelo;

import java.time.LocalDateTime;

public class Cita {
    private int idCita;
    private int idPropiedad;
    private int idUsuario;
    private LocalDateTime fechaHora;
    private String estado;        // PENDIENTE / CONFIRMADA / CANCELADA / REALIZADA
    private String observaciones;

    // Campos "joined" para mostrar en JSP
    private String tituloPropiedad;
    private String nombreCliente;
    private String correoCliente;
    private String telefonoCliente;

    public int getIdCita() { return idCita; }
    public void setIdCita(int idCita) { this.idCita = idCita; }

    public int getIdPropiedad() { return idPropiedad; }
    public void setIdPropiedad(int idPropiedad) { this.idPropiedad = idPropiedad; }

    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }

    public LocalDateTime getFechaHora() { return fechaHora; }
    public void setFechaHora(LocalDateTime fechaHora) { this.fechaHora = fechaHora; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public String getObservaciones() { return observaciones; }
    public void setObservaciones(String observaciones) { this.observaciones = observaciones; }

    public String getTituloPropiedad() { return tituloPropiedad; }
    public void setTituloPropiedad(String t) { this.tituloPropiedad = t; }

    public String getNombreCliente() { return nombreCliente; }
    public void setNombreCliente(String n) { this.nombreCliente = n; }

    public String getCorreoCliente() { return correoCliente; }
    public void setCorreoCliente(String c) { this.correoCliente = c; }

    public String getTelefonoCliente() { return telefonoCliente; }
    public void setTelefonoCliente(String t) { this.telefonoCliente = t; }
}
