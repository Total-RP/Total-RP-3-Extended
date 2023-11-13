#!/usr/bin/env python3

import argparse
import enum
import json
import os
from pathlib import Path

import requests
from luaparser import ast, astnodes
from requests.adapters import HTTPAdapter, Retry

CF_PROJECT_ID: str
"""CurseForge project ID."""

LOCALE_DIR: Path
"""Directory path containing localization files of the form 'enUS.lua'."""


class Locale(enum.Enum):
    deDE = 'deDE'
    esES = 'esES'
    esMX = 'esMX'
    frFR = 'frFR'
    itIT = 'itIT'
    koKR = 'koKR'
    ptBR = 'ptBR'
    ruRU = 'ruRU'
    zhCN = 'zhCN'
    zhTW = 'zhTW'

    def name(self):
        if self == Locale.deDE:
            return 'Deutsch'
        elif self == Locale.esES:
            return 'Español (EU)'
        elif self == Locale.esMX:
            return 'Español (AL)'
        elif self == Locale.frFR:
            return 'Français'
        elif self == Locale.itIT:
            return 'Italiano'
        elif self == Locale.koKR:
            return '한국어'
        elif self == Locale.ptBR:
            return 'Português'
        elif self == Locale.ruRU:
            return 'Pусский'
        elif self == Locale.zhCN:
            return '简体中文'
        elif self == Locale.zhTW:
            return '繁體中文'


def find_table_assignment(variable_name: str, statements: list[astnodes.Statement]):
    """
    Extracts the first statement from the given list that represents an
    assignment of a table constructor literal to a named variable, returning
    a tuple of the assigned variable name and the table constructor expression.

    If no table constructor assignment to the named variable is present in the
    given list of statements, None is returned.
    """

    for stmt in statements:
        if not isinstance(stmt, astnodes.Assign):
            continue

        for target, value in zip(stmt.targets, stmt.values):
            if isinstance(target, astnodes.Name) and target.id == variable_name and isinstance(value, astnodes.Table):
                return (target, value)

    return None


def convert_to_table_additions(target: astnodes.Name, value: astnodes.Table):
    """
    Converts a table constructor literal ('{ foo = "bar", ...}') to a block of
    table assignment statements.
    """

    body: list[astnodes.Statement] = []

    for field in value.fields:
        key = astnodes.String(field.key.id) if isinstance(
            field.key, astnodes.Name) else field.key

        index = astnodes.Index(key, target, notation=astnodes.IndexNotation.SQUARE)
        body.append(astnodes.Assign([index], [field.value]))

    return astnodes.Block(body)


def cf_prepare_session():
    """
    Prepares a CF API exchange session with an API token sourced from the
    local environment and retry logic attached to deal with the CF API's
    ever-present desire to just decide it doesn't want to work.
    """
    session = requests.Session()
    session.mount('https://', HTTPAdapter(max_retries=Retry(total=0, backoff_factor=1, status_forcelist=[500])))
    session.headers['x-api-token'] = os.getenv('CF_API_KEY')

    return session


def cf_upload_localization(path: Path, *, delete_missing_phrases: bool, dry_run: bool):
    session = cf_prepare_session()

    with path.open('r', encoding='utf-8') as f:
        chunk = ast.parse(f.read())
        assignment = find_table_assignment('L', chunk.body.body)

        if not assignment:
            raise RuntimeError(f'Failed to find translations in file: {path}')

        additions = convert_to_table_additions(*assignment)
        translations = ast.to_lua_source(additions)

    if dry_run:
        print(translations)
        return

    r = session.post(
        f'https://wow.curseforge.com/api/projects/{CF_PROJECT_ID}/localization/import',
        files={
            'metadata': (None, json.dumps({
                'language': 'enUS',
                'missing-phrase-handling': 'DeletePhrase' if delete_missing_phrases else 'DoNothing',
            })),
            'localizations': (None, translations),
        }
    )

    r.raise_for_status()


def cf_download_localization(locale: Locale, path: Path, *, dry_run: bool):
    url = f"https://wow.curseforge.com/api/projects/{CF_PROJECT_ID}/localization/export"
    params = {'lang': locale.value, 'export-type': 'Table', 'unlocalized': 'Ignore'}

    session = cf_prepare_session()
    res = session.get(url, params=params)
    res.raise_for_status()
    contents = res.content.decode('utf-8').replace('\r\n', '\n')

    if dry_run:
        print(contents)
        return

    with path.open('w+', encoding='utf-8', newline='\r\n') as f:
        f.write(f"""\
-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

-- THIS FILE IS AUTOMATICALLY GENERATED.
-- ALL MODIFICATIONS TO THIS FILE WILL BE LOST.

TRP3_API.loc:GetLocale("{locale.value}"):AddTexts({contents[4:]});
""")


def cf_download_multiple_localizations(locales: list[Locale] | None, *, dry_run: bool):
    if locales:
        locales = [Locale(l) for l in locales]
    else:
        locales = Locale

    for locale in locales:
        print(f'Processing locale: {locale.value}...')
        path = LOCALE_DIR / f'{locale.value}.lua'
        cf_download_localization(locale, path, dry_run=dry_run)


# fmt: off

parser = argparse.ArgumentParser(prog='upload-localization.py', description='CurseForge localization toolkit.')
parser.add_argument('-p', '--project-id', help='CurseForge project ID', required=True)
parser.add_argument('-r', '--locale-dir', help='Path to the directory of localization scripts', required=True, type=Path)

commands = parser.add_subparsers(title='commands', metavar=None)

upload = commands.add_parser('upload', help='Uploads translation strings to CurseForge')
upload.add_argument('-d', '--delete-missing-phrases', help='Mark missing phrases as deleted.', action='store_true')
upload.add_argument('-n', '--dry-run', help='Do not submit localization strings to CurseForge; only print them.', action='store_true')
upload.set_defaults(func=lambda args: cf_upload_localization(LOCALE_DIR / 'enUS.lua', delete_missing_phrases=args.delete_missing_phrases, dry_run=args.dry_run))

download = commands.add_parser('download', help='Fetches translation strings from CurseForge')
download.add_argument('-l', '--locale', help='Locale to download. Can be repeated for multiple locales. If not supplied, download all locales.', action='extend', nargs='*')
download.add_argument('-n', '--dry-run', help='Do not write localization strings to disk; only print them.', action='store_true')
download.set_defaults(func=lambda args: cf_download_multiple_localizations(args.locale, dry_run=args.dry_run))

# fmt: on

args = parser.parse_args()

CF_PROJECT_ID = args.project_id
LOCALE_DIR = args.locale_dir

if 'func' in args:
    args.func(args)
else:
    parser.print_help()
