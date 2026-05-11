(function () {
    'use strict';

    if (window.__tubePiP_installed) return;
    window.__tubePiP_installed = true;

    window.__tubePiP_requestPiP = function () {
        const video = findMainVideo();
        if (!video) {
            postMessage('pipUnsupported', 'No video element found');
            return;
        }
        if (video.paused) {
            video.play().catch(function () {});
        }
        if (typeof video.requestPictureInPicture === 'function') {
            video.requestPictureInPicture()
                .catch(function (err) {
                    tryWebKitPiP(video);
                });
        } else {
            tryWebKitPiP(video);
        }
    };

    function tryWebKitPiP(video) {
        if (typeof video.webkitSetPresentationMode === 'function') {
            try {
                video.webkitSetPresentationMode('picture-in-picture');
            } catch (e) {
                postMessage('pipUnsupported', 'webkit fallback failed: ' + e.message);
            }
        } else {
            postMessage('pipUnsupported', 'No PiP API available');
        }
    }

    function findMainVideo() {
        var videos = Array.from(document.querySelectorAll('video'));
        if (!videos.length) return null;
        var playing = videos.filter(function (v) { return !v.paused && v.duration > 10; });
        if (playing.length) {
            return playing.reduce(function (a, b) { return a.duration > b.duration ? a : b; });
        }
        return videos.reduce(function (a, b) { return (a.duration || 0) > (b.duration || 0) ? a : b; });
    }

    function extractAndSendTitle() {
        var selectors = [
            'h1.ytm-video-title',
            'h1[class*="title"]',
            '.slim-video-information-title',
            'title'
        ];
        for (var i = 0; i < selectors.length; i++) {
            var el = document.querySelector(selectors[i]);
            if (el && el.textContent.trim()) {
                var clean = el.textContent.trim().replace(/ - YouTube$/, '').trim();
                if (clean) {
                    postMessage('title', clean);
                    return;
                }
            }
        }
    }

    var observer = new MutationObserver(function () {
        extractAndSendTitle();
    });
    observer.observe(document.body || document.documentElement, {
        childList: true,
        subtree: true
    });

    if (document.readyState === 'complete' || document.readyState === 'interactive') {
        setTimeout(extractAndSendTitle, 800);
    } else {
        document.addEventListener('DOMContentLoaded', function () {
            setTimeout(extractAndSendTitle, 800);
        });
    }

    function postMessage(type, value) {
        if (window.webkit &&
            window.webkit.messageHandlers &&
            window.webkit.messageHandlers.tubePiP) {
            window.webkit.messageHandlers.tubePiP.postMessage({ type: type, value: value });
        }
    }

}());
