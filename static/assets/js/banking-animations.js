/**
 * MyRoanokeHeritage Bank - Dynamic Animations
 * Modern banking website interactions like Chase, Bank of America, etc.
 */

(function ($) {
    'use strict';

    // ========================================
    // 1. ANIMATED NUMBER COUNTERS (like BoA stats)
    // ========================================
    function animateCounters() {
        $('.counter').each(function () {
            const $this = $(this);
            const countTo = $this.text();

            $({ countNum: 0 }).animate({
                countNum: countTo
            }, {
                duration: 2000,
                easing: 'swing',
                step: function () {
                    $this.text(Math.floor(this.countNum));
                },
                complete: function () {
                    $this.text(this.countNum);
                }
            });
        });
    }

    // ========================================
    // 2. FEATURE CARDS HOVER PARALLAX (like Chase cards)
    // ========================================
    function initCardParallax() {
        $('.single-item, .single-box').on('mousemove', function (e) {
            const card = $(this);
            const rect = this.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;

            const centerX = rect.width / 2;
            const centerY = rect.height / 2;

            const rotateX = (y - centerY) / 20;
            const rotateY = (centerX - x) / 20;

            card.css({
                'transform': `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale(1.02)`,
                'transition': 'transform 0.1s ease-out'
            });
        });

        $('.single-item, .single-box').on('mouseleave', function () {
            $(this).css({
                'transform': 'perspective(1000px) rotateX(0) rotateY(0) scale(1)',
                'transition': 'transform 0.3s ease-out'
            });
        });
    }

    // ========================================
    // 3. SMOOTH SCROLL REVEAL (Progressive Enhancement)
    // ========================================
    function initScrollReveal() {
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('revealed');
                }
            });
        }, {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        });

        document.querySelectorAll('.reveal-on-scroll').forEach(el => {
            observer.observe(el);
        });
    }

    // ========================================
    // 4. TESTIMONIAL AUTO-ROTATE (like Capital One)
    // ========================================
    function initTestimonialRotation() {
        if ($('.testimonials-carousel').length) {
            $('.testimonials-carousel').slick({
                autoplay: true,
                autoplaySpeed: 5000,
                speed: 800,
                fade: true,
                cssEase: 'cubic-bezier(0.4, 0, 0.2, 1)',
                pauseOnHover: true,
                pauseOnFocus: true
            });
        }
    }

    // ========================================
    // 5. PROGRESS BARS ANIMATION
    // ========================================
    function animateProgressBars() {
        $('.progress-bar').each(function () {
            const $bar = $(this);
            const width = $bar.data('width');

            $bar.css({
                'width': '0%',
                'transition': 'width 1.5s ease-out'
            });

            setTimeout(() => {
                $bar.css('width', width + '%');
            }, 100);
        });
    }

    // ========================================
    // 6. ICON BOUNCE ANIMATION (on scroll into view)
    // ========================================
    function initIconAnimations() {
        const iconObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const icon = entry.target.querySelector('img');
                    if (icon) {
                        icon.classList.add('icon-bounce');
                        setTimeout(() => {
                            icon.classList.remove('icon-bounce');
                        }, 1000);
                    }
                }
            });
        }, { threshold: 0.5 });

        document.querySelectorAll('.single-item, .single-box').forEach(el => {
            iconObserver.observe(el);
        });
    }

    // ========================================
    // 7. NAVBAR SCROLL EFFECT (like Wells Fargo)
    // ========================================
    function initNavbarScroll() {
        let lastScroll = 0;

        $(window).on('scroll', function () {
            const currentScroll = $(this).scrollTop();
            const navbar = $('.header-section');

            if (currentScroll > 100) {
                navbar.addClass('scrolled');
            } else {
                navbar.removeClass('scrolled');
            }

            // Hide on scroll down, show on scroll up
            if (currentScroll > lastScroll && currentScroll > 300) {
                navbar.addClass('nav-hidden');
            } else {
                navbar.removeClass('nav-hidden');
            }

            lastScroll = currentScroll;
        });
    }

    // ========================================
    // 8. STATISTIC COUNTER WITH SCROLL TRIGGER
    // ========================================
    function initStatCounters() {
        let triggered = false;

        $(window).on('scroll', function () {
            const counterSection = $('.counter-section');

            if (counterSection.length && !triggered) {
                const sectionTop = counterSection.offset().top;
                const windowBottom = $(window).scrollTop() + $(window).height();

                if (windowBottom > sectionTop + 100) {
                    triggered = true;
                    animateCounters();
                }
            }
        });
    }

    // ========================================
    // 9. BUTTON RIPPLE EFFECT (Material Design style)
    // ========================================
    function initButtonRipple() {
        $('.cmn-btn, .cmdn-btn').on('click', function (e) {
            const button = $(this);
            const ripple = $('<span class="ripple"></span>');

            const diameter = Math.max(button.width(), button.height());
            const radius = diameter / 2;

            ripple.css({
                width: diameter,
                height: diameter,
                left: e.pageX - button.offset().left - radius,
                top: e.pageY - button.offset().top - radius
            });

            button.append(ripple);

            setTimeout(() => {
                ripple.remove();
            }, 600);
        });
    }

    // ========================================
    // 10. PARALLAX SCROLL EFFECT
    // ========================================
    function initParallax() {
        $(window).on('scroll', function () {
            const scrolled = $(this).scrollTop();

            $('.parallax-slow').css('transform', `translateY(${scrolled * 0.3}px)`);
            $('.parallax-fast').css('transform', `translateY(${scrolled * -0.2}px)`);
        });
    }

    // ========================================
    // 11. TYPEWRITER EFFECT FOR HERO TEXT
    // ========================================
    function initTypewriter() {
        const element = $('.typewriter-text');
        if (element.length) {
            const text = element.text();
            element.text('');
            element.css('display', 'inline-block');

            let i = 0;
            function type() {
                if (i < text.length) {
                    element.text(element.text() + text.charAt(i));
                    i++;
                    setTimeout(type, 50);
                }
            }

            setTimeout(type, 500);
        }
    }

    // ========================================
    // 12. LAZY LOAD IMAGES
    // ========================================
    function initLazyLoad() {
        if ('IntersectionObserver' in window) {
            const imageObserver = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        const img = entry.target;
                        img.src = img.dataset.src;
                        img.classList.add('loaded');
                        imageObserver.unobserve(img);
                    }
                });
            });

            document.querySelectorAll('img[data-src]').forEach(img => {
                imageObserver.observe(img);
            });
        }
    }

    // ========================================
    // 13. CARD FLIP INTERACTION
    // ========================================
    function initCardFlip() {
        $('.flip-card').on('click', function () {
            $(this).toggleClass('flipped');
        });
    }

    // ========================================
    // INITIALIZE ALL ON PAGE LOAD
    // ========================================
    $(document).ready(function () {
        // Core animations
        initStatCounters();
        initCardParallax();
        initScrollReveal();
        initIconAnimations();

        // Navigation effects
        initNavbarScroll();

        // Interactive elements
        initButtonRipple();
        initCardFlip();
        initTestimonialRotation();

        // Performance optimizations
        initLazyLoad();

        // NEW: More live effects (cursor follower and text glitch removed)
        // initMouseFollower(); // DISABLED - not nice
        initParticleBackground();
        // initTextGlitch(); // DISABLED - annoying text changes
        initProgressBars();
        initGradientAnimation();
        initFloatingElements();
        initCountdownTimer();
        initTooltips();

        console.log('🏦 Banking animations initialized');
    });

    // ========================================
    // NEW LIVE FEATURES
    // ========================================

    // Mouse follower effect (subtle cursor trail)
    function initMouseFollower() {
        let mouseX = 0, mouseY = 0;
        let ballX = 0, ballY = 0;
        const speed = 0.2;

        const $cursor = $('<div class="cursor-follower"></div>');
        $('body').append($cursor);

        $(document).on('mousemove', function (e) {
            mouseX = e.clientX;
            mouseY = e.clientY;
        });

        function animate() {
            let distX = mouseX - ballX;
            let distY = mouseY - ballY;

            ballX += distX * speed;
            ballY += distY * speed;

            $cursor.css({
                left: ballX + 'px',
                top: ballY + 'px'
            });

            requestAnimationFrame(animate);
        }
        animate();

        // Hide on link hover
        $('a, button').hover(
            function () { $cursor.addClass('cursor-hidden'); },
            function () { $cursor.removeClass('cursor-hidden'); }
        );
    }

    // Floating particle background effect
    function initParticleBackground() {
        const canvas = $('<canvas id="particle-canvas"></canvas>');
        $('.banner-section').prepend(canvas);

        const ctx = canvas[0].getContext('2d');
        canvas[0].width = window.innerWidth;
        canvas[0].height = window.innerHeight;

        const particles = [];
        const particleCount = 50;

        for (let i = 0; i < particleCount; i++) {
            particles.push({
                x: Math.random() * canvas[0].width,
                y: Math.random() * canvas[0].height,
                radius: Math.random() * 2 + 1,
                vx: (Math.random() - 0.5) * 0.5,
                vy: (Math.random() - 0.5) * 0.5
            });
        }

        function drawParticles() {
            ctx.clearRect(0, 0, canvas[0].width, canvas[0].height);
            ctx.fillStyle = 'rgba(0, 84, 129, 0.3)';

            particles.forEach(p => {
                p.x += p.vx;
                p.y += p.vy;

                if (p.x < 0 || p.x > canvas[0].width) p.vx *= -1;
                if (p.y < 0 || p.y > canvas[0].height) p.vy *= -1;

                ctx.beginPath();
                ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
                ctx.fill();
            });

            requestAnimationFrame(drawParticles);
        }
        drawParticles();
    }

    // Text glitch effect on hover
    function initTextGlitch() {
        $('.title').hover(
            function () {
                const $this = $(this);
                const original = $this.text();
                let count = 0;

                const glitchInterval = setInterval(() => {
                    if (count > 3) {
                        clearInterval(glitchInterval);
                        $this.text(original);
                        return;
                    }
                    const glitchText = original.split('').map(char =>
                        Math.random() > 0.9 ? String.fromCharCode(65 + Math.floor(Math.random() * 26)) : char
                    ).join('');
                    $this.text(glitchText);
                    count++;
                }, 50);
            }
        );
    }

    // Animated progress bars
    function initProgressBars() {
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const bar = $(entry.target);
                    const width = bar.data('progress');
                    bar.css('width', width + '%');
                }
            });
        }, { threshold: 0.5 });

        $('.progress-bar').each(function () {
            observer.observe(this);
        });
    }

    // Background gradient animation
    function initGradientAnimation() {
        let hue = 0;
        setInterval(() => {
            hue = (hue + 1) % 360;
            $('.animated-gradient-bg').css({
                'background': `linear-gradient(135deg,
                    hsl(${hue}, 70%, 30%),
                    hsl(${(hue + 60) % 360}, 70%, 40%))`
            });
        }, 50);
    }

    // Make elements float continuously
    function initFloatingElements() {
        $('.banner-content img').each(function (index) {
            $(this).addClass(`float-animation${index % 3 === 0 ? '-slow' : index % 2 === 0 ? '-delayed' : ''}`);
        });
    }

    // Live countdown timer (for promotions)
    function initCountdownTimer() {
        $('.countdown-timer').each(function () {
            const endDate = new Date($(this).data('end-date'));
            const $this = $(this);

            setInterval(() => {
                const now = new Date();
                const diff = endDate - now;

                if (diff <= 0) {
                    $this.text('Offer Ended');
                    return;
                }

                const days = Math.floor(diff / (1000 * 60 * 60 * 24));
                const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                const mins = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
                const secs = Math.floor((diff % (1000 * 60)) / 1000);

                $this.html(`${days}d ${hours}h ${mins}m ${secs}s`);
            }, 1000);
        });
    }

    // Interactive tooltips
    function initTooltips() {
        $('[data-tooltip]').hover(
            function (e) {
                const text = $(this).data('tooltip');
                const $tooltip = $(`<div class="custom-tooltip">${text}</div>`);
                $('body').append($tooltip);

                $tooltip.css({
                    top: e.pageY - 40 + 'px',
                    left: e.pageX - ($tooltip.width() / 2) + 'px'
                }).addClass('show');
            },
            function () {
                $('.custom-tooltip').remove();
            }
        );
    }

    // Re-trigger on window resize (debounced)
    let resizeTimer;
    $(window).on('resize', function () {
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(function () {
            // Re-initialize specific features if needed
        }, 250);
    });

})(jQuery);
