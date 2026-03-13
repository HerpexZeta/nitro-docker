#!/usr/bin/env node
/**
 * Nitro WebSocket Proxy — built-in modules only (no npm deps)
 *
 * Listens on port 3000 (publicly proxied by Replit) and forwards all
 * WebSocket traffic to the Arcturus emulator on localhost:2096.
 *
 * Uses Node.js built-in 'http' and 'net' modules only.
 */

const http = require('http');
const net  = require('net');

const PROXY_PORT    = 3000;
const ARCTURUS_HOST = '127.0.0.1';
const ARCTURUS_PORT = 2096;

let connectionCount = 0;

const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('Nitro WebSocket Proxy — connect via ws://\n');
});

server.on('upgrade', (req, clientSocket, head) => {
    const id = ++connectionCount;
    const origin = req.headers['origin'] || 'unknown';
    console.log(`[WS Proxy #${id}] Upgrade request from ${origin} for ${req.url}`);

    const backendSocket = net.createConnection(ARCTURUS_PORT, ARCTURUS_HOST, () => {
        console.log(`[WS Proxy #${id}] Connected to Arcturus at ${ARCTURUS_HOST}:${ARCTURUS_PORT}`);

        // Forward the original HTTP upgrade request to Arcturus
        const requestLine = `${req.method} ${req.url} HTTP/${req.httpVersion}\r\n`;
        const headers = Object.entries(req.headers)
            .map(([k, v]) => `${k}: ${v}`)
            .join('\r\n');
        backendSocket.write(requestLine + headers + '\r\n\r\n');

        if (head && head.length > 0) {
            backendSocket.write(head);
        }

        // Bidirectional pipe
        backendSocket.pipe(clientSocket);
        clientSocket.pipe(backendSocket);
    });

    backendSocket.on('error', (err) => {
        console.error(`[WS Proxy #${id}] Arcturus unreachable: ${err.message}`);
        // Send a proper HTTP error back to the client before closing
        try {
            clientSocket.write(
                'HTTP/1.1 502 Bad Gateway\r\n' +
                'Content-Type: text/plain\r\n' +
                'Connection: close\r\n\r\n' +
                'Arcturus emulator is not running on port 2096\n'
            );
        } catch (_) {}
        clientSocket.destroy();
    });

    backendSocket.on('close', () => {
        console.log(`[WS Proxy #${id}] Arcturus closed connection`);
        clientSocket.destroy();
    });

    clientSocket.on('error', (err) => {
        console.error(`[WS Proxy #${id}] Client error: ${err.message}`);
        backendSocket.destroy();
    });

    clientSocket.on('close', () => {
        console.log(`[WS Proxy #${id}] Client disconnected`);
        backendSocket.destroy();
    });
});

server.listen(PROXY_PORT, '0.0.0.0', () => {
    console.log(`[WS Proxy] Listening on port ${PROXY_PORT}`);
    console.log(`[WS Proxy] Forwarding WebSocket → ${ARCTURUS_HOST}:${ARCTURUS_PORT}`);
});
