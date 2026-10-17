#!/usr/bin/env python3

"""Compile a deck."""

import argparse

from anki.collection import Collection
from beartype import beartype

from ki.exporting import deckname_to_filename, export_deck_apkg
from ki.types import NoFile


@beartype
def main() -> None:
    """Compile a top-level deck into a ``.apkg`` binary."""
    parser = argparse.ArgumentParser()
    _ = parser.add_argument("--collection")
    _ = parser.add_argument("--deck")
    args: argparse.Namespace = parser.parse_args()

    col = Collection(args.collection)
    deckname = deckname_to_filename(args.deck)
    out_path = NoFile(f"{deckname}.apkg")

    export_deck_apkg(col, args.deck, out_path)


if __name__ == "__main__":
    main()
