<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Administrador</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
</head>
<body>
    <div class="dashboard-container">
        <!-- Sidebar -->
        <aside class="sidebar hidden" id="sidebar">
            <ul class="menu" id="menu">
                <li class="menu-item active"><a href="admin.jsp">Inicio</a></li>
                <li class="menu-item"><a href="Administrador/Gestion_categorias.jsp">Gestión de Categorías</a></li>
                <li class="menu-item"><a href="Administrador/Gestion_libros.jsp">Gestión de Libros</a></li>
                <li class="menu-item"><a href="#">Cerrar sesión</a></li>
            </ul>
        </aside>

        <!-- Contenido principal -->
        <main class="main-content">
            <section class="topbar">
                <div class="menu-icon" id="menuToggle">☰</div>
                <div class="search-box">
                    <input type="text" placeholder="Buscar...">
                </div>
                <div class="profile-pic" id="profileBtn">
                    <img src="https://placekitten.com/40/40" alt="Perfil" />
                    <div class="dropdown-menu" id="dropdownMenu">
                        <p><strong>Nombre:</strong> Admin</p>
                        <p><strong>Rol:</strong> Administrador</p>
                        <form action="logout.jsp" method="post">
                            <button type="submit">Cerrar sesión</button>
                        </form>
                    </div>
                </div>
            </section>

            <section class="content-area">
                <!-- Aquí se puede mostrar un resumen general -->
                <h2>Bienvenido al panel de administración</h2>
            </section>
        </main>
    </div>

    <!-- Scripts -->
    <script>
        const menuToggle = document.getElementById('menuToggle');
        const sidebar = document.getElementById('sidebar');
        const menuItems = document.querySelectorAll('.menu-item');
        menuToggle.addEventListener('click', () => {
            sidebar.classList.toggle('hidden');
        });
        menuItems.forEach(item => {
            item.addEventListener('click', () => {
                menuItems.forEach(i => i.classList.remove('active'));
                item.classList.add('active');
            });
        });

        const profileBtn = document.getElementById('profileBtn');
        const dropdownMenu = document.getElementById('dropdownMenu');
        profileBtn.addEventListener('click', () => {
            dropdownMenu.style.display = dropdownMenu.style.display === 'block' ? 'none' : 'block';
        });
        window.addEventListener('click', function (e) {
            if (!profileBtn.contains(e.target)) {
                dropdownMenu.style.display = 'none';
            }
        });
    </script>
</body>
</html>
