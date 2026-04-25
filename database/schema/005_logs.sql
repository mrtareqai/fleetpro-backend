-- 005_logs.sql
-- Logs Tables: Audit Logs (Movements), Notifications

CREATE TABLE audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT,
    user_id BIGINT,
    action_type ENUM('create', 'update', 'delete', 'login', 'other') NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    entity_id BIGINT,
    before_state JSON,
    after_state JSON,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT,
    user_id BIGINT NOT NULL,
    source ENUM('login_failed', 'booking_created', 'trip_delayed', 'payment_received', 'system') NOT NULL,
    type ENUM('in_app', 'telegram', 'email') NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
