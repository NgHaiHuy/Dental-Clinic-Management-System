document.addEventListener('DOMContentLoaded', function () {
    const tabButtons = document.querySelectorAll('.tab-button');
    const panels = document.querySelectorAll('.tab-panel');

    tabButtons.forEach(function (button) {
        button.addEventListener('click', function () {
            tabButtons.forEach(function (item) { item.classList.remove('active'); });
            panels.forEach(function (panel) { panel.classList.remove('active'); });
            button.classList.add('active');
            const panel = document.getElementById(button.dataset.tab);
            if (panel) panel.classList.add('active');
        });
    });

    document.querySelectorAll('.password-field > button').forEach(function (button) {
        button.addEventListener('click', function () {
            const input = button.parentElement.querySelector('input');
            const show = input.type === 'password';
            input.type = show ? 'text' : 'password';
            button.textContent = show ? 'Ẩn' : 'Hiện';
        });
    });
});
