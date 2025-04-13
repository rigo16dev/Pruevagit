package servlets;

import java.io.*;
import java.nio.file.Paths;
import javax.servlet.*;
import javax.servlet.annotation.*;
import javax.servlet.http.*;
import java.sql.*;

@WebServlet(name = "AgregarLibro", urlPatterns = {"/AgregarLibro"})
@MultipartConfig
public class AgregarLibro extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        PrintWriter out = response.getWriter();

        try {
            String titulo = request.getParameter("titulo");
            String autor = request.getParameter("autor");
            String anioStr = request.getParameter("anio");
            String cantidadStr = request.getParameter("cantidad");
            String estado = request.getParameter("estado");
            String idCategoriaStr = request.getParameter("categoria");
            String descripcion = request.getParameter("descripcion");

            // Validaciones
            if (titulo == null || titulo.trim().isEmpty() || titulo.length() > 100 ||
                autor == null || autor.trim().isEmpty() || autor.length() > 100 ||
                anioStr == null || cantidadStr == null || estado == null ||
                idCategoriaStr == null || descripcion == null || descripcion.length() > 1000) {
                out.println("Error: Datos inv$)A("lidos o incompletos.");
                return;
            }

            int anio = Integer.parseInt(anioStr);
            int cantidad = Integer.parseInt(cantidadStr);
            int idCategoria = Integer.parseInt(idCategoriaStr);

            if (anio < 1500 || anio > 2099 || cantidad <= 0) {
                out.println("Error: A?o o cantidad fuera de rango.");
                return;
            }

            if (!estado.equals("Normal") && !estado.equals("Da?ado")) {
                out.println("Error: Estado no v$)A("lido.");
                return;
            }

            // Validar imagen
            Part filePart = request.getPart("imagen");
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

            if (fileName == null || fileName.isEmpty()) {
                out.println("Error: No se seleccion$)A(. imagen.");
                return;
            }

            String lowerName = fileName.toLowerCase();
            if (!lowerName.endsWith(".jpg") && !lowerName.endsWith(".jpeg") && !lowerName.endsWith(".png")) {
                out.println("Error: Solo se permiten im$)A("genes JPG o PNG.");
                return;
            }

            // Guardar imagen
            String uploadPath = getServletContext().getRealPath("/img/libros/");
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            // Evitar nombres duplicados
            String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
            filePart.write(uploadPath + File.separator + uniqueFileName);

            // Guardar en base de datos
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/biblioteca_sv", "root", "");

            String sql = "INSERT INTO libros (titulo, autor, anio_publicacion, cantidad, estado, id_categoria, foto, descripcion) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, titulo);
            ps.setString(2, autor);
            ps.setInt(3, anio);
            ps.setInt(4, cantidad);
            ps.setString(5, estado);
            ps.setInt(6, idCategoria);
            ps.setString(7, uniqueFileName);
            ps.setString(8, descripcion);

            ps.executeUpdate();
            ps.close();
            con.close();

            response.sendRedirect("Administrador/Gestion_libros.jsp");

        } catch (NumberFormatException ex) {
            out.println("Error: A?o o cantidad inv$)A("lidos. " + ex.getMessage());
        } catch (Exception e) {
            out.println("Error al agregar libro: " + e.getMessage());
        }
        
        
        /*para eliminar libros */
        String accion = request.getParameter("accion");

if ("eliminar".equals(accion)) {
    int idLibro = Integer.parseInt(request.getParameter("id"));

    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/biblioteca_sv", "root", "");

        // Verificar si tiene pr$)A(&stamos
        PreparedStatement check = con.prepareStatement("SELECT COUNT(*) FROM prestamos WHERE id_libro = ?");
        check.setInt(1, idLibro);
        ResultSet rs = check.executeQuery();
        rs.next();
        int prestamos = rs.getInt(1);

        if (prestamos > 0) {
            // Tiene pr$)A(&stamos !z marcar como Inactivo
            PreparedStatement update = con.prepareStatement("UPDATE libros SET estado_actual = 'Inactivo' WHERE id_libro = ?");
            update.setInt(1, idLibro);
            update.executeUpdate();
            response.sendRedirect("Administrador/Gestion_libros.jsp?mensaje=Libro con pr$)A(&stamos: marcado como Inactivo.");
        } else {
            // No tiene pr$)A(&stamos !z eliminar
            PreparedStatement delete = con.prepareStatement("DELETE FROM libros WHERE id_libro = ?");
            delete.setInt(1, idLibro);
            delete.executeUpdate();
            response.sendRedirect("Administrador/Gestion_libros.jsp?mensaje=Libro eliminado correctamente.");
        }

        con.close();
        return; // salimos para no ejecutar el resto del c$)A(.digo de agregar

    } catch (Exception e) {
        response.sendRedirect("Administrador/Gestion_libros.jsp?mensaje=Error al eliminar libro: " + e.getMessage());
        return;
    }
}

    }
}
