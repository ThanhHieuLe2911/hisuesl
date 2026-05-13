<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

require_once __DIR__ . '/../config/database.php';

$error = '';
$success = false;

if (isset($_SESSION['admin_id'])) {
    header('Location: index.php');
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = trim($_POST['username'] ?? '');
    $password = $_POST['password'] ?? '';

    if (empty($username) || empty($password)) {
        $error = 'Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.';
    } else {
        $stmt = $db->prepare("SELECT * FROM admin_users WHERE username = ?");
        $stmt->execute([$username]);
        $admin = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($admin && password_verify($password, $admin['password'])) {
            $_SESSION['admin_id'] = $admin['id'];
            $_SESSION['admin_username'] = $admin['username'];
            header('Location: index.php');
            exit;
        } else {
            $error = 'Sai tên đăng nhập hoặc mật khẩu.';
        }
    }
}
?>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - HisuESL Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/remixicon@4.2.0/fonts/remixicon.css" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            padding: 20px;
        }
        .login-card {
            background: #fff;
            border-radius: 16px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.4);
            width: 100%;
            max-width: 420px;
            padding: 48px 40px;
            text-align: center;
        }
        .login-logo {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
            margin-bottom: 32px;
        }
        .login-logo i { font-size: 40px; color: #6c5ce7; }
        .login-logo span { font-size: 28px; font-weight: 700; color: #2d3436; }
        .login-logo small { display: block; font-size: 13px; color: #636e72; font-weight: 400; margin-top: 2px; }

        .form-group { margin-bottom: 20px; text-align: left; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 600; color: #2d3436; font-size: 14px; }
        .input-wrapper {
            position: relative;
        }
        .input-wrapper i { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: #b2bec3; font-size: 18px; }
        .form-group input {
            width: 100%;
            padding: 14px 14px 14px 44px;
            border: 2px solid #dfe6e9;
            border-radius: 10px;
            font-size: 15px;
            transition: border-color 0.3s, box-shadow 0.3s;
            outline: none;
        }
        .form-group input:focus {
            border-color: #6c5ce7;
            box-shadow: 0 0 0 4px rgba(108, 92, 231, 0.15);
        }
        .form-group input:focus + i,
        .input-wrapper:hover i { color: #6c5ce7; }

        .btn-login {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, #6c5ce7, #5a4bd4);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            margin-top: 8px;
        }
        .btn-login:hover {
            background: linear-gradient(135deg, #5a4bd4, #4834d4);
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(108, 92, 231, 0.4);
        }
        .btn-login:active { transform: translateY(0); }

        .alert {
            padding: 14px 16px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-size: 14px;
            text-align: left;
        }
        .alert-error {
            background: #fff5f5;
            color: #c0392b;
            border: 1px solid #fab1a0;
        }
        .alert-error i { margin-right: 8px; }

        .forgot-link {
            margin-top: 20px;
            font-size: 13px;
            color: #636e72;
        }
        .forgot-link a { color: #6c5ce7; text-decoration: none; }
        .forgot-link a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="login-card">
        <div class="login-logo">
            <i class="ri-graduation-cap-line"></i>
            <div>
                <span>HisuESL</span>
                <small>Admin Panel</small>
            </div>
        </div>

        <?php if ($error): ?>
        <div class="alert alert-error">
            <i class="ri-error-warning-line"></i> <?= htmlspecialchars($error) ?>
        </div>
        <?php endif; ?>

        <form method="POST" autocomplete="off">
            <div class="form-group">
                <label>Tên đăng nhập</label>
                <div class="input-wrapper">
                    <input type="text" name="username" placeholder="Nhập tên đăng nhập" value="<?= htmlspecialchars($_POST['username'] ?? '') ?>" required autofocus>
                    <i class="ri-user-line"></i>
                </div>
            </div>
            <div class="form-group">
                <label>Mật khẩu</label>
                <div class="input-wrapper">
                    <input type="password" name="password" placeholder="Nhập mật khẩu" required>
                    <i class="ri-lock-line"></i>
                </div>
            </div>
            <button type="submit" class="btn-login">
                <i class="ri-login-box-line"></i> Đăng nhập
            </button>
        </form>

        <p class="forgot-link">
            <a href="mailto:developer@hisuesl.local">Liên hệ developer nếu quên mật khẩu</a>
        </p>
    </div>
</body>
</html>
