(function () {
    'use strict';

    var detailButtons = Array.prototype.slice.call(document.querySelectorAll('[data-details-target]'));

    function setDetailState(button, expanded) {
        var targetId = button.getAttribute('data-details-target');
        var detailRow = targetId ? document.getElementById(targetId) : null;
        var recordRow = button.closest('.record-row');
        var label = button.querySelector('span');

        if (!detailRow) {
            return;
        }

        button.setAttribute('aria-expanded', expanded ? 'true' : 'false');
        detailRow.hidden = !expanded;
        if (recordRow) {
            recordRow.classList.toggle('is-open', expanded);
        }
        if (label) {
            label.textContent = expanded ? 'Thu gọn' : 'Xem chi tiết';
        }
    }

    function closeOtherDetails(activeButton) {
        detailButtons.forEach(function (button) {
            if (button !== activeButton && button.getAttribute('aria-expanded') === 'true') {
                setDetailState(button, false);
            }
        });
    }

    detailButtons.forEach(function (button) {
        button.addEventListener('click', function () {
            var shouldOpen = button.getAttribute('aria-expanded') !== 'true';
            if (shouldOpen) {
                closeOtherDetails(button);
            }
            setDetailState(button, shouldOpen);
        });
    });

    document.addEventListener('keydown', function (event) {
        if (event.key !== 'Escape') {
            return;
        }
        detailButtons.forEach(function (button) {
            if (button.getAttribute('aria-expanded') === 'true') {
                setDetailState(button, false);
                button.focus();
            }
        });
    });

    var form = document.getElementById('historyFilterForm');
    var fromDate = document.getElementById('fromDate');
    var toDate = document.getElementById('toDate');
    var submitButton = document.getElementById('filterSubmitButton');

    function syncDateLimits() {
        if (!fromDate || !toDate) {
            return;
        }
        toDate.min = fromDate.value || '';
        fromDate.max = toDate.value || '';
    }

    if (fromDate && toDate) {
        syncDateLimits();
        fromDate.addEventListener('change', syncDateLimits);
        toDate.addEventListener('change', syncDateLimits);
    }

    if (form && submitButton) {
        form.addEventListener('submit', function (event) {
            if (!form.checkValidity()) {
                event.preventDefault();
                form.reportValidity();
                return;
            }
            submitButton.disabled = true;
            var label = submitButton.querySelector('span');
            if (label) {
                label.textContent = 'Đang tìm...';
            }
        });
    }

    window.addEventListener('pageshow', function () {
        if (!submitButton) {
            return;
        }
        submitButton.disabled = false;
        var label = submitButton.querySelector('span');
        if (label) {
            label.textContent = 'Tìm kiếm';
        }
    });
}());
