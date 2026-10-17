"""Gauche(gosh)用のJupyterラッパーカーネル。

goshをサブプロセスとして起動し、driver.scmのREPLループにセルのソースを送る。
"""

import os
import signal
import subprocess

from ipykernel.kernelapp import IPKernelApp
from ipykernel.kernelbase import Kernel

DRIVER = os.path.join(os.path.dirname(os.path.abspath(__file__)), "driver.scm")
DONE_OK = b"\x02JUPYTER-DONE:ok\x03"
DONE_ERROR = b"\x02JUPYTER-DONE:error\x03"


def scheme_string_literal(src: str) -> str:
    escaped = src.replace("\\", "\\\\").replace('"', '\\"')
    escaped = escaped.replace("\r", "").replace("\n", "\\n")
    return f'"{escaped}"'


class GaucheKernel(Kernel):
    implementation = "gauche_kernel"
    implementation_version = "0.1"
    language = "scheme"
    language_version = "R7RS"
    language_info = {
        "name": "scheme",
        "mimetype": "text/x-scheme",
        "file_extension": ".scm",
        "codemirror_mode": "scheme",
        "pygments_lexer": "scheme",
    }
    banner = "Gauche (gosh) kernel"

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self._start_gosh()

    def _start_gosh(self):
        # 自前でSIGINTを転送するため、goshは別プロセスグループで起動する
        self.gosh = subprocess.Popen(
            ["gosh", DRIVER],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            start_new_session=True,
        )

    def _read_until_done(self, silent: bool) -> bool:
        """終端マーカーまで出力を読み、ストリームに流す。成功ならTrueを返す。"""
        buf = b""
        while True:
            try:
                chunk = os.read(self.gosh.stdout.fileno(), 4096)
            except KeyboardInterrupt:
                self.gosh.send_signal(signal.SIGINT)
                continue
            if not chunk:
                self._emit(buf, silent)
                self._emit(b"*** gosh process exited; restarting\n", silent)
                self._start_gosh()
                return False
            buf += chunk
            for marker, ok in ((DONE_OK, True), (DONE_ERROR, False)):
                idx = buf.find(marker)
                if idx >= 0:
                    self._emit(buf[:idx], silent)
                    return ok
            # マーカーが分割されて届く場合に備えて末尾は保留する
            keep = len(DONE_ERROR)
            if len(buf) > keep:
                self._emit(buf[:-keep], silent)
                buf = buf[-keep:]

    def _emit(self, data: bytes, silent: bool):
        if silent or not data:
            return
        self.send_response(
            self.iopub_socket,
            "stream",
            {"name": "stdout", "text": data.decode("utf-8", errors="replace")},
        )

    def do_execute(
        self, code, silent, store_history=True, user_expressions=None, allow_stdin=False
    ):
        if not code.strip():
            return self._ok_reply()
        self.gosh.stdin.write(
            f"(%jupyter-eval {scheme_string_literal(code)})\n".encode("utf-8")
        )
        self.gosh.stdin.flush()
        if self._read_until_done(silent):
            return self._ok_reply()
        return {
            "status": "error",
            "execution_count": self.execution_count,
            "ename": "SchemeError",
            "evalue": "",
            "traceback": [],
        }

    def _ok_reply(self):
        return {
            "status": "ok",
            "execution_count": self.execution_count,
            "payload": [],
            "user_expressions": {},
        }

    def do_shutdown(self, restart):
        self.gosh.terminate()
        return {"status": "ok", "restart": restart}


if __name__ == "__main__":
    IPKernelApp.launch_instance(kernel_class=GaucheKernel)
