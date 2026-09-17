package com.inmobiliaria.modelo;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class Solicitud {
    private int idSolicitud;
    private Integer idCita;            // puede ser null
    private int idUsuario;
    private int idPropiedad;
    private String tipo;               // COMPRA / ARRIENDO
    private String estado;             // RADICADA / EN_REVISION / APROBADA / RECHAZADA
    private LocalDateTime fechaRadicacion;
    private String observaciones;

    // Campos "joined"
    private String tituloPropiedad;
    private String nombreCliente;
    private String correoCliente;

    // Documentos adjuntos (1:N)
    private List<Documento> documentos = new ArrayList<>();

    // ----- getters y setters -----
    public int getIdSolicitud() { return idSolicitud; }
    public void setIdSolicitud(int idSolicitud) { this.idSolicitud = idSolicitud; }

    public Integer getIdCita() { return idCita; }
    public void setIdCita(Integer idCita) { this.idCita = idCita; }

    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }

    public int getIdPropiedad() { return idPropiedad; }
    public void setIdPropiedad(int idPropiedad) { this.idPropiedad = idPropiedad; }

    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public LocalDateTime getFechaRadicacion() { return fechaRadicacion; }
    public void setFechaRadicacion(LocalDateTime f) { this.fechaRadicacion = f; }

    public String getObservaciones() { return observaciones; }
    public void setObservaciones(String observaciones) { this.observaciones = observaciones; }

    public String getTituloPropiedad() { return tituloPropiedad; }
    public void setTituloPropiedad(String t) { this.tituloPropiedad = t; }

    public String getNombreCliente() { return nombreCliente; }
    public void setNombreCliente(String n) { this.nombreCliente = n; }

    public String getCorreoCliente() { return correoCliente; }
    public void setCorreoCliente(String c) { this.correoCliente = c; }

    public List<Documento> getDocumentos() { return documentos; }
    public void setDocumentos(List<Documento> documentos) { this.documentos = documentos; }

    // ----- clase interna Documento -----
    public static class Documento {
        private int idDocumento;
        private String nombre;
        private String url;
        private LocalDateTime fechaCarga;

        public int getIdDocumento() { return idDocumento; }
        public void setIdDocumento(int idDocumento) { this.idDocumento = idDocumento; }

        public String getNombre() { return nombre; }
        public void setNombre(String nombre) { this.nombre = nombre; }

        public String getUrl() { return url; }
        public void setUrl(String url) { this.url = url; }

        public LocalDateTime getFechaCarga() { return fechaCarga; }
        public void setFechaCarga(LocalDateTime fechaCarga) { this.fechaCarga = fechaCarga; }
    }
}
