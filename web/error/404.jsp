<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 - Không tìm thấy trang</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #0f172a 0%, #1e3a8a 50%, #0f172a 100%);
            min-height: 100vh; display: flex; align-items: center; justify-content: center;
            color: white; text-align: center; padding: 24px;
        }
        .error-card { max-width: 460px; animation: fadeIn 0.5s ease-out; }
        @keyframes fadeIn { from { opacity:0; transform: translateY(20px); } to { opacity:1; transform: translateY(0); } }
        .error-icon {
            width: 100px; height: 100px;
            background: rgba(6,182,212,0.12); border: 2px solid rgba(6,182,212,0.25);
            border-radius: 50%; display: inline-flex; align-items: center; justify-content: center;
            font-size: 42px; color: #22d3ee; margin-bottom: 28px;
        }
        .error-code {
            font-size: 88px; font-weight: 700; line-height: 1;
            background: linear-gradient(135deg, #06b6d4, #2563eb);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
            margin-bottom: 12px;
        }
        .error-title { font-size: 24px; font-weight: 700; margin-bottom: 12px; }
        .error-desc  { font-size: 15px; color: #94a3b8; line-height: 1.6; margin-bottom: 32px; }
        .btn-group { display: flex; gap: 12px; justify-content: center; }
        .btn {
            padding: 12px 24px; border-radius: 10px; font-size: 14px; font-weight: 600;
            font-family: 'Inter', sans-serif; cursor: pointer; text-decoration: none;
            display: inline-flex; align-items: center; gap: 8px; transition: all 0.2s; border: none;
        }
        .btn-primary { background: linear-gradient(135deg,#2563eb,#1d4ed8); color: white; }
        .btn-primary:hover { transform: translateY(-1px); box-shadow: 0 8px 24px rgba(37,99,235,0.35); }
        .btn-secondary { background: rgba(255,255,255,0.08); color: #cbd5e1; border: 1px solid rgba(255,255,255,0.15); }
        .btn-secondary:hover { background: rgba(255,255,255,0.15); color: white; }
    </style>
</head>
<body>
<%
    model.User loggedUser = (model.User) session.getAttribute("loggedInUser");
    String dashUrl = loggedUser != null ? model.Role.getDashboardUrl(loggedUser.getRoleID()) : "/auth/login";
%>
<div class="error-card">
    <div class="error-icon"><i class="fas fa-search"></i></div>
    <div class="error-code">404</div>
    <h1 class="error-title">Trang không tồn tại</h1>
    <p class="error-desc">Trang bạn đang tìm kiếm không tồn tại hoặc đã bị di chuyển sang địa chỉ khác.</p>
    <div class="btn-group">
        <a href="${pageContext.request.contextPath}<%= dashUrl %>" class="btn btn-primary">
            <i class="fas fa-home"></i> Về trang chính
        </a>
        <a href="javascript:history.back()" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Quay lại
        </a>
    </div>
</div>
</body>
</html>
