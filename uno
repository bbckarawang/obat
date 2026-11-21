html
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>UNO Party P2P - Multiplayer Tanpa Server</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- PeerJS untuk koneksi WebRTC P2P antar HP -->
    <script src="https://unpkg.com/peerjs@1.5.4/dist/peerjs.min.js"></script>
    <!-- Google Fonts: Fredoka & Inter untuk nuansa game kasual modern -->
    <link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@600;700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --uno-red: #ef4444;
            --uno-yellow: #eab308;
            --uno-green: #22c55e;
            --uno-blue: #3b82f6;
            --uno-dark: #18181b;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: radial-gradient(circle at center, #1e293b 0%, #0f172a 70%, #090d16 100%);
            color: #f8fafc;
            overflow-x: hidden;
            user-select: none;
            -webkit-tap-highlight-color: transparent;
        }

        .font-game {
            font-family: 'Fredoka', sans-serif;
        }

        /* Desain Kartu UNO Klasik */
        .uno-card {
            position: relative;
            width: 72px;
            height: 108px;
            border-radius: 12px;
            background-color: #ffffff;
            padding: 5px;
            box-shadow: 0 6px 15px rgba(0, 0, 0, 0.45), inset 0 0 0 1px rgba(255,255,255,0.4);
            transition: transform 0.22s cubic-bezier(0.34, 1.56, 0.64, 1), box-shadow 0.2s ease, opacity 0.2s ease;
            flex-shrink: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
        }

        @media (min-width: 640px) {
            .uno-card {
                width: 84px;
                height: 126px;
                border-radius: 14px;
                padding: 6px;
            }
        }

        .uno-card-inner {
            width: 100%;
            height: 100%;
            border-radius: 8px;
            position: relative;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* Warna Kartu */
        .card-red .uno-card-inner { background: linear-gradient(135deg, #f87171 0%, #dc2626 100%); }
        .card-yellow .uno-card-inner { background: linear-gradient(135deg, #facc15 0%, #ca8a04 100%); }
        .card-green .uno-card-inner { background: linear-gradient(135deg, #4ade80 0%, #16a34a 100%); }
        .card-blue .uno-card-inner { background: linear-gradient(135deg, #60a5fa 0%, #2563eb 100%); }
        .card-wild .uno-card-inner { 
            background: conic-gradient(from 45deg, #ef4444 0deg 90deg, #3b82f6 90deg 180deg, #eab308 180deg 270deg, #22c55e 270deg 360deg);
        }

        /* Oval Putih di Tengah Kartu */
        .uno-oval {
            width: 86%;
            height: 68%;
            background: #ffffff;
            border-radius: 50%;
            transform: rotate(-28deg);
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: inset 0 2px 5px rgba(0,0,0,0.2);
        }

        .uno-symbol-center {
            transform: rotate(28deg);
            font-family: 'Fredoka', sans-serif;
            font-weight: 700;
            font-size: 2rem;
            line-height: 1;
            text-shadow: 1px 2px 0px rgba(0,0,0,0.18);
        }

        @media (min-width: 640px) {
            .uno-symbol-center { font-size: 2.35rem; }
        }

        .text-card-red { color: #dc2626; }
        .text-card-yellow { color: #ca8a04; }
        .text-card-green { color: #16a34a; }
        .text-card-blue { color: #2563eb; }
        .text-card-wild { 
            background: linear-gradient(135deg, #dc2626, #ca8a04, #16a34a, #2563eb);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        /* Simbol Pojok Kartu */
        .uno-corner {
            position: absolute;
            font-family: 'Fredoka', sans-serif;
            font-weight: 700;
            font-size: 0.78rem;
            color: #ffffff;
            text-shadow: 0 1px 2px rgba(0,0,0,0.5);
            line-height: 1;
        }
        .uno-corner-tl { top: 4px; left: 5px; }
        .uno-corner-br { bottom: 4px; right: 5px; transform: rotate(180deg); }

        /* Bagian Belakang Kartu (Deck) */
        .uno-card-back {
            background: #ffffff;
            padding: 5px;
        }
        .uno-card-back .uno-card-inner {
            background: radial-gradient(circle, #27272a 0%, #09090b 100%);
        }
        .uno-back-logo {
            background: #ef4444;
            color: #facc15;
            font-family: 'Fredoka', sans-serif;
            font-weight: 700;
            font-size: 1.05rem;
            padding: 3px 10px;
            border-radius: 999px;
            transform: rotate(-28deg);
            border: 2px solid #ffffff;
            text-shadow: 1px 1px 0 #000;
            letter-spacing: 0.5px;
        }

        /* Interaksi Kartu di Tangan Pemain */
        .hand-card-playable {
            transform: translateY(-10px);
            box-shadow: 0 10px 22px rgba(250, 204, 21, 0.45), 0 0 0 2.5px #facc15;
        }
        .hand-card-playable:hover, .hand-card-playable:active {
            transform: translateY(-18px) scale(1.05);
        }
        .hand-card-disabled {
            opacity: 0.58;
            filter: grayscale(25%);
            cursor: not-allowed;
        }

        /* Animasi & Sorotan Giliran */
        @keyframes pulseGlow {
            0%, 100% { box-shadow: 0 0 0 0 rgba(250, 204, 21, 0.7); }
            50% { box-shadow: 0 0 0 8px rgba(250, 204, 21, 0); }
        }
        .active-turn-ring {
            animation: pulseGlow 1.6s infinite;
            border-color: #facc15 !important;
        }

        @keyframes spinSlow {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }
        @keyframes spinSlowReverse {
            from { transform: rotate(360deg); }
            to { transform: rotate(0deg); }
        }
        .spin-cw { animation: spinSlow 10s linear infinite; }
        .spin-ccw { animation: spinSlowReverse 10s linear infinite; }

        /* Scrollbar halus untuk tangan kartu */
        .no-scrollbar::-webkit-scrollbar { display: none; }
        .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
    </style>
</head>
<body class="min-h-screen flex flex-col justify-between">

    <!-- Top Navigation / Status Bar -->
    <header class="w-full px-3 py-2.5 bg-slate-900/80 backdrop-blur-md border-b border-slate-800 flex items-center justify-between z-30">
        <div class="flex items-center gap-2">
            <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-red-500 via-yellow-500 to-blue-500 flex items-center justify-center shadow-md">
                <span class="font-game text-white text-sm font-bold tracking-tighter">UNO</span>
            </div>
            <div>
                <h1 class="font-game text-base sm:text-lg leading-none text-white">UNO Party P2P</h1>
                <p id="header-conn-status" class="text-[11px] text-slate-400 flex items-center gap-1 mt-0.5">
                    <span class="w-2 h-2 rounded-full bg-amber-400 inline-block"></span> Siap Bermain
                </p>
            </div>
        </div>

        <div class="flex items-center gap-2">
            <!-- Tombol Panduan Singkat -->
            <button onclick="toggleModal('rules-modal', true)" class="p-2 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs font-medium border border-slate-700 transition" title="Aturan Main">
                ❓ Aturan
            </button>
            <!-- Tombol Mute/Unmute Audio -->
            <button id="btn-sound" onclick="toggleSound()" class="p-2 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 transition" title="Suara">
                🔊
            </button>
            <!-- Tombol Keluar Room (muncul saat di lobby/game) -->
            <button id="btn-leave" onclick="confirmLeaveGame()" class="hidden px-2.5 py-2 rounded-xl bg-red-500/20 hover:bg-red-500/30 text-red-300 border border-red-500/30 text-xs font-semibold transition">
                Keluar
            </button>
        </div>
    </header>

    <!-- Toast Notification Banner -->
    <div id="toast-container" class="fixed top-16 left-1/2 -translate-x-1/2 z-50 flex flex-col items-center gap-2 pointer-events-none w-11/12 max-w-sm"></div>

    <!-- ========================================================= -->
    <!-- VIEW 1: HALAMAN UTAMA (BUAT ROOM / GABUNG ROOM)           -->
    <!-- ========================================================= -->
    <main id="view-home" class="flex-1 flex flex-col items-center justify-center p-4 max-w-md mx-auto w-full">
        <div class="w-full bg-slate-900/90 border border-slate-800 rounded-3xl p-6 shadow-2xl backdrop-blur-lg">
            <!-- Logo Hero -->
            <div class="text-center mb-6">
                <div class="inline-flex items-center justify-center gap-1.5 mb-3">
                    <span class="w-9 h-12 rounded-lg bg-red-500 text-white font-game font-bold text-xl flex items-center justify-center -rotate-12 shadow-lg border-2 border-white">U</span>
                    <span class="w-9 h-12 rounded-lg bg-yellow-400 text-slate-900 font-game font-bold text-xl flex items-center justify-center -translate-y-1 shadow-lg border-2 border-white">N</span>
                    <span class="w-9 h-12 rounded-lg bg-green-500 text-white font-game font-bold text-xl flex items-center justify-center rotate-12 shadow-lg border-2 border-white">O</span>
                </div>
                <h2 class="font-game text-2xl text-white">Main UNO Bareng Teman</h2>
                <p class="text-xs text-slate-400 mt-1">Koneksi langsung antar HP via WebRTC P2P (2–8 Pemain, Tanpa Server/Firebase)</p>
            </div>

            <!-- Input Nama Pemain -->
            <div class="mb-5">
                <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">Nama Panggilan Kamu</label>
                <input type="text" id="input-player-name" maxlength="14" placeholder="Contoh: Budi, Sari, Andra..."
                    class="w-full px-4 py-3 rounded-xl bg-slate-800/90 border border-slate-700 text-white placeholder-slate-500 focus:outline-none focus:border-yellow-400 focus:ring-1 focus:ring-yellow-400 text-sm font-medium">
            </div>

            <!-- Tombol Buat Room Baru (Host) -->
            <button id="btn-create-room" onclick="createRoom()"
                class="w-full py-3.5 px-4 rounded-xl bg-gradient-to-r from-red-500 via-amber-500 to-yellow-500 hover:brightness-110 active:scale-[0.98] text-slate-950 font-game font-bold text-base shadow-lg shadow-amber-500/20 transition flex items-center justify-center gap-2">
                <span>👑</span> Buat Room Baru (Jadi Host)
            </button>

            <div class="relative my-5 flex items-center justify-center">
                <div class="border-t border-slate-800 w-full"></div>
                <span class="bg-slate-900 px-3 text-xs text-slate-500 font-medium">ATAU GABUNG ROOM</span>
                <div class="border-t border-slate-800 w-full"></div>
            </div>

            <!-- Form Gabung Room (Client) -->
            <div class="flex gap-2">
                <input type="text" id="input-room-code" maxlength="6" placeholder="KODE ROOM"
                    oninput="this.value = this.value.toUpperCase().replace(/[^A-Z0-9]/g, '')"
                    class="w-3/5 px-4 py-3 rounded-xl bg-slate-800/90 border border-slate-700 text-center font-game tracking-widest text-lg text-yellow-400 placeholder-slate-600 uppercase focus:outline-none focus:border-blue-400">
                <button id="btn-join-room" onclick="joinRoom()"
                    class="w-2/5 py-3 px-4 rounded-xl bg-blue-600 hover:bg-blue-500 active:scale-[0.98] text-white font-game font-bold text-base shadow-lg shadow-blue-600/25 transition">
                    Gabung
                </button>
            </div>
        </div>

        <p class="text-[11px] text-slate-500 text-center mt-4 max-w-xs">
            Tips: Pastikan semua HP terhubung ke internet (Wi-Fi atau Data Seluler) agar sinyal P2P terhubung lancar.
        </p>
    </main>

    <!-- ========================================================= -->
    <!-- VIEW 2: LOBBY RUANG TUNGGU                                -->
    <!-- ========================================================= -->
    <section id="view-lobby" class="hidden flex-1 flex flex-col items-center justify-center p-4 max-w-md mx-auto w-full">
        <div class="w-full bg-slate-900/90 border border-slate-800 rounded-3xl p-5 shadow-2xl">
            <!-- Info Kode Room -->
            <div class="bg-slate-950/80 border border-slate-800 rounded-2xl p-4 text-center mb-4">
                <span class="text-[11px] uppercase tracking-widest text-slate-400 font-semibold">Kode Room Permainan</span>
                <div class="flex items-center justify-center gap-3 mt-1">
                    <span id="lobby-room-code" class="font-game text-3xl sm:text-4xl tracking-widest text-yellow-400 select-all">-----</span>
                    <button onclick="copyRoomCode()" class="px-3 py-1.5 rounded-xl bg-slate-800 hover:bg-slate-700 active:scale-95 text-xs font-semibold text-white border border-slate-700 flex items-center gap-1 transition">
                        📋 Salin
                    </button>
                </div>
                <p class="text-[11px] text-slate-400 mt-1.5">Bagikan kode 5 huruf ini ke HP temanmu untuk bergabung</p>
            </div>

            <!-- Daftar Pemain Terhubung -->
            <div class="flex items-center justify-between mb-2">
                <h3 class="text-xs font-bold uppercase tracking-wider text-slate-300">Pemain di Room (<span id="lobby-player-count">1</span>/8)</h3>
                <button id="btn-add-bot" onclick="addBotPlayer()" class="hidden text-xs px-2.5 py-1 rounded-lg bg-emerald-500/20 hover:bg-emerald-500/30 text-emerald-300 border border-emerald-500/30 font-semibold transition">
                    + Tambah Bot AI
                </button>
            </div>

            <div id="lobby-player-list" class="space-y-2 max-h-60 overflow-y-auto pr-1 mb-5">
                <!-- Item pemain dirender via JS -->
            </div>

            <!-- Tombol Mulai Game (Khusus Host) -->
            <div id="host-lobby-controls" class="hidden">
                <button id="btn-start-game" onclick="startGame()"
                    class="w-full py-3.5 px-4 rounded-xl bg-gradient-to-r from-emerald-500 to-green-600 hover:brightness-110 active:scale-[0.98] text-white font-game font-bold text-lg shadow-lg shadow-emerald-600/30 transition">
                    🚀 Mulai Permainan!
                </button>
            </div>

            <!-- Pesan Menunggu (Khusus Client) -->
            <div id="client-lobby-wait" class="hidden text-center py-3 px-4 rounded-xl bg-slate-800/60 border border-slate-700/60">
                <p class="text-xs text-slate-300 animate-pulse">⏳ Menunggu Host memulai permainan...</p>
            </div>
        </div>
    </section>

    <!-- ========================================================= -->
    <!-- VIEW 3: ARENA PERMAINAN UNO (BOARD)                       -->
    <!-- ========================================================= -->
    <section id="view-game" class="hidden flex-1 flex flex-col justify-between overflow-hidden relative">
        
        <!-- AREA ATAS: Daftar Pemain Lawan -->
        <div class="w-full px-2 pt-2 pb-1">
            <div id="opponents-bar" class="flex items-center justify-start sm:justify-center gap-2 overflow-x-auto no-scrollbar py-1 px-1">
                <!-- Kartu status lawan dirender di sini -->
            </div>
        </div>

        <!-- AREA TENGAH: Meja Permainan (Arah Putaran, Deck, Discard Pile, Indikator Warna) -->
        <div class="flex-1 flex flex-col items-center justify-center relative px-4 my-1">
            
            <!-- Banner Status Giliran & Aksi Terakhir -->
            <div class="mb-3 text-center">
                <div id="turn-indicator-badge" class="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-slate-900/90 border border-slate-700 shadow-md">
                    <span id="direction-icon" class="text-base inline-block spin-cw">🔄</span>
                    <span id="turn-text" class="font-game text-sm sm:text-base text-white">Giliran Pemain...</span>
                </div>
                <p id="last-action-log" class="text-[11px] text-slate-400 mt-1 h-4 truncate max-w-xs mx-auto">Permainan dimulai!</p>
            </div>

            <!-- Meja Tengah: Deck + Discard + Indikator Warna Aktif -->
            <div class="relative flex items-center justify-center gap-6 sm:gap-10 my-1">
                
                <!-- Tumpukan Ambil Kartu (DRAW DECK) -->
                <div class="flex flex-col items-center">
                    <div id="draw-pile-card" onclick="handleDrawCardClick()" class="uno-card uno-card-back active:scale-95 transition relative">
                        <div class="uno-card-inner">
                            <span class="uno-back-logo">UNO</span>
                        </div>
                        <span id="deck-count-badge" class="absolute -top-2 -right-2 bg-slate-900 text-slate-200 border border-slate-600 text-[10px] font-bold px-1.5 py-0.5 rounded-full shadow">
                            108
                        </span>
                    </div>
                    <span class="text-[11px] font-semibold text-slate-400 mt-1.5">Ambil Kartu</span>
                </div>

                <!-- Indikator Warna Aktif saat ini -->
                <div class="flex flex-col items-center">
                    <div id="active-color-orb" class="w-11 h-11 rounded-full border-4 border-white/80 shadow-lg transition-colors duration-300 flex items-center justify-center bg-red-500">
                        <span id="direction-arrow-center" class="text-white font-bold text-lg">↻</span>
                    </div>
                    <span id="active-color-label" class="text-[10px] font-bold uppercase tracking-wider text-slate-300 mt-1">MERAH</span>
                </div>

                <!-- Tumpukan Kartu Buangan (DISCARD PILE) -->
                <div class="flex flex-col items-center">
                    <div id="discard-pile-slot" class="relative">
                        <!-- Kartu teratas dirender di sini -->
                    </div>
                    <span class="text-[11px] font-semibold text-slate-400 mt-1.5">Kartu Tengah</span>
                </div>
            </div>

            <!-- Tombol Aksi Cepat (Teriak UNO!, Tantang UNO!, Lewati Giliran setelah Draw) -->
            <div class="mt-3 flex flex-wrap items-center justify-center gap-2 min-h-[40px]">
                <!-- Tombol Teriakan UNO! -->
                <button id="btn-say-uno" onclick="sayUno()"
                    class="hidden px-5 py-2 rounded-full bg-gradient-to-r from-red-600 via-amber-500 to-yellow-400 text-slate-950 font-game font-bold text-sm sm:text-base shadow-lg shadow-red-500/40 animate-bounce border-2 border-white">
                    🔥 TERIAK UNO!
                </button>

                <!-- Tombol Tantang Lawan Lupa UNO -->
                <button id="btn-catch-uno" onclick="catchUno()"
                    class="hidden px-4 py-2 rounded-full bg-rose-600 hover:bg-rose-500 text-white font-game font-bold text-xs sm:text-sm shadow-lg border border-rose-300 animate-pulse">
                    🚨 Tangkap Lupa UNO! (+2)
                </button>

                <!-- Tombol Lewati Giliran (Setelah ambil 1 kartu & tidak dimainkan) -->
                <button id="btn-pass-turn" onclick="passTurnAfterDraw()"
                    class="hidden px-4 py-2 rounded-full bg-slate-700 hover:bg-slate-600 text-white font-semibold text-xs sm:text-sm border border-slate-500 shadow">
                    ⏭️ Lewati Giliran
                </button>
            </div>
        </div>

        <!-- AREA BAWAH: Kartu di Tangan Pemain Sendiri -->
        <div class="w-full bg-gradient-to-t from-slate-950 via-slate-900/95 to-transparent pt-3 pb-4 px-2 border-t border-slate-800/70">
            <div class="max-w-3xl mx-auto">
                <div class="flex items-center justify-between px-2 mb-1.5">
                    <div class="flex items-center gap-2">
                        <span id="my-player-badge" class="text-xs font-bold text-white bg-slate-800 px-2.5 py-0.5 rounded-full border border-slate-700">
                            Kamu (0 kartu)
                        </span>
                        <span id="my-uno-status" class="hidden text-[11px] font-game font-bold text-yellow-400 bg-yellow-400/10 px-2 py-0.5 rounded-full border border-yellow-400/40">
                            ★ UNO AKTIF!
                        </span>
                    </div>
                    <span id="my-turn-hint" class="text-[11px] text-slate-400">Menunggu giliran...</span>
                </div>

                <!-- Barisan Kartu Pemain (Horizontal Scrollable & Responsif) -->
                <div id="my-hand-container" class="flex items-end justify-start sm:justify-center gap-2 overflow-x-auto no-scrollbar pt-5 pb-2 px-3 min-h-[145px]">
                    <!-- Kartu pemain dirender di sini -->
                </div>
            </div>
        </div>
    </section>

    <!-- ========================================================= -->
    <!-- MODAL 1: PILIH WARNA (WILD / WILD +4)                     -->
    <!-- ========================================================= -->
    <div id="color-picker-modal" class="hidden fixed inset-0 z-50 bg-black/75 backdrop-blur-sm flex items-center justify-center p-4">
        <div class="bg-slate-900 border border-slate-700 rounded-3xl p-6 max-w-xs w-full text-center shadow-2xl">
            <h3 class="font-game text-xl text-white mb-1">Pilih Warna Baru</h3>
            <p class="text-xs text-slate-400 mb-4">Tentukan warna permainan berikutnya</p>
            <div class="grid grid-cols-2 gap-3">
                <button onclick="selectWildColor('red')" class="h-20 rounded-2xl bg-red-500 hover:bg-red-400 active:scale-95 text-white font-game font-bold text-lg shadow-lg border-2 border-white/30 transition">
                    MERAH
                </button>
                <button onclick="selectWildColor('blue')" class="h-20 rounded-2xl bg-blue-500 hover:bg-blue-400 active:scale-95 text-white font-game font-bold text-lg shadow-lg border-2 border-white/30 transition">
                    BIRU
                </button>
                <button onclick="selectWildColor('yellow')" class="h-20 rounded-2xl bg-yellow-400 hover:bg-yellow-300 active:scale-95 text-slate-950 font-game font-bold text-lg shadow-lg border-2 border-white/30 transition">
                    KUNING
                </button>
                <button onclick="selectWildColor('green')" class="h-20 rounded-2xl bg-green-500 hover:bg-green-400 active:scale-95 text-white font-game font-bold text-lg shadow-lg border-2 border-white/30 transition">
                    HIJAU
                </button>
            </div>
        </div>
    </div>

    <!-- ========================================================= -->
    <!-- MODAL 2: PEMENANG & PAPAN SKOR                            -->
    <!-- ========================================================= -->
    <div id="winner-modal" class="hidden fixed inset-0 z-50 bg-black/80 backdrop-blur-md flex items-center justify-center p-4">
        <div class="bg-slate-900 border border-yellow-500/40 rounded-3xl p-6 max-w-sm w-full text-center shadow-2xl">
            <div class="text-5xl mb-2">🏆</div>
            <h2 class="font-game text-2xl text-yellow-400">Permainan Selesai!</h2>
            <p id="winner-announcement" class="text-base font-bold text-white mt-1 mb-4">Budi Memenangkan Ronde Ini!</p>

            <div class="bg-slate-950/80 rounded-2xl p-3 mb-5 border border-slate-800 text-left">
                <p class="text-[11px] uppercase tracking-wider text-slate-400 font-bold mb-2">Klasemen & Poin Ronde</p>
                <div id="scoreboard-list" class="space-y-1.5 text-sm">
                    <!-- Skor pemain dirender di sini -->
                </div>
            </div>

            <div id="winner-host-actions" class="hidden flex flex-col gap-2">
                <button onclick="restartGame()" class="w-full py-3 rounded-xl bg-gradient-to-r from-emerald-500 to-green-600 text-white font-game font-bold text-base shadow-lg">
                    🔄 Main Lagi (Ronde Baru)
                </button>
                <button onclick="backToLobby()" class="w-full py-2.5 rounded-xl bg-slate-800 text-slate-300 text-xs font-semibold border border-slate-700">
                    Kembali ke Lobby
                </button>
            </div>
            <p id="winner-client-wait" class="hidden text-xs text-slate-400 animate-pulse">
                Menunggu Host memulai ronde berikutnya...
            </p>
        </div>
    </div>

    <!-- ========================================================= -->
    <!-- MODAL 3: PANDUAN ATURAN MAIN                              -->
    <!-- ========================================================= -->
    <div id="rules-modal" class="hidden fixed inset-0 z-50 bg-black/75 backdrop-blur-sm flex items-center justify-center p-4">
        <div class="bg-slate-900 border border-slate-700 rounded-3xl p-5 max-w-md w-full shadow-2xl max-h-[85vh] overflow-y-auto">
            <div class="flex items-center justify-between mb-3">
                <h3 class="font-game text-lg text-yellow-400">📖 Cara Bermain UNO P2P</h3>
                <button onclick="toggleModal('rules-modal', false)" class="w-8 h-8 rounded-full bg-slate-800 text-slate-300 flex items-center justify-center">✕</button>
            </div>
            <div class="space-y-2.5 text-xs text-slate-300 leading-relaxed">
                <p><strong class="text-white">1. Koneksi Tanpa Server:</strong> Satu pemain membuat room sebagai <b>Host</b> dan membagikan Kode Room 5 karakter. Pemain lain memasukkan kode tersebut di HP masing-masing.</p>
                <p><strong class="text-white">2. Tujuan Game:</strong> Habiskan semua kartu di tanganmu lebih dulu dari pemain lain.</p>
                <p><strong class="text-white">3. Mencocokkan Kartu:</strong> Keluarkan kartu yang memiliki <b>Warna</b>, <b>Angka</b>, atau <b>Simbol</b> sama dengan kartu teratas di tengah meja. Kartu <b>Wild</b> bisa dikeluarkan kapan saja.</p>
                <p><strong class="text-white">4. Kartu Aksi:</strong><br>
                    • <b>⊘ (Skip):</b> Melewati giliran pemain berikutnya.<br>
                    • <b>⇄ (Reverse):</b> Membalik arah putaran permainan (jika 2 pemain, berfungsi seperti Skip).<br>
                    • <b>+2 (Draw Two):</b> Pemain berikutnya mengambil 2 kartu & dilewati gilirannya.<br>
                    • <b>Wild:</b> Bebas memilih warna baru.<br>
                    • <b>Wild +4:</b> Bebas memilih warna baru & pemain berikutnya ambil 4 kartu + dilewati.
                </p>
                <p><strong class="text-white">5. Aturan UNO!:</strong> Saat kartumu tersisa 1 (atau akan tersisa 1), tekan tombol <b>TERIAK UNO!</b> Jika lupa, pemain lain bisa menekan <b>Tangkap Lupa UNO!</b> dan kamu dihukum ambil 2 kartu!</p>
            </div>
            <button onclick="toggleModal('rules-modal', false)" class="w-full mt-4 py-2.5 rounded-xl bg-blue-600 text-white font-semibold text-xs">
                Mengerti, Tutup
            </button>
        </div>
    </div>

    <!-- ========================================================= -->
    <!-- MODAL 4: KONFIRMASI KELUAR (PENGGANTI CONFIRM())          -->
    <!-- ========================================================= -->
    <div id="leave-modal" class="hidden fixed inset-0 z-50 bg-black/75 backdrop-blur-sm flex items-center justify-center p-4">
        <div class="bg-slate-900 border border-slate-700 rounded-3xl p-5 max-w-xs w-full text-center shadow-2xl">
            <h3 class="font-game text-lg text-white mb-1">Keluar dari Room?</h3>
            <p class="text-xs text-slate-400 mb-4">Koneksi ke permainan saat ini akan diputuskan.</p>
            <div class="flex gap-2">
                <button onclick="toggleModal('leave-modal', false)" class="flex-1 py-2.5 rounded-xl bg-slate-800 text-slate-300 text-xs font-semibold">Batal</button>
                <button onclick="leaveGameNow()" class="flex-1 py-2.5 rounded-xl bg-red-600 text-white text-xs font-semibold">Ya, Keluar</button>
            </div>
        </div>
    </div>

    <script>
        /**
         * ============================================================================
         * ARSITEKTUR MULTIPLAYER P2P (PEERJS) & ENGINE GAME UNO LENGKAP
         * ============================================================================
         * - Topologi Star:
         *   1 HP bertindak sebagai HOST (Peer ID: "UNOP2P-" + 5 karakter kode).
         *   HP lainnya bertindak sebagai CLIENT yang terhubung langsung ke Peer ID Host.
         * - Host menyimpan kebenaran state tunggal (Single Source of Truth) dan
         *   memvalidasi setiap langkah pemain (atau Bot AI), lalu menyiarkan (broadcast)
         *   state terbaru ke seluruh Client secara real-time.
         */

        // Prefix unik untuk mencegah tabrakan ID di broker PeerJS publik
        const PEER_PREFIX = 'UNOP2P2026-';
        const COLORS = ['red', 'yellow', 'green', 'blue'];
        const COLOR_NAMES_ID = {
            red: 'MERAH',
            yellow: 'KUNING',
            green: 'HIJAU',
            blue: 'BIRU',
            wild: 'BEBAS'
        };

        // State Jaringan & Identitas Lokal
        let peer = null;
        let isHost = false;
        let myPeerId = '';
        let myName = '';
        let roomCode = '';
        let hostConnection = null; // Untuk Client: koneksi ke Host
        let clientConnections = {}; // Untuk Host: map peerId -> DataConnection
        let soundEnabled = true;
        let pendingWildCardIndex = null;
        let botTimer = null;

        // State Utama Permainan (Dikelola Host & disinkronkan ke semua Client)
        let gameState = {
            phase: 'lobby', // 'lobby' | 'playing' | 'ended'
            players: [],    // [{ id, name, isHost, isBot, connected, hand: [], unoCalled: false, score: 0 }]
            deck: [],
            discardPile: [],
            currentColor: 'red',
            turnIndex: 0,
            direction: 1,   // 1 = searah jarum jam, -1 = berlawanan jarum jam
            hasDrawnThisTurn: false,
            lastActionText: 'Menunggu permainan dimulai...',
            winnerId: null
        };

        // ============================================================================
        // 1. SISTEM EFEK SUARA (WEB AUDIO API - TANPA FILE EKSTERNAL)
        // ============================================================================
        const AudioEngine = (() => {
            let ctx = null;
            function getCtx() {
                if (!ctx) {
                    const AudioContext = window.AudioContext || window.webkitAudioContext;
                    if (AudioContext) ctx = new AudioContext();
                }
                if (ctx && ctx.state === 'suspended') ctx.resume();
                return ctx;
            }

            function playTone(freq, type, duration, vol = 0.15, delay = 0) {
                if (!soundEnabled) return;
                try {
                    const audioCtx = getCtx();
                    if (!audioCtx) return;
                    const osc = audioCtx.createOscillator();
                    const gain = audioCtx.createGain();
                    osc.type = type;
                    osc.frequency.setValueAtTime(freq, audioCtx.currentTime + delay);
                    gain.gain.setValueAtTime(vol, audioCtx.currentTime + delay);
                    gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + delay + duration);
                    osc.connect(gain);
                    gain.connect(audioCtx.destination);
                    osc.start(audioCtx.currentTime + delay);
                    osc.stop(audioCtx.currentTime + delay + duration);
                } catch (e) { /* Abaikan jika diblokir autoplay browser */ }
            }

            return {
                cardPlay: () => { playTone(520, 'triangle', 0.12, 0.18); playTone(680, 'sine', 0.1, 0.12, 0.05); },
                cardDraw: () => { playTone(320, 'sine', 0.14, 0.15); },
                unoShout: () => {
                    playTone(587.33, 'square', 0.12, 0.16, 0);
                    playTone(880, 'square', 0.25, 0.18, 0.12);
                },
                penalty: () => { playTone(200, 'sawtooth', 0.25, 0.16); playTone(150, 'sawtooth', 0.3, 0.16, 0.15); },
                yourTurn: () => { playTone(660, 'sine', 0.12, 0.12); },
                win: () => {
                    [523.25, 659.25, 783.99, 1046.50].forEach((f, i) => playTone(f, 'triangle', 0.28, 0.2, i * 0.11));
                }
            };
        })();

        function toggleSound() {
            soundEnabled = !soundEnabled;
            document.getElementById('btn-sound').textContent = soundEnabled ? '🔊' : '🔇';
            showToast(soundEnabled ? 'Efek suara aktif' : 'Efek suara dimatikan');
        }

        // ============================================================================
        // 2. UTILITAS UI & NOTIFIKASI
        // ============================================================================
        function showToast(message, type = 'info') {
            const container = document.getElementById('toast-container');
            const toast = document.createElement('div');
            const bgMap = {
                info: 'bg-slate-800/95 border-slate-600 text-white',
                success: 'bg-emerald-900/95 border-emerald-500 text-emerald-100',
                warn: 'bg-amber-900/95 border-amber-500 text-amber-100',
                error: 'bg-red-900/95 border-red-500 text-red-100'
            };
            toast.className = `px-4 py-2.5 rounded-2xl border shadow-xl text-xs font-semibold text-center backdrop-blur-md transition-all duration-300 ${bgMap[type] || bgMap.info}`;
            toast.textContent = message;
            container.appendChild(toast);
            setTimeout(() => {
                toast.style.opacity = '0';
                toast.style.transform = 'translateY(-8px)';
                setTimeout(() => toast.remove(), 300);
            }, 2800);
        }

        function toggleModal(id, show) {
            const el = document.getElementById(id);
            if (show) el.classList.remove('hidden');
            else el.classList.add('hidden');
        }

        function switchView(viewName) {
            ['view-home', 'view-lobby', 'view-game'].forEach(v => {
                document.getElementById(v).classList.add('hidden');
            });
            document.getElementById(`view-${viewName}`).classList.remove('hidden');

            const leaveBtn = document.getElementById('btn-leave');
            if (viewName === 'home') leaveBtn.classList.add('hidden');
            else leaveBtn.classList.remove('hidden');
        }

        function updateConnectionHeader(statusText, colorClass) {
            const el = document.getElementById('header-conn-status');
            el.innerHTML = `<span class="w-2 h-2 rounded-full ${colorClass} inline-block"></span> ${statusText}`;
        }

        function generateRoomCode() {
            // Hindari karakter ambigu seperti O, 0, I, 1
            const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
            let code = '';
            for (let i = 0; i < 5; i++) {
                code += chars.charAt(Math.floor(Math.random() * chars.length));
            }
            return code;
        }

        function copyRoomCode() {
            const tempInput = document.createElement('input');
            tempInput.value = roomCode;
            document.body.appendChild(tempInput);
            tempInput.select();
            tempInput.setSelectionRange(0, 99999);
            try {
                document.execCommand('copy');
                showToast(`Kode Room "${roomCode}" berhasil disalin!`, 'success');
            } catch (err) {
                showToast('Gagal menyalin otomatis, silakan catat kodenya.', 'warn');
            }
            document.body.removeChild(tempInput);
        }

        // ============================================================================
        // 3. MANAJEMEN KONEKSI PEERJS (HOST & CLIENT)
        // ============================================================================
        function getValidatedName() {
            const input = document.getElementById('input-player-name').value.trim();
            if (!input) {
                const randomNum = Math.floor(10 + Math.random() * 89);
                return `Pemain_${randomNum}`;
            }
            return input;
        }

        // Konfigurasi STUN Server Publik Gratis untuk menembus NAT antar jaringan HP
        const PEER_CONFIG = {
            debug: 1,
            config: {
                iceServers: [
                    { urls: 'stun:stun.l.google.com:19302' },
                    { urls: 'stun:stun1.l.google.com:19302' },
                    { urls: 'stun:stun2.l.google.com:19302' },
                    { urls: 'stun:global.stun.twilio.com:3478' }
                ]
            }
        };

        // HOST: Membuat Room Baru
        function createRoom() {
            myName = getValidatedName();
            roomCode = generateRoomCode();
            isHost = true;

            const btn = document.getElementById('btn-create-room');
            btn.disabled = true;
            btn.textContent = 'Menyiapkan Room...';
            updateConnectionHeader('Menghubungkan P2P...', 'bg-amber-400 animate-ping');

            peer = new Peer(PEER_PREFIX + roomCode, PEER_CONFIG);

            peer.on('open', (id) => {
                myPeerId = id;
                btn.disabled = false;
                btn.innerHTML = '<span>👑</span> Buat Room Baru (Jadi Host)';

                // Inisialisasi State Game dengan Host sebagai pemain pertama
                gameState = {
                    phase: 'lobby',
                    players: [{
                        id: myPeerId,
                        name: myName,
                        isHost: true,
                        isBot: false,
                        connected: true,
                        hand: [],
                        unoCalled: false,
                        score: 0
                    }],
                    deck: [],
                    discardPile: [],
                    currentColor: 'red',
                    turnIndex: 0,
                    direction: 1,
                    hasDrawnThisTurn: false,
                    lastActionText: 'Room dibuat. Menunggu pemain bergabung...',
                    winnerId: null
                };

                updateConnectionHeader(`Host • Room ${roomCode}`, 'bg-emerald-400');
                switchView('lobby');
                renderLobby();
                showToast(`Room ${roomCode} siap! Bagikan kode ke teman.`, 'success');
            });

            // Host menerima koneksi masuk dari HP lain
            peer.on('connection', (conn) => {
                setupHostClientConnection(conn);
            });

            peer.on('error', (err) => {
                console.error('PeerJS Host Error:', err);
                btn.disabled = false;
                btn.innerHTML = '<span>👑</span> Buat Room Baru (Jadi Host)';
                if (err.type === 'unavailable-id') {
                    // Jika kebetulan ID terpakai, coba buat ulang
                    createRoom();
                } else {
                    showToast('Koneksi P2P bermasalah. Coba periksa internetmu.', 'error');
                    updateConnectionHeader('Terputus', 'bg-red-500');
                }
            });
        }

        // HOST: Menangani koneksi dari setiap Client
        function setupHostClientConnection(conn) {
            conn.on('open', () => {
                clientConnections[conn.peer] = conn;
            });

            conn.on('data', (data) => {
                handleMessageFromClient(conn, data);
            });

            conn.on('close', () => {
                delete clientConnections[conn.peer];
                const player = gameState.players.find(p => p.id === conn.peer);
                if (player) {
                    if (gameState.phase === 'lobby') {
                        gameState.players = gameState.players.filter(p => p.id !== conn.peer);
                        showToast(`${player.name} keluar dari lobby.`, 'warn');
                    } else {
                        player.connected = false;
                        gameState.lastActionText = `⚠️ ${player.name} terputus dari jaringan!`;
                        showToast(`${player.name} terputus!`, 'warn');
                        // Jika sedang giliran pemain yang putus, otomatis lewati setelah 2 detik
                        if (gameState.players[gameState.turnIndex]?.id === player.id) {
                            setTimeout(() => {
                                if (!player.connected && gameState.phase === 'playing') {
                                    advanceTurn(1);
                                    broadcastGameState();
                                }
                            }, 2000);
                        }
                    }
                    broadcastGameState();
                }
            });
        }

        // CLIENT: Bergabung ke Room Host
        function joinRoom() {
            const codeInput = document.getElementById('input-room-code').value.trim().toUpperCase();
            if (codeInput.length < 4) {
                showToast('Masukkan Kode Room yang valid!', 'warn');
                return;
            }

            myName = getValidatedName();
            roomCode = codeInput;
            isHost = false;

            const btn = document.getElementById('btn-join-room');
            btn.disabled = true;
            btn.textContent = '...';
            updateConnectionHeader('Mencari Room...', 'bg-amber-400 animate-ping');

            peer = new Peer(PEER_CONFIG);

            peer.on('open', (id) => {
                myPeerId = id;
                const targetHostId = PEER_PREFIX + roomCode;
                hostConnection = peer.connect(targetHostId, { reliable: true });

                const timeout = setTimeout(() => {
                    if (!hostConnection || !hostConnection.open) {
                        btn.disabled = false;
                        btn.textContent = 'Gabung';
                        showToast('Room tidak ditemukan atau Host tidak merespons.', 'error');
                        updateConnectionHeader('Gagal Terhubung', 'bg-red-500');
                    }
                }, 9000);

                hostConnection.on('open', () => {
                    clearTimeout(timeout);
                    btn.disabled = false;
                    btn.textContent = 'Gabung';
                    updateConnectionHeader(`Terhubung • Room ${roomCode}`, 'bg-emerald-400');

                    // Kirim permintaan bergabung beserta nama pemain
                    hostConnection.send({
                        type: 'JOIN_REQUEST',
                        name: myName
                    });
                });

                hostConnection.on('data', (data) => {
                    handleMessageFromHost(data);
                });

                hostConnection.on('close', () => {
                    showToast('Koneksi dengan Host terputus!', 'error');
                    updateConnectionHeader('Host Terputus', 'bg-red-500');
                    setTimeout(() => leaveGameNow(), 2000);
                });
            });

            peer.on('error', (err) => {
                console.error('PeerJS Client Error:', err);
                btn.disabled = false;
                btn.textContent = 'Gabung';
                showToast('Gagal terhubung ke Room. Periksa kode & internet.', 'error');
                updateConnectionHeader('Error Koneksi', 'bg-red-500');
            });
        }

        function sendToHost(payload) {
            if (isHost) {
                // Jika Host sendiri yang melakukan aksi, proses langsung
                handleMessageFromClient({ peer: myPeerId }, payload);
            } else if (hostConnection && hostConnection.open) {
                hostConnection.send(payload);
            } else {
                showToast('Tidak terhubung ke Host!', 'error');
            }
        }

        function broadcastGameState() {
            if (!isHost) return;
            // Render di layar Host sendiri
            applySyncedState(gameState);
            // Kirim ke semua Client yang terhubung
            Object.values(clientConnections).forEach(conn => {
                if (conn.open) {
                    conn.send({
                        type: 'STATE_SYNC',
                        state: gameState
                    });
                }
            });
        }

        function confirmLeaveGame() {
            toggleModal('leave-modal', true);
        }

        function leaveGameNow() {
            toggleModal('leave-modal', false);
            if (botTimer) clearTimeout(botTimer);
            if (peer) {
                peer.destroy();
                peer = null;
            }
            hostConnection = null;
            clientConnections = {};
            isHost = false;
            updateConnectionHeader('Siap Bermain', 'bg-amber-400');
            switchView('home');
        }

        // ============================================================================
        // 4. LOGIKA LOBBY & BOT AI
        // ============================================================================
        function addBotPlayer() {
            if (!isHost) return;
            if (gameState.players.length >= 8) {
                showToast('Maksimal 8 pemain dalam satu room!', 'warn');
                return;
            }
            const botNames = ['Bot Alfa', 'Bot Luna', 'Bot Rio', 'Bot Kira', 'Bot Max', 'Bot Zara', 'Bot Neo'];
            const usedNames = gameState.players.map(p => p.name);
            const availableName = botNames.find(n => !usedNames.includes(n)) || `Bot_${gameState.players.length + 1}`;

            gameState.players.push({
                id: 'BOT-' + Date.now() + '-' + Math.floor(Math.random() * 1000),
                name: availableName,
                isHost: false,
                isBot: true,
                connected: true,
                hand: [],
                unoCalled: false,
                score: 0
            });
            AudioEngine.cardDraw();
            broadcastGameState();
        }

        function removePlayerFromLobby(playerId) {
            if (!isHost) return;
            if (clientConnections[playerId]) {
                clientConnections[playerId].close();
                delete clientConnections[playerId];
            }
            gameState.players = gameState.players.filter(p => p.id !== playerId);
            broadcastGameState();
        }

        function renderLobby() {
            document.getElementById('lobby-room-code').textContent = roomCode;
            document.getElementById('lobby-player-count').textContent = gameState.players.length;

            const addBotBtn = document.getElementById('btn-add-bot');
            const hostControls = document.getElementById('host-lobby-controls');
            const clientWait = document.getElementById('client-lobby-wait');

            if (isHost) {
                addBotBtn.classList.remove('hidden');
                hostControls.classList.remove('hidden');
                clientWait.classList.add('hidden');
            } else {
                addBotBtn.classList.add('hidden');
                hostControls.classList.add('hidden');
                clientWait.classList.remove('hidden');
            }

            const listEl = document.getElementById('lobby-player-list');
            listEl.innerHTML = '';

            gameState.players.forEach((p, idx) => {
                const isMe = p.id === myPeerId;
                const item = document.createElement('div');
                item.className = 'flex items-center justify-between px-3.5 py-2.5 rounded-xl bg-slate-800/80 border border-slate-700/80';
                item.innerHTML = `
                    <div class="flex items-center gap-2.5">
                        <div class="w-8 h-8 rounded-full flex items-center justify-center font-game font-bold text-sm ${p.isBot ? 'bg-purple-500/20 text-purple-300 border border-purple-500/40' : 'bg-blue-500/20 text-blue-300 border border-blue-500/40'}">
                            ${p.isBot ? '🤖' : (idx + 1)}
                        </div>
                        <div>
                            <div class="flex items-center gap-1.5">
                                <span class="text-sm font-semibold text-white">${escapeHtml(p.name)}</span>
                                ${isMe ? '<span class="text-[10px] px-1.5 py-0.2 bg-yellow-400/20 text-yellow-300 rounded font-bold">KAMU</span>' : ''}
                                ${p.isHost ? '<span class="text-[10px] px-1.5 py-0.2 bg-amber-500/20 text-amber-300 rounded font-bold">HOST</span>' : ''}
                            </div>
                            <span class="text-[11px] text-emerald-400 flex items-center gap-1">
                                <span class="w-1.5 h-1.5 rounded-full bg-emerald-400"></span> ${p.isBot ? 'AI Siap' : 'Terhubung P2P'}
                            </span>
                        </div>
                    </div>
                    ${(isHost && !p.isHost) ? `<button onclick="removePlayerFromLobby('${p.id}')" class="text-xs text-red-400 hover:text-red-300 px-2 py-1 rounded bg-red-500/10">Hapus</button>` : ''}
                `;
                listEl.appendChild(item);
            });
        }

        // ============================================================================
        // 5. DECK & ATURAN INTI GAME UNO (108 KARTU)
        // ============================================================================
        function createUnoDeck() {
            const deck = [];
            let uid = 1;

            COLORS.forEach(color => {
                // Angka 0: 1 per warna
                deck.push({ uid: uid++, color, value: '0', type: 'number', points: 0 });

                // Angka 1-9: 2 per warna
                for (let n = 1; n <= 9; n++) {
                    deck.push({ uid: uid++, color, value: String(n), type: 'number', points: n });
                    deck.push({ uid: uid++, color, value: String(n), type: 'number', points: n });
                }

                // Kartu Aksi (Skip, Reverse, Draw Two): 2 per warna (20 poin)
                ['skip', 'reverse', 'draw2'].forEach(action => {
                    deck.push({ uid: uid++, color, value: action, type: 'action', points: 20 });
                    deck.push({ uid: uid++, color, value: action, type: 'action', points: 20 });
                });
            });

            // Kartu Wild & Wild Draw Four: masing-masing 4 kartu (50 poin)
            for (let i = 0; i < 4; i++) {
                deck.push({ uid: uid++, color: 'wild', value: 'wild', type: 'wild', points: 50 });
                deck.push({ uid: uid++, color: 'wild', value: 'wild4', type: 'wild', points: 50 });
            }

            return shuffleArray(deck);
        }

        function shuffleArray(arr) {
            const copy = [...arr];
            for (let i = copy.length - 1; i > 0; i--) {
                const j = Math.floor(Math.random() * (i + 1));
                [copy[i], copy[j]] = [copy[j], copy[i]];
            }
            return copy;
        }

        function drawCardsFromDeck(count) {
            const drawn = [];
            for (let i = 0; i < count; i++) {
                if (gameState.deck.length === 0) {
                    // Kocok ulang discard pile (sisakan kartu teratas)
                    if (gameState.discardPile.length <= 1) break;
                    const topCard = gameState.discardPile.pop();
                    gameState.deck = shuffleArray(gameState.discardPile);
                    gameState.discardPile = [topCard];
                }
                if (gameState.deck.length > 0) {
                    drawn.push(gameState.deck.pop());
                }
            }
            return drawn;
        }

        function isCardPlayable(card, topCard, currentColor) {
            if (!card || !topCard) return false;
            // Kartu Wild & Wild+4 selalu bisa dimainkan
            if (card.color === 'wild') return true;
            // Warna cocok dengan warna aktif meja
            if (card.color === currentColor) return true;
            // Angka atau simbol aksi sama dengan kartu teratas
            if (card.value === topCard.value) return true;
            return false;
        }

        // HOST: Memulai Permainan
        function startGame() {
            if (!isHost) return;
            if (gameState.players.length < 2) {
                showToast('Minimal butuh 2 pemain! Tambahkan Bot AI jika bermain sendiri.', 'warn');
                return;
            }

            gameState.deck = createUnoDeck();
            gameState.discardPile = [];
            gameState.direction = 1;
            gameState.turnIndex = 0;
            gameState.hasDrawnThisTurn = false;
            gameState.winnerId = null;

            // Bagikan 7 kartu awal ke setiap pemain
            gameState.players.forEach(p => {
                p.hand = drawCardsFromDeck(7);
                p.unoCalled = false;
            });

            // Ambil 1 kartu awal untuk ditaruh di tengah (pastikan bukan Wild +4)
            let firstCard = drawCardsFromDeck(1)[0];
            while (firstCard.value === 'wild4') {
                gameState.deck.unshift(firstCard);
                gameState.deck = shuffleArray(gameState.deck);
                firstCard = drawCardsFromDeck(1)[0];
            }

            gameState.discardPile.push(firstCard);
            gameState.currentColor = firstCard.color === 'wild'
                ? COLORS[Math.floor(Math.random() * 4)]
                : firstCard.color;

            gameState.phase = 'playing';
            gameState.lastActionText = `Permainan dimulai! Kartu pertama: ${formatCardName(firstCard)}`;

            // Terapkan efek jika kartu pertama adalah kartu aksi
            if (firstCard.value === 'reverse') {
                gameState.direction = -1;
                if (gameState.players.length === 2) advanceTurn(1);
            } else if (firstCard.value === 'skip') {
                advanceTurn(1);
            } else if (firstCard.value === 'draw2') {
                const victim = gameState.players[gameState.turnIndex];
                victim.hand.push(...drawCardsFromDeck(2));
                gameState.lastActionText = `${victim.name} ambil +2 dari kartu pembuka!`;
                advanceTurn(1);
            }

            AudioEngine.cardPlay();
            broadcastGameState();
            scheduleBotIfNeeded();
        }

        function restartGame() {
            if (!isHost) return;
            toggleModal('winner-modal', false);
            startGame();
        }

        function backToLobby() {
            if (!isHost) return;
            toggleModal('winner-modal', false);
            gameState.phase = 'lobby';
            broadcastGameState();
        }

        function advanceTurn(steps = 1) {
            const total = gameState.players.length;
            gameState.turnIndex = (gameState.turnIndex + (steps * gameState.direction) % total + total) % total;
            gameState.hasDrawnThisTurn = false;
        }

        // ============================================================================
        // 6. PEMROSESAN AKSI PEMAIN (DI JALANKAN DI HOST)
        // ============================================================================
        function handleMessageFromClient(conn, data) {
            if (!isHost || !data || !data.type) return;
            const senderId = conn.peer;

            switch (data.type) {
                case 'JOIN_REQUEST': {
                    if (gameState.phase !== 'lobby') {
                        conn.send({ type: 'ERROR_MSG', message: 'Permainan sudah berlangsung!' });
                        return;
                    }
                    if (gameState.players.length >= 8) {
                        conn.send({ type: 'ERROR_MSG', message: 'Room sudah penuh (maks 8 pemain)!' });
                        return;
                    }
                    // Cegah duplikat ID
                    const existing = gameState.players.find(p => p.id === senderId);
                    if (!existing) {
                        gameState.players.push({
                            id: senderId,
                            name: (data.name || 'Pemain').substring(0, 14),
                            isHost: false,
                            isBot: false,
                            connected: true,
                            hand: [],
                            unoCalled: false,
                            score: 0
                        });
                        AudioEngine.cardDraw();
                    }
                    broadcastGameState();
                    break;
                }

                case 'PLAY_CARD': {
                    if (gameState.phase !== 'playing') return;
                    const currentPlayer = gameState.players[gameState.turnIndex];
                    if (!currentPlayer || currentPlayer.id !== senderId) return;

                    processPlayCard(currentPlayer, data.cardIndex, data.chosenColor);
                    break;
                }

                case 'DRAW_CARD': {
                    if (gameState.phase !== 'playing') return;
                    const currentPlayer = gameState.players[gameState.turnIndex];
                    if (!currentPlayer || currentPlayer.id !== senderId) return;
                    if (gameState.hasDrawnThisTurn) return;

                    processDrawCard(currentPlayer);
                    break;
                }

                case 'PASS_TURN': {
                    if (gameState.phase !== 'playing') return;
                    const currentPlayer = gameState.players[gameState.turnIndex];
                    if (!currentPlayer || currentPlayer.id !== senderId) return;
                    if (!gameState.hasDrawnThisTurn) return;

                    gameState.lastActionText = `${currentPlayer.name} melewati giliran.`;
                    advanceTurn(1);
                    broadcastGameState();
                    scheduleBotIfNeeded();
                    break;
                }

                case 'SAY_UNO': {
                    const player = gameState.players.find(p => p.id === senderId);
                    if (player && player.hand.length <= 2) {
                        player.unoCalled = true;
                        gameState.lastActionText = `🔥 ${player.name} berteriak "UNO!"`;
                        broadcastGameState();
                        broadcastSound('unoShout');
                    }
                    break;
                }

                case 'CATCH_UNO': {
                    const catcher = gameState.players.find(p => p.id === senderId);
                    // Cari pemain lain yang kartunya 1 tapi belum teriak UNO
                    const target = gameState.players.find(p => p.id !== senderId && p.hand.length === 1 && !p.unoCalled);
                    if (catcher && target) {
                        target.hand.push(...drawCardsFromDeck(2));
                        target.unoCalled = false;
                        gameState.lastActionText = `🚨 ${catcher.name} menangkap ${target.name} lupa UNO! (+2 kartu)`;
                        broadcastGameState();
                        broadcastSound('penalty');
                    }
                    break;
                }
            }
        }

        function processPlayCard(player, cardIndex, chosenColor) {
            const card = player.hand[cardIndex];
            const topCard = gameState.discardPile[gameState.discardPile.length - 1];

            if (!card || !isCardPlayable(card, topCard, gameState.currentColor)) {
                return;
            }

            // Keluarkan kartu dari tangan pemain ke discard pile
            player.hand.splice(cardIndex, 1);
            gameState.discardPile.push(card);

            // Reset status UNO jika kartu > 1
            if (player.hand.length > 1) {
                player.unoCalled = false;
            }

            // Tentukan warna aktif
            if (card.color === 'wild') {
                gameState.currentColor = COLORS.includes(chosenColor) ? chosenColor : 'red';
            } else {
                gameState.currentColor = card.color;
            }

            broadcastSound('cardPlay');

            // Cek apakah pemain sudah menghabiskan seluruh kartunya (MENANG!)
            if (player.hand.length === 0) {
                finishRound(player);
                return;
            }

            let actionLog = `${player.name} memainkan ${formatCardName(card)}`;
            if (card.color === 'wild') {
                actionLog += ` (Warna: ${COLOR_NAMES_ID[gameState.currentColor]})`;
            }

            // Terapkan efek kartu khusus
            const playerCount = gameState.players.length;
            if (card.value === 'reverse') {
                gameState.direction *= -1;
                actionLog += ' • Arah berbalik!';
                if (playerCount === 2) {
                    // Dalam aturan resmi 2 pemain, Reverse bertindak seperti Skip
                    advanceTurn(2);
                } else {
                    advanceTurn(1);
                }
            } else if (card.value === 'skip') {
                const skippedPlayer = gameState.players[(gameState.turnIndex + gameState.direction + playerCount) % playerCount];
                actionLog += ` • ${skippedPlayer.name} dilewati!`;
                advanceTurn(2);
            } else if (card.value === 'draw2') {
                const victimIndex = (gameState.turnIndex + gameState.direction + playerCount) % playerCount;
                const victim = gameState.players[victimIndex];
                victim.hand.push(...drawCardsFromDeck(2));
                victim.unoCalled = false;
                actionLog += ` • ${victim.name} ambil +2 kartu!`;
                advanceTurn(2);
            } else if (card.value === 'wild4') {
                const victimIndex = (gameState.turnIndex + gameState.direction + playerCount) % playerCount;
                const victim = gameState.players[victimIndex];
                victim.hand.push(...drawCardsFromDeck(4));
                victim.unoCalled = false;
                actionLog += ` • ${victim.name} ambil +4 kartu!`;
                advanceTurn(2);
            } else {
                advanceTurn(1);
            }

            gameState.lastActionText = actionLog;
            broadcastGameState();
            scheduleBotIfNeeded();
        }

        function processDrawCard(player) {
            const drawn = drawCardsFromDeck(1);
            if (drawn.length === 0) {
                gameState.lastActionText = 'Deck habis! Giliran dilewati.';
                advanceTurn(1);
                broadcastGameState();
                scheduleBotIfNeeded();
                return;
            }

            const newCard = drawn[0];
            player.hand.push(newCard);
            player.unoCalled = false;
            gameState.hasDrawnThisTurn = true;
            broadcastSound('cardDraw');

            const topCard = gameState.discardPile[gameState.discardPile.length - 1];
            const canPlayDrawn = isCardPlayable(newCard, topCard, gameState.currentColor);

            if (!canPlayDrawn) {
                // Jika kartu yang baru diambil tidak cocok, otomatis lanjut ke pemain berikutnya
                gameState.lastActionText = `${player.name} mengambil 1 kartu (tidak cocok).`;
                advanceTurn(1);
                broadcastGameState();
                scheduleBotIfNeeded();
            } else {
                // Jika cocok, pemain boleh memilih memainkannya atau melewati giliran
                gameState.lastActionText = `${player.name} mengambil 1 kartu dari deck.`;
                broadcastGameState();
            }
        }

        function finishRound(winner) {
            gameState.phase = 'ended';
            gameState.winnerId = winner.id;

            // Hitung total poin dari sisa kartu lawan
            let roundPoints = 0;
            gameState.players.forEach(p => {
                if (p.id !== winner.id) {
                    p.hand.forEach(c => { roundPoints += c.points; });
                }
            });
            winner.score += roundPoints;
            gameState.lastActionText = `🏆 ${winner.name} menang dan mendapat +${roundPoints} poin!`;

            broadcastSound('win');
            broadcastGameState();
        }

        function broadcastSound(soundName) {
            if (AudioEngine[soundName]) AudioEngine[soundName]();
            Object.values(clientConnections).forEach(conn => {
                if (conn.open) conn.send({ type: 'PLAY_SOUND', sound: soundName });
            });
        }

        // ============================================================================
        // 7. KECERDASAN BUATAN (BOT AI) UNTUK HOST
        // ============================================================================
        function scheduleBotIfNeeded() {
            if (!isHost || gameState.phase !== 'playing') return;
            if (botTimer) clearTimeout(botTimer);

            const currentPlayer = gameState.players[gameState.turnIndex];
            if (!currentPlayer || !currentPlayer.isBot) return;

            botTimer = setTimeout(() => {
                if (gameState.phase !== 'playing') return;
                const bot = gameState.players[gameState.turnIndex];
                if (!bot || !bot.isBot) return;

                // Cek apakah ada lawan yang lupa teriak UNO
                const vulnerableHuman = gameState.players.find(p => p.id !== bot.id && p.hand.length === 1 && !p.unoCalled);
                if (vulnerableHuman && Math.random() < 0.7) {
                    vulnerableHuman.hand.push(...drawCardsFromDeck(2));
                    gameState.lastActionText = `🚨 ${bot.name} menangkap ${vulnerableHuman.name} lupa UNO! (+2)`;
                    broadcastSound('penalty');
                    broadcastGameState();
                }

                const topCard = gameState.discardPile[gameState.discardPile.length - 1];
                // Cari semua kartu yang valid di tangan Bot
                const validIndices = [];
                bot.hand.forEach((c, idx) => {
                    if (isCardPlayable(c, topCard, gameState.currentColor)) {
                        validIndices.push(idx);
                    }
                });

                if (validIndices.length > 0) {
                    // Prioritaskan kartu non-wild dulu jika ada
                    const nonWild = validIndices.filter(i => bot.hand[i].color !== 'wild');
                    const chosenIdx = nonWild.length > 0
                        ? nonWild[Math.floor(Math.random() * nonWild.length)]
                        : validIndices[0];

                    // Pilih warna terbanyak di tangan Bot jika mengeluarkan Wild
                    const colorCounts = { red: 0, yellow: 0, green: 0, blue: 0 };
                    bot.hand.forEach(c => { if (colorCounts[c.color] !== undefined) colorCounts[c.color]++; });
                    const bestColor = Object.keys(colorCounts).reduce((a, b) => colorCounts[a] >= colorCounts[b] ? a : b);

                    // Bot teriak UNO otomatis jika sisa 2 kartu sebelum main
                    if (bot.hand.length === 2) {
                        bot.unoCalled = true;
                        broadcastSound('unoShout');
                    }

                    processPlayCard(bot, chosenIdx, bestColor);
                } else {
                    // Ambil 1 kartu
                    processDrawCard(bot);
                    // Jika setelah ambil kartu masih giliran Bot (kartu baru valid), mainkan!
                    if (gameState.phase === 'playing' && gameState.players[gameState.turnIndex]?.id === bot.id) {
                        setTimeout(() => {
                            const newIdx = bot.hand.length - 1;
                            const colorCounts = { red: 0, yellow: 0, green: 0, blue: 0 };
                            bot.hand.forEach(c => { if (colorCounts[c.color] !== undefined) colorCounts[c.color]++; });
                            const bestColor = Object.keys(colorCounts).reduce((a, b) => colorCounts[a] >= colorCounts[b] ? a : b);
                            processPlayCard(bot, newIdx, bestColor);
                        }, 700);
                    }
                }
            }, 1150);
        }

        // ============================================================================
        // 8. SINKRONISASI STATE & RENDERING UI (CLIENT & HOST)
        // ============================================================================
        function handleMessageFromHost(data) {
            if (!data || !data.type) return;
            if (data.type === 'STATE_SYNC') {
                const prevTurnId = gameState.players[gameState.turnIndex]?.id;
                gameState = data.state;
                const newTurnId = gameState.players[gameState.turnIndex]?.id;

                if (gameState.phase === 'playing' && newTurnId === myPeerId && prevTurnId !== myPeerId) {
                    AudioEngine.yourTurn();
                }
                applySyncedState(gameState);
            } else if (data.type === 'PLAY_SOUND') {
                if (AudioEngine[data.sound]) AudioEngine[data.sound]();
            } else if (data.type === 'ERROR_MSG') {
                showToast(data.message, 'error');
                leaveGameNow();
            }
        }

        function applySyncedState(state) {
            if (state.phase === 'lobby') {
                toggleModal('winner-modal', false);
                switchView('lobby');
                renderLobby();
            } else if (state.phase === 'playing') {
                toggleModal('winner-modal', false);
                switchView('game');
                renderGameBoard();
            } else if (state.phase === 'ended') {
                switchView('game');
                renderGameBoard();
                renderWinnerModal();
            }
        }

        // Render Kartu UNO dalam bentuk HTML
        function createCardHTML(card, extraClass = '', onClickAttr = '') {
            const symbol = getCardDisplaySymbol(card);
            const textColorClass = `text-card-${card.color}`;
            return `
                <div ${onClickAttr} class="uno-card card-${card.color} ${extraClass}">
                    <div class="uno-card-inner">
                        <span class="uno-corner uno-corner-tl">${symbol}</span>
                        <div class="uno-oval">
                            <span class="uno-symbol-center ${textColorClass}">${symbol}</span>
                        </div>
                        <span class="uno-corner uno-corner-br">${symbol}</span>
                    </div>
                </div>
            `;
        }

        function getCardDisplaySymbol(card) {
            switch (card.value) {
                case 'skip': return '⊘';
                case 'reverse': return '⇄';
                case 'draw2': return '+2';
                case 'wild': return '★';
                case 'wild4': return '+4';
                default: return card.value;
            }
        }

        function formatCardName(card) {
            const valNames = {
                skip: 'Skip ⊘',
                reverse: 'Reverse ⇄',
                draw2: 'Draw +2',
                wild: 'Wild ★',
                wild4: 'Wild +4'
            };
            const valLabel = valNames[card.value] || card.value;
            if (card.color === 'wild') return valLabel;
            return `${COLOR_NAMES_ID[card.color]} ${valLabel}`;
        }

        function renderGameBoard() {
            const me = gameState.players.find(p => p.id === myPeerId);
            const currentPlayer = gameState.players[gameState.turnIndex];
            const isMyTurn = currentPlayer && currentPlayer.id === myPeerId && gameState.phase === 'playing';
            const topCard = gameState.discardPile[gameState.discardPile.length - 1];

            // 1. Render Daftar Lawan di Bagian Atas
            const opponentsBar = document.getElementById('opponents-bar');
            opponentsBar.innerHTML = '';
            gameState.players.forEach((p, idx) => {
                if (p.id === myPeerId) return; // Diri sendiri dirender di bawah
                const isTurn = idx === gameState.turnIndex;
                const isUno = p.hand.length === 1;
                const oppEl = document.createElement('div');
                oppEl.className = `flex-shrink-0 px-3 py-2 rounded-2xl bg-slate-900/90 border-2 transition-all min-w-[96px] text-center relative ${isTurn ? 'active-turn-ring bg-slate-800' : 'border-slate-800'} ${!p.connected ? 'opacity-50' : ''}`;
                oppEl.innerHTML = `
                    ${isUno ? `<span class="absolute -top-2 -right-1 px-1.5 py-0.2 rounded-full text-[9px] font-game font-bold ${p.unoCalled ? 'bg-yellow-400 text-slate-950' : 'bg-rose-600 text-white animate-bounce'}">${p.unoCalled ? 'UNO!' : 'LUPA UNO?'}</span>` : ''}
                    <div class="text-xs font-bold text-white truncate max-w-[90px] mx-auto">
                        ${p.isBot ? '🤖 ' : ''}${escapeHtml(p.name)}
                    </div>
                    <div class="flex items-center justify-center gap-1 mt-1">
                        <span class="inline-block w-3.5 h-5 rounded-sm bg-red-500 border border-white/80"></span>
                        <span class="font-game text-sm text-yellow-400 font-bold">${p.hand.length}</span>
                    </div>
                    <div class="text-[9px] text-slate-400 mt-0.5">${p.score} pts</div>
                `;
                opponentsBar.appendChild(oppEl);
            });

            // 2. Render Indikator Giliran & Arah Putaran
            const dirIcon = document.getElementById('direction-icon');
            const dirCenter = document.getElementById('direction-arrow-center');
            if (gameState.direction === 1) {
                dirIcon.className = 'text-base inline-block spin-cw';
                dirCenter.textContent = '↻';
            } else {
                dirIcon.className = 'text-base inline-block spin-ccw';
                dirCenter.textContent = '↺';
            }

            const turnBadge = document.getElementById('turn-indicator-badge');
            const turnText = document.getElementById('turn-text');
            if (isMyTurn) {
                turnBadge.className = 'inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-yellow-400 text-slate-950 font-bold shadow-lg shadow-yellow-400/30';
                turnText.className = 'font-game text-sm sm:text-base text-slate-950';
                turnText.textContent = '⭐ GILIRAN KAMU!';
            } else {
                turnBadge.className = 'inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-slate-900/90 border border-slate-700 shadow-md';
                turnText.className = 'font-game text-sm sm:text-base text-white';
                turnText.textContent = `Giliran: ${currentPlayer ? currentPlayer.name : '-'}`;
            }

            document.getElementById('last-action-log').textContent = gameState.lastActionText;

            // 3. Render Deck, Discard Pile & Warna Aktif
            document.getElementById('deck-count-badge').textContent = gameState.deck.length;
            const drawPileEl = document.getElementById('draw-pile-card');
            if (isMyTurn && !gameState.hasDrawnThisTurn) {
                drawPileEl.classList.add('ring-2', 'ring-yellow-400', 'cursor-pointer');
            } else {
                drawPileEl.classList.remove('ring-2', 'ring-yellow-400');
            }

            const orb = document.getElementById('active-color-orb');
            const colorClasses = {
                red: 'bg-red-500 shadow-red-500/50',
                yellow: 'bg-yellow-400 shadow-yellow-400/50',
                green: 'bg-green-500 shadow-green-500/50',
                blue: 'bg-blue-500 shadow-blue-500/50'
            };
            orb.className = `w-11 h-11 rounded-full border-4 border-white/90 shadow-lg transition-colors duration-300 flex items-center justify-center ${colorClasses[gameState.currentColor] || 'bg-slate-600'}`;
            document.getElementById('active-color-label').textContent = COLOR_NAMES_ID[gameState.currentColor] || '-';

            if (topCard) {
                document.getElementById('discard-pile-slot').innerHTML = createCardHTML(topCard, 'cursor-default');
            }

            // 4. Render Tombol Aksi (Teriak UNO, Tangkap UNO, Pass Turn)
            const btnSayUno = document.getElementById('btn-say-uno');
            const btnCatchUno = document.getElementById('btn-catch-uno');
            const btnPassTurn = document.getElementById('btn-pass-turn');

            // Pemain bisa teriak UNO jika kartunya tinggal 1 atau 2 (saat akan membuang kartu ke-2)
            if (me && me.hand.length <= 2 && me.hand.length > 0 && !me.unoCalled) {
                btnSayUno.classList.remove('hidden');
            } else {
                btnSayUno.classList.add('hidden');
            }

            // Pemain bisa menangkap lawan yang kartunya 1 tapi belum teriak UNO
            const someoneForgotUno = gameState.players.some(p => p.id !== myPeerId && p.hand.length === 1 && !p.unoCalled);
            if (someoneForgotUno && gameState.phase === 'playing') {
                btnCatchUno.classList.remove('hidden');
            } else {
                btnCatchUno.classList.add('hidden');
            }

            // Tombol Lewati Giliran muncul jika sudah ambil 1 kartu di giliran ini
            if (isMyTurn && gameState.hasDrawnThisTurn) {
                btnPassTurn.classList.remove('hidden');
            } else {
                btnPassTurn.classList.add('hidden');
            }

            // 5. Render Kartu di Tangan Pemain Sendiri
            const handContainer = document.getElementById('my-hand-container');
            handContainer.innerHTML = '';

            if (me) {
                document.getElementById('my-player-badge').textContent = `${me.name} (${me.hand.length} kartu) • ${me.score} pts`;
                const myUnoBadge = document.getElementById('my-uno-status');
                if (me.unoCalled && me.hand.length === 1) myUnoBadge.classList.remove('hidden');
                else myUnoBadge.classList.add('hidden');

                const turnHint = document.getElementById('my-turn-hint');
                if (isMyTurn) {
                    turnHint.textContent = gameState.hasDrawnThisTurn
                        ? 'Mainkan kartu yang baru diambil atau klik Lewati'
                        : 'Tap kartu yang menyala atau ambil dari deck';
                    turnHint.className = 'text-[11px] text-yellow-400 font-semibold';
                } else {
                    turnHint.textContent = 'Menunggu giliran lawan...';
                    turnHint.className = 'text-[11px] text-slate-400';
                }

                // Urutkan tampilan atau biarkan sesuai urutan indeks asli agar indeks klik akurat
                me.hand.forEach((card, index) => {
                    const playable = isMyTurn && isCardPlayable(card, topCard, gameState.currentColor);
                    const stateClass = isMyTurn
                        ? (playable ? 'hand-card-playable' : 'hand-card-disabled')
                        : 'opacity-90';
                    const clickAttr = playable ? `onclick="onMyCardClick(${index})"` : '';
                    handContainer.insertAdjacentHTML('beforeend', createCardHTML(card, stateClass, clickAttr));
                });
            }
        }

        function renderWinnerModal() {
            const winner = gameState.players.find(p => p.id === gameState.winnerId);
            document.getElementById('winner-announcement').textContent = winner
                ? `🎉 ${winner.name} Memenangkan Ronde Ini!`
                : 'Ronde Selesai!';

            const sortedPlayers = [...gameState.players].sort((a, b) => b.score - a.score);
            const listEl = document.getElementById('scoreboard-list');
            listEl.innerHTML = sortedPlayers.map((p, idx) => `
                <div class="flex items-center justify-between py-1.5 px-2.5 rounded-xl ${p.id === gameState.winnerId ? 'bg-yellow-400/15 border border-yellow-400/30' : 'bg-slate-900'}">
                    <span class="font-semibold text-white">${idx === 0 ? '👑 ' : ''}${escapeHtml(p.name)}</span>
                    <span class="font-game text-yellow-400 font-bold">${p.score} Poin</span>
                </div>
            `).join('');

            if (isHost) {
                document.getElementById('winner-host-actions').classList.remove('hidden');
                document.getElementById('winner-client-wait').classList.add('hidden');
            } else {
                document.getElementById('winner-host-actions').classList.add('hidden');
                document.getElementById('winner-client-wait').classList.remove('hidden');
            }

            toggleModal('winner-modal', true);
        }

        // ============================================================================
        // 9. INTERAKSI SENTUH / KLIK PENGGUNA
        // ============================================================================
        function onMyCardClick(cardIndex) {
            const me = gameState.players.find(p => p.id === myPeerId);
            const currentPlayer = gameState.players[gameState.turnIndex];
            if (!me || !currentPlayer || currentPlayer.id !== myPeerId) return;

            const card = me.hand[cardIndex];
            const topCard = gameState.discardPile[gameState.discardPile.length - 1];
            if (!card || !isCardPlayable(card, topCard, gameState.currentColor)) {
                showToast('Kartu ini tidak cocok dengan warna/angka di meja!', 'warn');
                return;
            }

            if (card.color === 'wild') {
                // Buka modal pemilih warna terlebih dahulu
                pendingWildCardIndex = cardIndex;
                toggleModal('color-picker-modal', true);
            } else {
                sendToHost({
                    type: 'PLAY_CARD',
                    cardIndex: cardIndex,
                    chosenColor: card.color
                });
            }
        }

        function selectWildColor(color) {
            toggleModal('color-picker-modal', false);
            if (pendingWildCardIndex === null) return;
            sendToHost({
                type: 'PLAY_CARD',
                cardIndex: pendingWildCardIndex,
                chosenColor: color
            });
            pendingWildCardIndex = null;
        }

        function handleDrawCardClick() {
            const currentPlayer = gameState.players[gameState.turnIndex];
            if (!currentPlayer || currentPlayer.id !== myPeerId) {
                showToast('Bukan giliranmu untuk mengambil kartu!', 'warn');
                return;
            }
            if (gameState.hasDrawnThisTurn) {
                showToast('Kamu sudah mengambil 1 kartu di giliran ini.', 'info');
                return;
            }
            sendToHost({ type: 'DRAW_CARD' });
        }

        function passTurnAfterDraw() {
            sendToHost({ type: 'PASS_TURN' });
        }

        function sayUno() {
            sendToHost({ type: 'SAY_UNO' });
        }

        function catchUno() {
            sendToHost({ type: 'CATCH_UNO' });
        }

        function escapeHtml(str) {
            return String(str)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;');
        }

        // Pulihkan nama tersimpan jika ada di localStorage
        window.addEventListener('DOMContentLoaded', () => {
            try {
                const savedName = localStorage.getItem('uno_p2p_player_name');
                if (savedName) document.getElementById('input-player-name').value = savedName;
                document.getElementById('input-player-name').addEventListener('change', (e) => {
                    localStorage.setItem('uno_p2p_player_name', e.target.value.trim());
                });
            } catch (e) {}
        });
    </script>
</body>
</html>