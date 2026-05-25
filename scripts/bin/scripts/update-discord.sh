#!/bin/bash

# Pfade
WAL_COLORS="$HOME/.cache/wal/colors.css"
THEME_DIR="$HOME/.var/app/com.discordapp.Discord/config/BetterDiscord/themes"
OUTPUT_FILE="$THEME_DIR/PywalFlatpak.theme.css"

if [ ! -f "$WAL_COLORS" ]; then
    echo "Fehler: Keine Wal-Farben gefunden."
    exit 1
fi

cat "$WAL_COLORS" >> "$OUTPUT_FILE"

cat <<EOF >> "$OUTPUT_FILE"

:root {
    /* --- FARBEN --- */
    --wal-bg: var(--background);
    /* Sidebar/Panels: 6% heller */
    --wal-sidebar: color-mix(in srgb, var(--background), white 6%);
    /* Eingabefelder/Karten: 10% heller */
    --wal-lighter: color-mix(in srgb, var(--background), white 10%);
    
    --wal-accent: var(--color2);
    --wal-text: var(--foreground);
    --wal-dim: var(--color8);

    /* --- BASIS VARIABLEN --- */
    --background-primary: var(--wal-bg) !important;
    --background-secondary: var(--wal-sidebar) !important;
    --background-tertiary: var(--wal-bg) !important;
    --background-accent: var(--wal-accent) !important;
    --bg-base-primary: var(--wal-bg) !important;
    --bg-base-secondary: var(--wal-sidebar) !important;
    --home-background: var(--wal-bg) !important;
}

/* ========================================================================
   1. HAUPTBEREICHE
   ======================================================================== */

/* Hintergrund der App */
body, #app-mount, .app-1q1i1E {
    background-color: var(--wal-bg) !important;
}

/* MITTE: FREUNDESLISTE & CHAT */
div[class*="peopleColumn"] {
    background-color: var(--wal-bg) !important;
}
/* Der Chat-Hintergrund */
main[class*="chatContent"], div[class*="chat"] {
    background-color: var(--wal-bg) !important;
}
/* Der Header oben (Online/Alle...) */
section[class*="title"], div[class*="container"][class*="themed"] {
    background-color: var(--wal-bg) !important;
}
div[class*="tabBody"] {
    background-color: var(--wal-bg) !important;
}

/* ========================================================================
   2. SEITENLEISTEN
   ======================================================================== */

/* LINKS: KANÄLE */
div[class*="sidebar"] {
    background-color: var(--wal-sidebar) !important;
}
/* User Panel unten links */
section[class*="panels"] {
    background-color: var(--wal-sidebar) !important;
}
/* Suchleiste links */
div[class*="searchBar"] {
    background-color: var(--wal-lighter) !important;
}

/* GANZ LINKS: SERVER */
nav[class*="guilds"] {
    background-color: var(--wal-bg) !important;
}
/* Scroller transparent machen, damit Hintergrund sichtbar ist */
nav[class*="guilds"] [class*="scroller"] {
    background-color: transparent !important;
}

/* ========================================================================
   3. RECHTS
   ======================================================================== */

div[class*="nowPlayingColumn"] {
    background-color: var(--wal-bg) !important;
}
div[class*="nowPlayingColumn"] [class*="scroller"] {
    background-color: transparent !important;
}
div[class*="itemCard"], div[class*="outer"] {
    background-color: var(--wal-lighter) !important;
    border: 1px solid var(--wal-accent) !important;
    border-radius: 5px;
}
/* Hover bei Karten */
div[class*="itemCard"]:hover {
    background-color: color-mix(in srgb, var(--wal-lighter), white 5%) !important;
}

/* ========================================================================
   4. DETAILS & FIXES
   ======================================================================== */

/* "Freund hinzufügen" Button (Lila wegmachen) */
button[class*="lookFilled"][class*="colorBrand"] {
    background-color: var(--wal-accent) !important;
    color: var(--wal-bg) !important;
}

/* Eingabefelder */
div[class*="channelTextArea"] {
    background-color: var(--wal-lighter) !important;
}
div[class*="scrollableContainer"] {
    background-color: var(--wal-lighter) !important;
}

/* Textfarben */
div, span, h2, h3 { color: var(--wal-text); }
div[class*="subtext"], div[class*="note"] { color: var(--wal-dim) !important; }

/* Scrollbars */
::-webkit-scrollbar-thumb { background: var(--wal-accent) !important; }
::-webkit-scrollbar-track { background: transparent !important; }

EOF

echo "V20 applied. Please reload Discord (Ctrl+R)."
