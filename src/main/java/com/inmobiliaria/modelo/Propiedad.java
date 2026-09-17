package com.inmobiliaria.modelo;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class Propiedad {
    private int idPropiedad;
    private String matriculaInmobiliaria;
    private String titulo;
    private String descripcion;
    private BigDecimal precio;
    private BigDecimal areaM2;
    private int habitaciones;
    private int banos;
    private String direccion;
    private String estado;
    private int idTipo;
    private int idCiudad;
    private int idInmobiliaria;
    private LocalDateTime fechaPublicacion;

    // Datos "joined" para mostrar en JSP
    private String nombreTipo;
    private String nombreCiudad;
    private String razonSocialInmobiliaria;

    private List<String> imagenes = new ArrayList<>();
    private List<String> caracteristicas = new ArrayList<>();

    // getters y setters ...
    public int getIdPropiedad() { return idPropiedad; }
    public void setIdPropiedad(int idPropiedad) { this.idPropiedad = idPropiedad; }
    public String getMatriculaInmobiliaria() { return matriculaInmobiliaria; }
    public void setMatriculaInmobiliaria(String m) { this.matriculaInmobiliaria = m; }
    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
    public BigDecimal getPrecio() { return precio; }
    public void setPrecio(BigDecimal precio) { this.precio = precio; }
    public BigDecimal getAreaM2() { return areaM2; }
    public void setAreaM2(BigDecimal areaM2) { this.areaM2 = areaM2; }
    public int getHabitaciones() { return habitaciones; }
    public void setHabitaciones(int habitaciones) { this.habitaciones = habitaciones; }
    public int getBanos() { return banos; }
    public void setBanos(int banos) { this.banos = banos; }
    public String getDireccion() { return direccion; }
    public void setDireccion(String direccion) { this.direccion = direccion; }
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
    public int getIdTipo() { return idTipo; }
    public void setIdTipo(int idTipo) { this.idTipo = idTipo; }
    public int getIdCiudad() { return idCiudad; }
    public void setIdCiudad(int idCiudad) { this.idCiudad = idCiudad; }
    public int getIdInmobiliaria() { return idInmobiliaria; }
    public void setIdInmobiliaria(int idInmobiliaria) { this.idInmobiliaria = idInmobiliaria; }
    public LocalDateTime getFechaPublicacion() { return fechaPublicacion; }
    public void setFechaPublicacion(LocalDateTime f) { this.fechaPublicacion = f; }
    public String getNombreTipo() { return nombreTipo; }
    public void setNombreTipo(String nombreTipo) { this.nombreTipo = nombreTipo; }
    public String getNombreCiudad() { return nombreCiudad; }
    public void setNombreCiudad(String nombreCiudad) { this.nombreCiudad = nombreCiudad; }
    public String getRazonSocialInmobiliaria() { return razonSocialInmobiliaria; }
    public void setRazonSocialInmobiliaria(String r) { this.razonSocialInmobiliaria = r; }
    public List<String> getImagenes() { return imagenes; }
    public void setImagenes(List<String> imagenes) { this.imagenes = imagenes; }
    public List<String> getCaracteristicas() { return caracteristicas; }
    public void setCaracteristicas(List<String> c) { this.caracteristicas = c; }
}
