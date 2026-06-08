#!/usr/bin/env python3
import http.server
import socketserver
import os
import sys
import json
import markov_ai
import cfg_ai

PORT = 8000
DIRECTORY = "export/web"

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def end_headers(self):
        # The COOP and COEP headers are required for SharedArrayBuffer support in Godot 4 Web exports
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        # Ensure correct MIME type for WebAssembly
        if self.path.endswith(".wasm"):
            self.send_header("Content-Type", "application/wasm")
        super().end_headers()

    def do_GET(self):
        if self.path == "/api/agent/customer":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            
            # Generare 100% locala si instanta cu propriul nostru AI (Markov Chain LM)
            response_text = markov_ai.get_customer_reply()
            
            self.wfile.write(json.dumps({"text": response_text}).encode("utf-8"))
            return
            
        elif self.path == "/api/agent/splash":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            
            # Generare 100% locala folosind Symbolic AI (Context-Free Grammar)
            response_text = cfg_ai.get_splash_text()
            
            self.wfile.write(json.dumps({"text": response_text}).encode("utf-8"))
            return
            
        else:
            super().do_GET()

if not os.path.exists(DIRECTORY):
    os.makedirs(DIRECTORY)

socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Serving {DIRECTORY} at http://localhost:{PORT}")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping server.")
        sys.exit(0)
