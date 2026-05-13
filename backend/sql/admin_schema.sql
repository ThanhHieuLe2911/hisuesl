-- =============================================
-- HisuESL Admin Panel - Database Migration
-- Chạy file này trong MySQL Workbench trước khi sử dụng Admin Panel
-- =============================================

-- =============================================
-- Bảng admin_users: tài khoản quản trị
-- =============================================
CREATE TABLE IF NOT EXISTS admin_users (
    id         INT PRIMARY KEY AUTO_INCREMENT,
    username   VARCHAR(100) NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,
    created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

-- Tài khoản mặc định: admin / admin
-- Hash bcrypt: password_hash('admin', PASSWORD_DEFAULT)
INSERT INTO admin_users (username, password) VALUES
('admin', '$2y$10$1ZZ9Aa4RYNJdnfrMTOSYNeUv14h9vUiPRoNZxxYTcnyzHbxD642YO');

-- =============================================
-- Bảng learning_stats: thống kê học tập (optional)
-- =============================================
CREATE TABLE IF NOT EXISTS learning_stats (
    id            INT PRIMARY KEY AUTO_INCREMENT,
    stat_date     DATE         NOT NULL,
    new_users     INT          DEFAULT 0,
    quizzes_taken INT          DEFAULT 0,
    total_points  INT          DEFAULT 0,
    created_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);
