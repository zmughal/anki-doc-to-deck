#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# See example at <https://superuser.com/questions/698902/can-i-create-an-anki-deck-from-a-csv-file>

import os

ANKI_LIB = '/usr/share/anki'
ANKI_ADDONS_PATH = os.path.join(
  os.path.expanduser('~'),
  'Documents/Anki/addons')

import sys
import tempfile
import shutil
import argparse

sys.path.append(ANKI_LIB)
sys.path.append(ANKI_ADDONS_PATH)

import anki

from anki.exporting import AnkiPackageExporter
from anki.importing import TextImporter

from image_occlusion_enhanced.template import add_io_model
from image_occlusion_enhanced.config import IO_FLDS

CSV_IO_FLDS_IDS = ["id", "hd", "im", "qm",  "ft", "rk",
              "sc", "e1", "e2", "am", "om"]

def argparser():
  parser = argparse.ArgumentParser(description='Converts semicolon CSV to Anki APKG file')
  required = parser.add_argument_group('required arguments')
  required.add_argument('--csv-filename', help='CSV input file', required=True)
  required.add_argument('--deck-name', help='Name of Anki deck', required=True)
  required.add_argument('--apkg-filename', help='APKG filename', required=True)
  required.add_argument('--media-directory', help='Anki media directory', required=True)
  required.add_argument('--model-name', help='Model name', required=True)

  return parser


def main():
  parser = argparser();
  args = parser.parse_args()

  csv_filename = args.csv_filename
  deck_name = args.deck_name
  apkg_filename = args.apkg_filename
  media_directory = args.media_directory
  model_name = args.model_name

  # this is removed at the end of the program
  TMPDIR = tempfile.mkdtemp()

  collection = anki.Collection(os.path.join(TMPDIR, 'collection.anki2'))

  deck_id = collection.decks.id(deck_name)
  deck = collection.decks.get(deck_id)

  if model_name == 'Image Occlusion Enhanced':
    model = add_io_model(collection)
  else:
    model = collection.models.byName(model_name).copy()

  model['did'] = deck_id

  collection.models.update(model)
  collection.models.setCurrent(model)
  collection.models.save(model)

  importer = TextImporter(collection, csv_filename)
  importer.allowHTML = True
  importer.initMapping()
  importer.run()

  for media_file in os.listdir(media_directory):
    os.symlink(
        os.path.join(media_directory, media_file),
        os.path.join(TMPDIR, 'collection.media', media_file))

  export = AnkiPackageExporter(collection)
  export.exportInto(apkg_filename)

  shutil.rmtree(TMPDIR)

if __name__ == "__main__":
  main()
