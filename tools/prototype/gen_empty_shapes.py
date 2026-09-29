#!/usr/bin/env python3
"""Generates lib/prototype/fixtures/empty_shapes.g.dart from the swagger spec.

An endpoint with no fixture still has to answer in the *shape* its generated
converter expects, otherwise a missing fixture surfaces as an unrelated cast
error (and, inside a dialog, an endless spinner). This walks the spec's GET
responses and records whether each path returns a bare array, a `{data: []}`
wrapper, or a plain object.

Run from the repo root:  python3 tools/prototype/gen_empty_shapes.py
"""

import pathlib
import re

SPEC = pathlib.Path('swaggers/gruene-api.yaml')
OUT = pathlib.Path('lib/prototype/fixtures/empty_shapes.g.dart')


def indent(line: str) -> int:
    return len(line) - len(line.lstrip(' '))


def parse():
    lines = SPEC.read_text().splitlines()

    # --- component schemas: which ones wrap their payload in `data: [...]` ---
    wrappers: set[str] = set()
    objects: set[str] = set()
    current = None
    in_props = False
    for i, line in enumerate(lines):
        if indent(line) == 4 and line.rstrip().endswith(':') and re.match(r'^    [A-Za-z0-9_]+:$', line):
            current = line.strip().rstrip(':')
            objects.add(current)
            in_props = False
        elif current and indent(line) == 6 and line.strip() == 'properties:':
            in_props = True
        elif current and in_props and indent(line) == 8 and line.strip() == 'data:':
            # `data:` whose immediate child is `type: array`
            for nxt in lines[i + 1:i + 3]:
                if nxt.strip() == 'type: array':
                    wrappers.add(current)
                    break
        elif indent(line) <= 4 and line.strip() and not line.startswith('    '):
            current = None
            in_props = False

    # --- GET responses per path ---
    shapes: dict[str, str] = {}
    path = None
    method = None
    in_200 = False
    in_schema = False
    for line in lines:
        stripped = line.strip()
        if indent(line) == 2 and stripped.startswith('/') and stripped.endswith(':'):
            path = stripped.rstrip(':')
            method = None
        elif path and indent(line) == 4 and stripped.rstrip(':') in ('get', 'post', 'put', 'patch', 'delete'):
            method = stripped.rstrip(':')
            in_200 = in_schema = False
        elif method == 'get' and indent(line) == 8 and stripped in ("'200':", '200:'):
            in_200 = True
        elif method == 'get' and indent(line) == 8 and stripped.endswith(':'):
            in_200 = False
        elif in_200 and stripped == 'schema:':
            in_schema = True
        elif in_schema and stripped == 'type: array':
            shapes[path] = 'array'
            in_schema = in_200 = False
        elif in_schema and stripped.startswith('$ref:'):
            name = stripped.split('/')[-1].strip().strip("'\"")
            shapes[path] = 'wrapper' if name in wrappers else 'object'
            in_schema = in_200 = False

    return shapes


def main():
    shapes = parse()
    rows = '\n'.join(f"  '{p}': EmptyShape.{s}," for p, s in sorted(shapes.items()))

    OUT.write_text(f'''// GENERATED — do not edit by hand.
// Regenerate: python3 tools/prototype/gen_empty_shapes.py

/// The shape an endpoint answers in, so an unfixtured endpoint can return an
/// empty response the generated converters still accept.
enum EmptyShape {{
  /// A bare JSON array.
  array,

  /// An object wrapping its payload in `data`.
  wrapper,

  /// A plain object.
  object,
}}

/// GET paths from `swaggers/gruene-api.yaml`, with `{{param}}` placeholders intact.
const emptyShapes = <String, EmptyShape>{{
{rows}
}};
''')
    counts = {s: sum(1 for v in shapes.values() if v == s) for s in ('array', 'wrapper', 'object')}
    print(f'{len(shapes)} GET paths -> {OUT}')
    print(f'  array={counts["array"]} wrapper={counts["wrapper"]} object={counts["object"]}')


if __name__ == '__main__':
    main()
