"""Publish a checked GitHub release to CurseForge; default is a local dry run.

Uses the official Upload API. No retry after POST: an ambiguous network failure
must be checked in the author console before rerunning to avoid duplicate files.
"""
import argparse
import json
import os
from pathlib import Path
import re
import urllib.error
import urllib.request
import uuid
import zipfile

API = 'https://www.curseforge.com/api'
PROJECT = 1792380


def prepare(event):
    release = event['release']
    tag = release['tag_name']
    if not re.fullmatch(r'v\d+\.\d+\.\d+', tag) or release.get('draft'):
        raise ValueError('Expected a published vX.Y.Z release')
    version = tag[1:]
    archive = Path(f'outputs/WaylaidValue-{version}.zip')
    with zipfile.ZipFile(archive) as z:
        if z.testzip() or len(set(z.namelist())) != len(z.namelist()):
            raise ValueError('Invalid ZIP')
        for name in z.namelist():
            parts = name.split('/')
            if len(parts) != 2 or parts[0] != 'WaylaidValue' or parts[1] in ('', '.', '..'):
                raise ValueError('Unexpected ZIP path')
        toc = z.read('WaylaidValue/WaylaidValue.toc').decode()
        if not re.search(r'^## Version: ' + re.escape(version) + r'$', toc, re.M):
            raise ValueError('Release tag and TOC differ')
        if not re.search(r'^## Interface: 16001$', toc, re.M):
            raise ValueError('Expected Forever interface 16001')
    notes = release.get('body') or ''
    if not notes.strip():
        raise ValueError('Release notes are required')
    return archive, {
        'displayName': f'Waylaid Value {version} — Forever',
        'changelog': notes,
        'changelogType': 'markdown',
        'releaseType': 'beta' if release.get('prerelease') else 'release',
        'isMarkedForManualRelease': False,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--event', default=os.environ.get('GITHUB_EVENT_PATH'))
    parser.add_argument('--upload', action='store_true')
    args = parser.parse_args()
    if not args.event:
        parser.error('--event or GITHUB_EVENT_PATH is required')
    archive, metadata = prepare(json.loads(Path(args.event).read_text()))
    if not args.upload:
        print(f'Dry run: {archive} → CurseForge {PROJECT}, {metadata["releaseType"]}, Forever 1.60.1')
        return
    token = os.environ.get('CF_API_KEY', '').strip()
    if not token:
        raise SystemExit('Missing GitHub Actions secret CF_API_KEY; no upload attempted')
    headers = {'X-Api-Token': token, 'User-Agent': 'WaylaidValue-release'}
    try:
        req = urllib.request.Request(API + '/game/versions', headers=headers)
        with urllib.request.urlopen(req, timeout=60) as response:
            versions = json.load(response)
        matches = [v for v in versions if v['name'] == '1.60.1']
        if len(matches) != 1:
            raise ValueError('Forever 1.60.1 did not resolve uniquely; no upload attempted')
        metadata['gameVersions'] = [matches[0]['id']]
        boundary = 'WaylaidValue' + uuid.uuid4().hex
        filename = archive.stem + '-forever.zip'
        body = (f'--{boundary}\r\nContent-Disposition: form-data; name="metadata"\r\n\r\n'
                + json.dumps(metadata) + f'\r\n--{boundary}\r\n'
                + f'Content-Disposition: form-data; name="file"; filename="{filename}"\r\n'
                + 'Content-Type: application/zip\r\n\r\n').encode()
        body += archive.read_bytes() + f'\r\n--{boundary}--\r\n'.encode()
        headers['Content-Type'] = f'multipart/form-data; boundary={boundary}'
        req = urllib.request.Request(f'{API}/projects/{PROJECT}/upload-file', body, headers)
        with urllib.request.urlopen(req, timeout=180) as response:
            result = json.load(response)
        file_id = int(result['id'])
        print(f'Uploaded: https://authors.curseforge.com/#/projects/{PROJECT}/files/{file_id}')
    except urllib.error.HTTPError as error:
        # Never log headers or response bodies that might contain credentials.
        raise SystemExit(f'CurseForge returned HTTP {error.code}; check the file list before retrying') from None


if __name__ == '__main__':
    main()
