<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Gestión de Libros</title>
    <link href="../css/style.css" rel="stylesheet" type="text/css"/>
    <link rel="stylesheet" href="../css/style_admin.css" type="text/css"/>
</head>
<body>
<div class="dashboard-container">
    
    <!-- Sidebar -->
    <aside class="sidebar">
        <h2>Biblioteca</h2>
        <ul class="menu">
            <li class="menu-item"><a href="inicio.jsp">Inicio</a></li>
            <li class="menu-item"><a href="Gestion_categorias.jsp">Gestión de Categorías</a></li>
            <li class="menu-item active"><a href="Gestion_libros.jsp">Gestión de Libros</a></li>
            <li class="menu-item"><a href="CerrarSesion">Cerrar sesión</a></li>
        </ul>
    </aside>

    <!-- Main Content -->
    <div class="main-content">
        <!-- Topbar -->
        <div class="topbar">
            <div class="menu-icon">&#9776;</div>
            <div class="search-box">
  <form method="get" action="Gestion_libros.jsp" onsubmit="return false;">
    <input type="text" name="buscar" placeholder="Buscar libro..." 
           value="<%= request.getParameter("buscar") != null ? request.getParameter("buscar") : "" %>"
           onkeyup="if(this.value.length > 1){ this.form.submit(); }">
</form>

</div>

            <div class="profile-pic">
                <img src="img/perfil.jpg" alt="Perfil">
            </div>
        </div>

        <!-- Zona principal -->
        <div class="orders">
            <h2>Agregar Libro</h2>
<div class="header-acciones">
    <button class="btn-nuevo" onclick="abrirModal()">+ Nuevo Libro</button>
</div>


            <table class="tabla-libros" id="tablaLibros">

                <thead>
                    <tr>
                        <th>ID</th>
                        <th>NOMBRE</th>
                        <th>IMAGEN</th>
                        <th>DESCRIPCIÓN</th>
                        <th>AÑO</th>
                        <th>CANTIDAD</th>
                        <th>CATEGORÍA</th>
                        <th>ESTADO</th>
                        <th>ACCIONES</th>
                    </tr>
                </thead>
                <tbody>
   <%
    String busqueda = request.getParameter("buscar");
    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/biblioteca_sv", "root", "");

        String sql = "SELECT l.*, c.nombre AS categoria_nombre " +
                     "FROM libros l INNER JOIN categorias c ON l.id_categoria = c.id_categoria";

        PreparedStatement ps;

        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " WHERE LOWER(l.titulo) LIKE ? OR LOWER(l.autor) LIKE ?";
            ps = con.prepareStatement(sql);
            String filtro = "%" + busqueda.toLowerCase() + "%";
            ps.setString(1, filtro);
            ps.setString(2, filtro);
        } else {
            ps = con.prepareStatement(sql);
        }

        ResultSet rs = ps.executeQuery();

        boolean hayResultados = false;
        while (rs.next()) {
            hayResultados = true;
%>
<tr>
    <td><%= rs.getInt("id_libro") %></td>
    <td><%= rs.getString("titulo") %></td>
    <td>
        <img src="../img/libros/<%= rs.getString("foto") %>" alt="Imagen" width="50" height="50" style="border-radius: 5px;">
    </td>
    <td><%= rs.getString("descripcion") %></td>
    <td><%= rs.getInt("anio_publicacion") %></td>
    <td><%= rs.getInt("cantidad") %></td>
    <td><%= rs.getString("categoria_nombre") %></td>
    <td><%= rs.getString("estado") %></td>
    <td>
    <form method="post" action="../AgregarLibro" onsubmit="return confirm('¿Estás seguro que deseas eliminar este libro?');" style="display:inline;">
        <input type="hidden" name="accion" value="eliminar">
        <input type="hidden" name="id" value="<%= rs.getInt("id_libro") %>">
        <button type="submit" class="btn-eliminar">🗑️</button>
    </form>
</td>

</tr>
<%
        }

        if (!hayResultados) {
%>
<tr><td colspan="9">No se encontraron resultados.</td></tr>
<%
        }

        rs.close();
        ps.close();
        con.close();

    } catch (Exception e) {
        out.println("<tr><td colspan='9'>Error al buscar libros: " + e.getMessage() + "</td></tr>");
    }
%>



                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- MODAL -->
<div id="modalAgregarLibro" class="modal">
    <div class="modal-contenido">
        <span class="cerrar" onclick="cerrarModal()">&times;</span>
        <h2>Agregar Libro</h2>
        <!-- formulario aquí -->


        <form action="../AgregarLibro" method="post" enctype="multipart/form-data" class="formulario-libro">
    <div class="form-group">
        <input type="text" name="titulo" placeholder="Título del libro" required maxlength="100">
        <input type="text" name="autor" placeholder="Autor" required maxlength="100">
    </div>

    <div class="form-group">
        <input type="number" name="anio" placeholder="Año de publicación" required min="1500" max="2099">
        <input type="number" name="cantidad" placeholder="Cantidad disponible" required min="1" step="1">
    </div>

    <div class="form-group">
        <select name="estado" required>
            <option value="">Estado</option>
            <option value="Normal">Normal</option>
            <option value="Dañado">Dañado</option>
        </select>

        <select name="categoria" required>
            <option value="">Seleccione categoría</option>
              <%
                        try {
                            Class.forName("com.mysql.jdbc.Driver");
                            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/biblioteca_sv", "root", "");
                            Statement st = con.createStatement();
                            ResultSet rs = st.executeQuery("SELECT * FROM categorias");

                            while(rs.next()) {
                    %>
                        <option value="<%= rs.getInt("id_categoria") %>"><%= rs.getString("nombre") %></option>
                    <%
                            }
                            con.close();
                        } catch(Exception e) {
                            out.println("Error al cargar categorías");
                        }
                    %>
        </select>
    </div>

    <textarea name="descripcion" placeholder="Descripción del libro" rows="3" maxlength="1000"></textarea>

    <div class="form-group">
        <input type="file" name="imagen" accept="image/png, image/jpeg" required>
    </div>

    <button type="submit" class="btn-agregar">Guardar libro</button>
</form>

    </div>
</div>

<!-- Scripts -->
<script>
    function abrirModal() {
        document.getElementById("modalAgregarLibro").style.display = "block";
    }

    function cerrarModal() {
        document.getElementById("modalAgregarLibro").style.display = "none";
    }

    window.onclick = function(event) {
        const modal = document.getElementById("modalAgregarLibro");
        if (event.target === modal) {
            modal.style.display = "none";
        }
    }
</script>

<script>
    const searchLibroInput = document.getElementById("searchLibroInput");
    const tablaLibros = document.getElementById("tablaLibros");

    searchLibroInput.addEventListener("keyup", function () {
        const value = this.value.toLowerCase();
        const rows = tablaLibros.getElementsByTagName("tr");

        for (let i = 1; i < rows.length; i++) { // empieza desde 1 para saltar el thead
            const row = rows[i];
            const text = row.innerText.toLowerCase();
            row.style.display = text.includes(value) ? "" : "none";
        }
    });
</script>


</body>
</html>
