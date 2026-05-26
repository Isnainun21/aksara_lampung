const music = document.getElementById('bgMusic');
const musicToggleBtn = document.getElementById('musicToggle');
const modalMusicToggle = document.getElementById('modalMusicToggle');
const modalMusicIcon = document.getElementById('modalMusicIcon');
const settingsModal = document.getElementById('settingsModal');
const openSettingsBtn = document.getElementById('openSettingsBtn');
const closeSettingsBtn = document.getElementById('closeSettingsBtn');
const splashScreen = document.getElementById('splashScreen');
const splashSkip = document.getElementById('splashSkip');
const splashAnimation = document.getElementById('splashAnimation');
const sfxTombol = new Audio('sound effect tombol.mp3');

sfxTombol.preload = 'auto';

function tutupSplash() {
    if (!splashScreen || splashScreen.classList.contains('hide')) return;
    splashScreen.classList.add('hide');
}

function mulaiSplash() {
    if (!splashScreen) return;

    const fallbackTimer = setTimeout(tutupSplash, 4500);
    splashSkip.addEventListener('click', () => {
        mainkanSfxTombol();
        tutupSplash();
    });

    if (!window.lottie || !splashAnimation) {
        splashAnimation.innerHTML = '<div class="splash-subtitle">Memuat...</div>';
        return;
    }

    const animasi = window.lottie.loadAnimation({
        container: splashAnimation,
        renderer: 'svg',
        loop: false,
        autoplay: true,
        path: 'splash.json'
    });

    animasi.addEventListener('complete', () => {
        clearTimeout(fallbackTimer);
        setTimeout(tutupSplash, 450);
    });
    animasi.addEventListener('data_failed', () => {
        clearTimeout(fallbackTimer);
        setTimeout(tutupSplash, 1200);
    });
}

mulaiSplash();

function mainkanSfxTombol() {
    sfxTombol.currentTime = 0;
    sfxTombol.play().catch(() => console.log('SFX tertahan browser atau file belum tersedia'));
}

openSettingsBtn.addEventListener('click', () => {
    mainkanSfxTombol();
    settingsModal.style.display = 'flex';
});

closeSettingsBtn.addEventListener('click', () => {
    mainkanSfxTombol();
    settingsModal.style.display = 'none';
});

document.querySelectorAll('.menu-item, .tool-box, .btn-vip').forEach(tombol => {
    tombol.addEventListener('click', mainkanSfxTombol);
});

document.body.addEventListener('click', function() {
    if (music.paused) {
        music.play().catch(() => console.log('Audio otomatis ditahan browser'));
        updateAudioUI(true);
    }
}, { once: true });

function toggleMusic() {
    mainkanSfxTombol();
    if (music.paused) {
        music.play();
        updateAudioUI(true);
    } else {
        music.pause();
        updateAudioUI(false);
    }
}

function updateAudioUI(isPlaying) {
    if (isPlaying) {
        musicToggleBtn.textContent = '\uD83D\uDD0A';
        modalMusicIcon.textContent = '\uD83C\uDFB5';
    } else {
        musicToggleBtn.textContent = '\uD83D\uDD07';
        modalMusicIcon.textContent = '\u2715';
    }
}

musicToggleBtn.addEventListener('click', toggleMusic);
modalMusicToggle.addEventListener('click', toggleMusic);

document.getElementById('homeSongPoint').textContent = localStorage.getItem('poinNyani') || '0';
document.getElementById('homeWritePoint').textContent = localStorage.getItem('latihanNulis') || '0';
document.getElementById('homeQuizPoint').textContent = localStorage.getItem('skorAksaraLampung') || '0';
document.getElementById('homeLangPoint').textContent = localStorage.getItem('bahasaStars') || '0';
