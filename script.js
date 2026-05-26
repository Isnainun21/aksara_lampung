// =======================================================
// 1. AMBIL ELEMEN-ELEMEN DARI HTML
// =======================================================
const music = document.getElementById('bgMusic');
const musicToggleBtn = document.getElementById('musicToggle');
const modalMusicToggle = document.getElementById('modalMusicToggle');
const modalMusicIcon = document.getElementById('modalMusicIcon');
const settingsModal = document.getElementById('settingsModal');
const openSettingsBtn = document.getElementById('openSettingsBtn');
const closeSettingsBtn = document.getElementById('closeSettingsBtn');

// =======================================================
// 🎛️ TENTARA BARU: BUAT AUDIO SPEAKER KHUSUS LEWAT JS
// =======================================================
// Membuat objek audio baru langsung di JS biar file HTML lo tetep bersih
const sfxTombol = new Audio('sound effect tombol.mp3'); 
sfxTombol.preload = 'auto'; // Biar suaranya langsung siap pas di-klik tanpa delay

// Fungsi utama untuk membunyikan efek suara 1 detik lo
function mainkanSfxTombol() {
    sfxTombol.currentTime = 0; // Reset durasi ke 0 biar kalau di-klik cepet gak kepotong delay
    sfxTombol.play().catch(err => console.log("SFX tertahan sistem keamanan browser"));
}

// =======================================================
// ⚙️ LOGIKA PENGATURAN (OPEN/CLOSE MODAL) + EFEK SUARA
// =======================================================

// Pas tombol Gear Pengaturan diklik -> Bunyi suara + JS Box Muncul
openSettingsBtn.addEventListener('click', () => { 
    mainkanSfxTombol(); // 🔊 Efek suara berbunyi tepat saat di-klik
    settingsModal.style.display = 'flex'; // 🎬 Modal pop-up muncul
});

// Pas tombol Silang (Close) diklik -> Bunyi suara + JS Box Hilang
closeSettingsBtn.addEventListener('click', () => { 
    mainkanSfxTombol(); // 🔊 Efek suara berbunyi
    settingsModal.style.display = 'none'; // 🎬 Modal ditutup
});

// =======================================================
// 🎮 OTOMATIS PASANG EFEK SUARA PADA TOMBOL LAINNYA
// =======================================================
// Kode sakti ini nyari tombol Menu Utama, Pilihan di dalam Setting, dan tombol VIP 
// Biar pas di-klik langsung ngeluarin efek suara 1 detik lo, jadi game gak sepi!
document.querySelectorAll('.menu-item, .tool-box, .btn-vip').forEach(tombol => {
    tombol.addEventListener('click', mainkanSfxTombol);
});

// =======================================================
// 🎵 LOGIKA PENGATUR AUDIO BACKGROUND (BAMUS)
// =======================================================

// Autoplay Musik saat pertama kali layar disentuh/di-klik (Bypass block sistem browser)
document.body.addEventListener('click', function() {
    if (music.paused) {
        music.play().catch(err => console.log("Audio otomatis ditahan oleh sistem browser"));
        updateAudioUI(true);
    }
}, { once: true });

// Fungsi On/Off Musik Latar
function toggleMusic() {
    mainkanSfxTombol(); // Tombol musik pun kalau diklik ikut bunyi sfx pendek lo
    if (music.paused) {
        music.play();
        updateAudioUI(true);
    } else {
        music.pause();
        updateAudioUI(false);
    }
}

// Update Tampilan Icon On/Off Speaker Musik
function updateAudioUI(isPlaying) {
    if(isPlaying) {
        musicToggleBtn.textContent = '🔊';
        modalMusicIcon.textContent = '🎵';
    } else {
        musicToggleBtn.textContent = '🔇';
        modalMusicIcon.textContent = '❌';
    }
}

// Event klik untuk On/Off musik latar
musicToggleBtn.addEventListener('click', toggleMusic);
modalMusicToggle.addEventListener('click', toggleMusic);