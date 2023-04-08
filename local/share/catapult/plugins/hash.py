import hashlib

from catapult.api import (Plugin, SearchResult, copy_text_to_clipboard,
                          lookup_icon)
from catapult.i18n import _

hash_methods = {
    "blake2b": hashlib.blake2b(),
    "blake2s": hashlib.blake2s(),
    "md5": hashlib.md5(),
    "sha1": hashlib.sha1(),
    "sha224": hashlib.sha224(),
    "sha256": hashlib.sha256(),
    "sha384": hashlib.sha384(),
    "sha3224": hashlib.sha3_224(),
    "sha3256": hashlib.sha3_256(),
    "sha3384": hashlib.sha3_384(),
    "sha3512": hashlib.sha3_512(),
    "sha512": hashlib.sha512(),
    "shake128": hashlib.shake_128(),
    "shake256": hashlib.shake_256(),
}


class HashPlugin(Plugin):
    save_history = False
    title = _("Hash")

    def __init__(self):
        super().__init__()

    def launch(self, window, id):
        copy_text_to_clipboard(id)

    def search(self, query):
        hash_method, text = query.split(maxsplit=1)
        if hash_method in hash_methods:
            h = hash_methods[hash_method]
            h.update(text.encode())
            if "shake" in hash_method:
                result = h.hexdigest(32)
            else:
                result = h.hexdigest()
            yield SearchResult(
                description=f"{hash_method} of {text}",
                fuzzy=False,
                icon=lookup_icon(
                    "password-manager", "preferences-desktop-user-password"
                ),
                id=result,
                offset=0,
                plugin=self,
                score=1,
                title=result,
            )
