#!/usr/bin/env python3
"""Create a byte-reproducible source/PDF release archive."""

from __future__ import annotations

import argparse
import gzip
import hashlib
from pathlib import Path
import subprocess
import tarfile


ROOT = Path(__file__).resolve().parents[1]
RELEASE_EPOCH = 1790208000  # 2026-09-24 00:00:00 UTC


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def release_files() -> list[Path]:
    process = subprocess.run(
        ["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"],
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=True,
    )
    relative_paths = [Path(item.decode()) for item in process.stdout.split(b"\0") if item]
    files = [path for path in relative_paths if (ROOT / path).is_file()]
    return sorted(files, key=lambda item: item.as_posix())


def build_archive(version: str, output_dir: Path) -> tuple[Path, Path, int]:
    prefix = f"PseudoArithmetic-{version}"
    output_dir.mkdir(parents=True, exist_ok=True)
    archive = output_dir / f"{prefix}.tar.gz"
    checksum = output_dir / f"{prefix}.tar.gz.sha256"
    files = release_files()

    with archive.open("wb") as raw_stream:
        with gzip.GzipFile(filename="", mode="wb", fileobj=raw_stream, mtime=0) as gzip_stream:
            with tarfile.open(fileobj=gzip_stream, mode="w", format=tarfile.PAX_FORMAT) as tar:
                for relative in files:
                    source = ROOT / relative
                    info = tar.gettarinfo(str(source), arcname=f"{prefix}/{relative.as_posix()}")
                    info.uid = 0
                    info.gid = 0
                    info.uname = "root"
                    info.gname = "root"
                    info.mtime = RELEASE_EPOCH
                    info.mode = 0o755 if source.stat().st_mode & 0o111 else 0o644
                    info.pax_headers = {}
                    with source.open("rb") as stream:
                        tar.addfile(info, stream)

    digest = sha256(archive)
    checksum.write_text(f"{digest}  {archive.name}\n", encoding="utf-8")
    return archive, checksum, len(files)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", type=Path, default=ROOT / "dist")
    arguments = parser.parse_args()

    version = (ROOT / "VERSION").read_text(encoding="utf-8").strip()
    archive, checksum, count = build_archive(version, arguments.output_dir)
    print(f"archive={archive}")
    print(f"checksum_file={checksum}")
    print(f"sha256={sha256(archive)}")
    print(f"file_count={count}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
