#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Utility to check for libraries' versions"""

from contextlib import closing
import json
from functools import cmp_to_key
import os
import re
from typing import Dict, Any
from urllib.request import Request
from urllib.request import urlopen


class Net:
    @staticmethod
    def _get(url: str) -> bytes:
        request = Request(url, headers={"User-Agent": "Python"})

        with closing(urlopen(request)) as r:
            return r.read()


class Version:
    VERSION_REGEX = re.compile(
        r"v?(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?"
        "("
        "[._-]?"
        r"(?:(stable|beta|b|RC|alpha|a|patch|pl|p)((?:[.-]?\d+)*)?)?"
        "([.-]?dev)?"
        ")?"
        r"(?:\+[^\s]+)?"
    )

    def __init__(self, metadata):
        self.metadata = metadata

    def get_version(self):
        def _compare_versions(x, y):
            mx = self.VERSION_REGEX.match(x)
            my = self.VERSION_REGEX.match(y)

            vx = tuple(int(p or "0") for p in mx.groups()[:3]) + (mx.group(5),)
            vy = tuple(int(p or "0") for p in my.groups()[:3]) + (my.group(5),)

            if vx < vy:
                return -1
            elif vx > vy:
                return 1

            return 0

        releases = sorted(
            self.metadata["releases"].keys(), key=cmp_to_key(_compare_versions)
        )

        for release in reversed(releases):
            m = self.VERSION_REGEX.match(release)

            version = release

            return version


class Pypi(Net):
    """JSON APi."""

    server = "https://pypi.org"
    endpoints = {
        "project": server + "/pypi/{project_name}/json",
        "release": server + "/pypi/{project_name}/{version}/json",
    }

    def __init__(self, name: str):
        self.name = name
        self._meta: Optional[Dict[str, Any]] = None
        self.project = self.endpoints["project"].format(project_name=self.name)

    @property
    def meta(self):
        if not self._meta:
            self._meta = self._get_json(self.project)
        return self._meta

    @property
    def version(self):
        return Version(self.meta).get_version()

    @classmethod
    def info(cls, package: str) -> Dict[str, Any]:
        """Get package info from pypi."""

    @classmethod
    def _get_json(cls, url: str) -> Dict[str, Any]:
        html = cls._get(url)
        return json.loads(html)


def check_version(pkg):
    print(Pypi(pkg).version)
    return 0


def cli():
    import sys

    args = sys.argv[1:]
    if len(args) != 1:
        raise ValueError("usage: check_version [opts] [package]")

    sys.exit(check_version(args[0]))


if __name__ == "__main__":
    cli()
