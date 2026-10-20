"""Export decks to ``.apkg`` files."""

import re

from anki.collection import (
    Collection,
    DeckIdLimit,
    ExportAnkiPackageOptions,
)
from beartype import beartype

from ki.types import File, NoFile

# Characters which are illegal in filenames on Windows (plus the caret, which
# is illegal on old Windows versions).
ILLEGAL_FILENAME_CHARS = r'[\\/?<>:*|"^]'


@beartype
def deckname_to_filename(deckname: str) -> str:
    """Replace characters which are illegal in filenames with underscores."""
    return re.sub(ILLEGAL_FILENAME_CHARS, "_", deckname)


@beartype
def export_deck_apkg(
    col: Collection,
    deck: str,
    out_path: File | NoFile,
    *,
    legacy: bool = True,
    media: bool = True,
) -> int:
    """
    Export a single deck to an ``.apkg`` file.

    Parameters
    ----------
    col
        Anki collection.
    deck
        Name of the deck to export, e.g. ``"parent::child"``.
    out_path
        Where to write the ``.apkg`` file. Should end in ``.apkg``.
    legacy
        Whether to write the legacy (v2) package layout, which is readable by
        Anki 2.1.50 and earlier, at the cost of a larger file. If `False`, the
        modern (v3) layout is written, which requires Anki 2.1.55 or later.
    media
        Whether to include the deck's media files in the package.

    Returns
    -------
    int
        The number of notes written to the package.
    """
    # NOTE: `create=False`, since `decks.id()` creates the deck by default,
    # which would silently export an empty package for a mistyped deck name.
    did = col.decks.id(deck, create=False)

    if did is None:
        raise ValueError(f"deck not found: {deck}")

    return col.export_anki_package(
        out_path=str(out_path),
        options=ExportAnkiPackageOptions(
            # NOTE: Scheduling information is not exported: a compiled deck is
            # distributed to users who have not studied these notes yet.
            with_scheduling=False,
            with_deck_configs=False,
            with_media=media,
            legacy=legacy,
        ),
        limit=DeckIdLimit(deck_id=did),
    )
