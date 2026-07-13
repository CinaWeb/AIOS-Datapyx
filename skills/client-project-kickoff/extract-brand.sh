#!/usr/bin/env bash
# extract-brand.sh <url>
# Downloads raw HTML (+ response headers) for a client site and greps for
# brand signals (logo candidates, theme color, inline hex colors, CSS color
# custom properties, Google Fonts links, font-family declarations) and
# tech-stack signals (CMS/platform, server headers).
# Adapt/extend as needed (e.g. fetch linked stylesheets too).
set -euo pipefail
url="$1"
html="$(curl -sL "$url")"
headers="$(curl -sIL "$url")"

echo "== Logo candidates =="
grep -oE '<link[^>]+rel="[^"]*icon[^"]*"[^>]*>' <<<"$html" || true
grep -oE '<meta[^>]+property="og:image"[^>]*>' <<<"$html" || true
grep -oE '<img[^>]+(class|alt)="[^"]*logo[^"]*"[^>]*>' <<<"$html" || true

echo "== Theme color meta =="
grep -oE '<meta[^>]+name="theme-color"[^>]*>' <<<"$html" || true

echo "== Inline hex colors =="
grep -oE '#[0-9a-fA-F]{6}\b' <<<"$html" | sort -u || true

echo "== CSS custom properties (--color-*, --primary etc.) =="
grep -oE -- '--[a-zA-Z0-9_-]*(color|primary|secondary|accent)[a-zA-Z0-9_-]*[[:space:]]*:[[:space:]]*#?[0-9a-fA-F]{3,8}' <<<"$html" || true

echo "== Google Fonts links =="
grep -oE '<link[^>]+fonts\.googleapis\.com[^>]*>' <<<"$html" || true

echo "== font-family declarations =="
grep -oE "font-family:[[:space:]]*[^;\"']+" <<<"$html" | sort -u || true

echo "== Linked stylesheets (fetch these too for more colors/fonts) =="
grep -oE '<link[^>]+rel="stylesheet"[^>]+href="[^"]+"' <<<"$html" || true

echo "== Platform/CMS signals =="
grep -oE '<meta[^>]+name="generator"[^>]*>' <<<"$html" || true
grep -qoE '/wp-content/|/wp-includes/|/wp-json/' <<<"$html" && echo "-> WordPress signal found (/wp-content|/wp-includes|/wp-json)" || true
grep -qoE 'cdn\.shopify\.com' <<<"$html" && echo "-> Shopify signal found (cdn.shopify.com)" || true
grep -qoE '\.webflow\.io|website-files\.com' <<<"$html" && echo "-> Webflow signal found" || true
grep -qoE 'squarespace\.com' <<<"$html" && echo "-> Squarespace signal found" || true
grep -qoE 'wix\.com|wixstatic\.com' <<<"$html" && echo "-> Wix signal found" || true

echo "== Server / hosting headers =="
grep -iE '^(server|x-powered-by):' <<<"$headers" || true
