document.addEventListener('DOMContentLoaded', function () {
    const menuToggle = document.querySelector('.menu-toggle');
    const mainNav = document.querySelector('.main-nav');
    if (menuToggle && mainNav) {
        menuToggle.addEventListener('click', function () {
            const isOpen = mainNav.classList.toggle('mobile-open');
            menuToggle.setAttribute('aria-expanded', String(isOpen));
        });
    }

    const accountMenu = document.querySelector('.account-menu');
    const accountTrigger = document.querySelector('.account-trigger');
    if (accountMenu && accountTrigger) {
        accountTrigger.addEventListener('click', function (event) {
            event.stopPropagation();
            const isOpen = accountMenu.classList.toggle('is-open');
            accountTrigger.setAttribute('aria-expanded', String(isOpen));
        });

        document.addEventListener('click', function () {
            accountMenu.classList.remove('is-open');
            accountTrigger.setAttribute('aria-expanded', 'false');
        });

        document.addEventListener('keydown', function (event) {
            if (event.key === 'Escape') {
                accountMenu.classList.remove('is-open');
                accountTrigger.setAttribute('aria-expanded', 'false');
            }
        });
    }
});
