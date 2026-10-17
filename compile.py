#!/usr/bin/env python3

"""Compile a deck."""

import argparse
import os
import re

from anki.collection import (
    Collection,
    DeckIdLimit,
    ExportAnkiPackageOptions,
)
from beartype import beartype


@beartype
def main() -> None:
    """Compile a top-level deck into a ``.apkg`` binary."""
    parser = argparse.ArgumentParser()
    _ = parser.add_argument("--collection")
    _ = parser.add_argument("--deck")
    args: argparse.Namespace = parser.parse_args()

    col = Collection(args.collection)
    did = col.decks.id(args.deck)

    if did is None:
        raise ValueError(f"deck not found: {args.deck}")

    deckname = re.sub(r'[\\/?<>:*|"^]', "_", args.deck)
    filename = f"{deckname}.apkg"
    file = os.path.normpath(filename)

    _ = col.export_anki_package(
        out_path=file,
        options=ExportAnkiPackageOptions(
            with_scheduling=False,
            with_deck_configs=False,
            with_media=True,
            legacy=True,
        ),
        limit=DeckIdLimit(deck_id=did),
    )


if __name__ == "__main__":
    main()
