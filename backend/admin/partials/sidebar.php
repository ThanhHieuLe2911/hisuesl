<aside class="sidebar" id="sidebar">
    <div class="sidebar-header">
        <div class="sidebar-logo">
            <i class="ri-graduation-cap-line"></i>
            <span>HisuESL</span>
        </div>
        <button class="sidebar-close" onclick="toggleSidebar()">
            <i class="ri-close-line"></i>
        </button>
    </div>

    <div class="sidebar-user">
        <div class="user-avatar">
            <i class="ri-user-settings-line"></i>
        </div>
        <div class="user-info">
            <span class="user-name">Quản trị viên</span>
            <span class="user-role">
                <i class="ri-shield-check-line"></i> Administrator
            </span>
        </div>
    </div>

    <nav class="sidebar-nav">
        <div class="nav-section-label">Quản lý</div>
        <a href="/hisuesl_backend/admin/index.php" class="nav-item <?= ($currentPage ?? '') === 'dashboard' ? 'active' : '' ?>">
            <i class="ri-dashboard-line"></i>
            <span>Dashboard</span>
        </a>
        <a href="/hisuesl_backend/admin/topics/index.php" class="nav-item <?= ($currentPage ?? '') === 'topics' ? 'active' : '' ?>">
            <i class="ri-book-2-line"></i>
            <span>Topics</span>
        </a>
        <a href="/hisuesl_backend/admin/vocabularies/index.php" class="nav-item <?= ($currentPage ?? '') === 'vocabularies' ? 'active' : '' ?>">
            <i class="ri-file-word-2-line"></i>
            <span>Vocabularies</span>
        </a>
        <a href="/hisuesl_backend/admin/questions/index.php" class="nav-item <?= ($currentPage ?? '') === 'questions' ? 'active' : '' ?>">
            <i class="ri-bubble-chart-line"></i>
            <span>Questions</span>
        </a>

        <div class="nav-divider"></div>
        <div class="nav-section-label">Công cụ</div>
        <a href="/hisuesl_backend/admin/export.php" class="nav-item <?= ($currentPage ?? '') === 'export' ? 'active' : '' ?>">
            <i class="ri-download-2-line"></i>
            <span>Export CSV</span>
        </a>
        <a href="/hisuesl_backend/admin/import.php" class="nav-item <?= ($currentPage ?? '') === 'import' ? 'active' : '' ?>">
            <i class="ri-upload-2-line"></i>
            <span>Import CSV</span>
        </a>
    </nav>

    <div class="sidebar-footer">
        <a href="/hisuesl_backend/admin/logout.php" class="nav-item logout-item">
            <i class="ri-logout-box-r-line"></i>
            <span>Đăng xuất</span>
        </a>
    </div>
</aside>

<script>
function toggleSidebar() {
    document.getElementById('sidebar').classList.toggle('collapsed');
    document.querySelector('.main-content').classList.toggle('sidebar-collapsed');
}
</script>
