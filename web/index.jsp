<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Object loggedUser = session.getAttribute("loggedInUser");
    Object roleValue = session.getAttribute("userRole");
    int roleId = roleValue instanceof Number ? ((Number) roleValue).intValue() : 0;
    boolean isLoggedIn = loggedUser != null;

    String dashboardUrl;
    switch (roleId) {
        case 1: dashboardUrl = request.getContextPath() + "/admin/dashboard.jsp"; break;
        case 2: dashboardUrl = request.getContextPath() + "/doctor/dashboard.jsp"; break;
        case 3: dashboardUrl = request.getContextPath() + "/receptionist/dashboard.jsp"; break;
        case 4: dashboardUrl = request.getContextPath() + "/customer/dashboard.jsp"; break;
        default: dashboardUrl = request.getContextPath() + "/auth/login";
    }

    String bookingUrl = !isLoggedIn
            ? request.getContextPath() + "/auth/login"
            : (roleId == 4
                ? request.getContextPath() + "/customer/booking.jsp"
                : dashboardUrl);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="SmileCare - Nha khoa tận tâm cho nụ cười khỏe đẹp.">
    <title>SmileCare | Nha khoa tận tâm</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&family=Nunito+Sans:wght@400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/smilecare.css?v=20260716-2">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/smilecare-account.css?v=20260716-2">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/smilecare-mobile.css?v=20260716-2">
</head>
<body>
    <jsp:include page="/WEB-INF/components/header.jsp" />

    <main>
        <section class="hero">
            <div class="hero-orb orb-one"></div>
            <div class="hero-orb orb-two"></div>
            <div class="container hero-grid">
                <div class="hero-copy">
                    <p class="eyebrow"><span>●</span> NHA KHOA CHUẨN QUỐC TẾ</p>
                    <h1>Nụ cười rạng rỡ,<br><em>tự tin mỗi ngày.</em></h1>
                    <p class="hero-description">SmileCare đồng hành cùng bạn trên hành trình chăm sóc sức khỏe răng miệng bằng dịch vụ tận tâm và công nghệ hiện đại.</p>
                    <div class="hero-actions">
                        <a class="button" href="<%= bookingUrl %>">Đặt lịch khám <span>→</span></a>
                        <a class="text-button" href="#services">Khám phá dịch vụ <span>↓</span></a>
                    </div>
                    <div class="trust-row">
                        <div class="avatars"><span>MA</span><span>TH</span><span>LN</span><span>+</span></div>
                        <p><strong>10.000+</strong><br>khách hàng tin chọn</p>
                    </div>
                </div>

                <div class="hero-visual">
                    <div class="hero-image-frame">
                        <img src="https://images.unsplash.com/photo-1609840114035-3c981b782dfe?auto=format&fit=crop&w=900&q=85" alt="Bác sĩ SmileCare tư vấn khách hàng">
                    </div>
                    <div class="floating-card appointment-card"><span class="card-icon">✓</span><div><small>Đặt khám trực tuyến</small><strong>Nhanh chóng, dễ dàng</strong></div></div>
                    <div class="floating-card rating-card"><strong>4.9 <span>★</span></strong><small>Đánh giá từ khách hàng</small></div>
                </div>
            </div>
        </section>

        <section class="quick-booking" id="booking">
            <div class="container quick-booking-inner">
                <div><p class="eyebrow"><span>●</span> ĐẶT HẸN CÙNG SMILECARE</p><h2>Sẵn sàng chăm sóc nụ cười của bạn?</h2></div>
                <a class="button button-light" href="<%= bookingUrl %>">Đặt lịch ngay <span>→</span></a>
            </div>
        </section>

        <section class="section" id="about">
            <div class="container feature-grid">
                <div class="section-intro">
                    <p class="eyebrow"><span>●</span> VÌ SAO CHỌN SMILECARE</p>
                    <h2>Chăm sóc bằng<br><em>sự thấu hiểu.</em></h2>
                    <p>Mỗi nụ cười đều xứng đáng được chăm sóc theo cách riêng, an toàn và nhẹ nhàng nhất.</p>
                    <a class="text-button teal" href="#contact">Tìm hiểu thêm <span>→</span></a>
                </div>
                <div class="feature-list">
                    <article class="feature-card"><span class="feature-icon">✦</span><div><h3>Đội ngũ tận tâm</h3><p>Bác sĩ giàu kinh nghiệm, luôn lắng nghe và tư vấn rõ ràng.</p></div></article>
                    <article class="feature-card"><span class="feature-icon">⌁</span><div><h3>Công nghệ hiện đại</h3><p>Thiết bị tiên tiến giúp chẩn đoán chính xác và điều trị nhẹ nhàng.</p></div></article>
                    <article class="feature-card"><span class="feature-icon">♡</span><div><h3>Chăm sóc trọn vẹn</h3><p>Theo dõi sát sao trước, trong và sau mỗi lần điều trị.</p></div></article>
                </div>
            </div>
        </section>

        <section class="section services-section" id="services">
            <div class="container">
                <div class="section-heading"><div><p class="eyebrow"><span>●</span> DỊCH VỤ NỔI BẬT</p><h2>Nụ cười khỏe đẹp<br><em>từ bên trong.</em></h2></div><a class="text-button teal" href="<%= bookingUrl %>">Đặt lịch dịch vụ <span>→</span></a></div>
                <div class="service-grid">
                    <article class="service-card"><div class="service-art art-blue">✧</div><h3>Khám tổng quát</h3><p>Kiểm tra toàn diện, phát hiện sớm các vấn đề răng miệng.</p><a href="<%= bookingUrl %>" aria-label="Đặt khám tổng quát">→</a></article>
                    <article class="service-card"><div class="service-art art-mint">⌁</div><h3>Chăm sóc thẩm mỹ</h3><p>Tẩy trắng, dán sứ và thiết kế nụ cười tự nhiên.</p><a href="<%= bookingUrl %>" aria-label="Đặt chăm sóc thẩm mỹ">→</a></article>
                    <article class="service-card"><div class="service-art art-peach">◌</div><h3>Chỉnh nha</h3><p>Niềng răng hiện đại cho nụ cười đều đẹp và tự tin.</p><a href="<%= bookingUrl %>" aria-label="Đặt chỉnh nha">→</a></article>
                </div>
            </div>
        </section>

        <section class="section doctors-section" id="doctors">
            <div class="container doctor-panel">
                <div class="doctor-photo"><img src="https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&w=850&q=85" alt="Bác sĩ nha khoa SmileCare"></div>
                <div class="doctor-content"><p class="eyebrow"><span>●</span> ĐỘI NGŨ CHUYÊN MÔN</p><h2>Người bạn đồng hành cùng nụ cười của bạn.</h2><p>Đội ngũ SmileCare luôn lấy sự an tâm của khách hàng làm ưu tiên trong từng buổi thăm khám.</p><a class="button" href="<%= bookingUrl %>">Đặt lịch tư vấn <span>→</span></a></div>
            </div>
        </section>

        <section class="clinic-info-section" id="clinic-info">
            <div class="container clinic-profile">
                <article class="clinic-introduction">
                    <span class="clinic-label"><span>✦</span> Nha khoa tận tâm</span>
                    <h2>Chủ động lịch khám,<br><em>an tâm chăm sóc.</em></h2>
                    <p>SmileCare là phòng khám nha khoa chuyên sâu, mang đến dịch vụ chăm sóc răng miệng an toàn, tận tâm và thuận tiện cho mọi khách hàng.</p>
                    <ul class="clinic-benefits">
                        <li><span>✓</span> Chọn giờ khám phù hợp</li>
                        <li><span>✓</span> Không cần chờ lấy số</li>
                        <li><span>✓</span> Nhắc lịch trước ngày khám</li>
                        <li><span>✓</span> Hỗ trợ nhanh chóng</li>
                    </ul>
                    <a class="button clinic-booking-button" href="<%= bookingUrl %>">Đặt lịch khám ngay <span>→</span></a>
                </article>

                <aside class="clinic-sidebar" aria-label="Thông tin phòng khám">
                    <section class="clinic-info-block">
                        <div class="clinic-block-heading">
                            <span class="clinic-block-icon" aria-hidden="true">◷</span>
                            <div><small>Thời gian phục vụ</small><h3>Giờ làm việc</h3></div>
                        </div>
                        <div class="working-hours" aria-label="Giờ làm việc của phòng khám">
                            <div class="working-hours-row"><strong>Thứ 2 - Thứ 6</strong><span>7h - 18h30</span></div>
                            <div class="working-hours-row"><strong>Thứ 7</strong><span>7h30 - 18h30</span></div>
                            <div class="working-hours-row"><strong>Chủ nhật</strong><span>8h - 14h</span></div>
                        </div>
                    </section>

                    <section class="clinic-info-block support-block">
                        <div class="clinic-block-heading">
                            <span class="clinic-block-icon coral" aria-hidden="true">☎</span>
                            <div><small>Chúng tôi luôn sẵn sàng</small><h3>Tổng đài hỗ trợ</h3></div>
                        </div>
                        <p class="support-description">Nếu bạn cần thêm thông tin, vui lòng liên hệ tổng đài bên dưới để được trợ giúp.</p>
                        <div class="support-links">
                            <a href="tel:1900636227">
                                <span class="support-icon" aria-hidden="true">☎</span>
                                <span>Tổng đài bệnh viện: <strong>1900 636 227</strong></span>
                            </a>
                            <a href="<%= bookingUrl %>">
                                <span class="support-icon" aria-hidden="true">✦</span>
                                <span>Tư vấn đặt khám</span>
                            </a>
                        </div>
                    </section>
                </aside>
            </div>
        </section>
    </main>

    <jsp:include page="/WEB-INF/components/footer.jsp" />

    <script src="${pageContext.request.contextPath}/assets/js/smilecare.js"></script>
</body>
</html>
