<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars($pageTitle ?? 'HisuESL Admin') ?></title>
    <link href="https://cdn.jsdelivr.net/npm/remixicon@4.2.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="stylesheet" href="/hisuesl_backend/admin/assets/style.css">
</head>
<body>
    <div class="admin-layout">
        <?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
if (!isset($_SESSION['admin_id'])) {
    header('Location: /hisuesl_backend/admin/login.php');
    exit;
}

// Flash messages
$flashSuccess = $_SESSION['flash_success'] ?? null;
$flashError = $_SESSION['flash_error'] ?? null;
unset($_SESSION['flash_success'], $_SESSION['flash_error']);
?>
<?php include __DIR__ . '/sidebar.php'; ?>
        <main class="main-content">
            <header class="top-header">
                <button class="sidebar-toggle" onclick="toggleSidebar()">
                    <i class="ri-menu-line"></i>
                </button>
                <div class="header-left">
                    <h1><?= htmlspecialchars($pageTitle ?? 'Dashboard') ?></h1>
                    <?php if (isset($breadcrumb)): ?>
                    <nav class="breadcrumb">
                        <?php foreach ($breadcrumb as $label => $link): ?>
                            <a href="<?= $link ?>"><?= htmlspecialchars($label) ?></a>
                            <span class="separator">/</span>
                        <?php endforeach; ?>
                        <span class="current"><?= htmlspecialchars($pageTitle ?? '') ?></span>
                    </nav>
                    <?php endif; ?>
                </div>
                <div class="header-right">
                    <div class="admin-info">
                        <i class="ri-user-settings-line"></i>
                        <span><?= htmlspecialchars($_SESSION['admin_username'] ?? 'Admin') ?></span>
                    </div>
                    <a href="logout.php" class="btn-logout" title="Đăng xuất">
                        <i class="ri-logout-box-r-line"></i>
                        <span>Đăng xuất</span>
                    </a>
                </div>
            </header>
            <div class="content-body">
<?php if ($flashSuccess): ?>
                <div class="alert alert-success" style="margin-bottom:16px;">
                    <i class="ri-check-line"></i> <?= htmlspecialchars($flashSuccess) ?>
                </div>
<?php endif; ?>
<?php if ($flashError): ?>
                <div class="alert alert-error" style="margin-bottom:16px;">
                    <i class="ri-error-warning-line"></i> <?= htmlspecialchars($flashError) ?>
                </div>
<?php endif; ?>
