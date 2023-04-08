import asyncio
import hashlib
import re

import aiohttp
# import requests
from catapult.api import (Plugin, SearchResult, copy_text_to_clipboard,
                          lookup_icon)
from catapult.i18n import _

cache = {}

PATTERN = r"^tr\s([a-z]{2})\s([a-z]{2})\s(.*)\s"


class TranslatorPlugin(Plugin):
    save_history = False
    title = _("Translator")
    cache_key = ""

    def __init__(self):
        super().__init__()

    def launch(self, window, id):
        copy_text_to_clipboard(cache.get(self.cache_key, ""))

    async def google_translate(self, text, source_language, target_language):
        self.cache_key = hashlib.md5(
            f"{text}{source_language}{target_language}".encode()
        ).hexdigest()
        if self.cache_key in cache:
            return cache[self.cache_key]

        url = "https://translate.googleapis.com/translate_a/single"
        params = {
            "client": "gtx",
            "sl": source_language,
            "tl": target_language,
            "dt": "t",
            "q": text,
        }
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"
        }
        async with aiohttp.ClientSession(headers=headers) as session:
            async with session.get(url, params=params, timeout=3) as response:
                result = (await response.json())[0][0][0]
                cache[self.cache_key] = result
        return result

    def search(self, query):
        match = re.match(PATTERN, query)
        if not match:
            return

        src, dest, text = match.groups()
        result = asyncio.run(self.google_translate(text, src, dest))
        if result:
            yield SearchResult(
                description=result,
                fuzzy=False,
                icon=lookup_icon(
                    "gnome-translate",
                    "deepin-translator",
                    "org.gnome.Translate",
                    "org.gnome.Translate",
                    "application-x-executable",
                ),
                id="0",
                offset=0,
                plugin=self,
                score=1,
                title="Traduccion",
            )

    # def google_translate(self, text, source_language, target_language):
    #     cache_key = hashlib.md5(
    #         f"{text}{source_language}{target_language}".encode()
    #     ).hexdigest()
    #     if cache_key in cache:
    #         return cache[cache_key]
    #
    #     url = "https://translate.googleapis.com/translate_a/single"
    #     params = {
    #         "client": "gtx",
    #         "sl": source_language,
    #         "tl": target_language,
    #         "dt": "t",
    #         "q": text,
    #     }
    #     headers = {
    #         "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"
    #     }
    #     try:
    #         response = requests.get(
    #             url, params=params, headers=headers, timeout=3
    #         ).json()
    #         result = response[0][0][0]
    #         cache[cache_key] = result
    #     except:
    #         result = None
    #     return result
    #
    # def search(self, query):
    #     match = re.match(PATTERN, query)
    #     if not match:
    #         return
    #
    #     src, dest, text = match.groups()
    #     result = self.google_translate(text, src, dest)
    #
    #     if result:
    #         yield SearchResult(
    #             description=result,
    #             fuzzy=False,
    #             icon=lookup_icon(
    #                 "gnome-translate",
    #                 "deepin-translator",
    #                 "org.gnome.Translate",
    #                 "org.gnome.Translate",
    #                 "application-x-executable",
    #             ),
    #             id=result,
    #             offset=0,
    #             plugin=self,
    #             score=1,
    #             title="Traduccion",
    #         )

    # def google_translate(self, text, source_language, target_language):
    #     base_url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl={0}&tl={1}&dt=t&q={2}"
    #     url = base_url.format(
    #         source_language, target_language, urllib.parse.quote(text)
    #     )
    #     headers = {
    #         "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"
    #     }
    #     req = urllib.request.Request(url, headers=headers)
    #     response = urllib.request.urlopen(req).read().decode("utf-8")
    #     result = json.loads(response)[0][0][0]
    #     return result
    #
    # def search(self, query):
    #     match = re.match(PATTERN, query)
    #     if not match:
    #         return
    #
    #     src, dest, text = match.groups()
    #     result = self.google_translate(text, src, dest)
    #
    #     if result:
    #         yield SearchResult(
    #             description=result,
    #             fuzzy=False,
    #             icon=lookup_icon(
    #                 "gnome-translate",
    #                 "deepin-translator",
    #                 "org.gnome.Translate",
    #                 "org.gnome.Translate",
    #                 "application-x-executable",
    #             ),
    #             id=result,
    #             offset=0,
    #             plugin=self,
    #             score=1,
    #             title="Traduccion",
    #         )
