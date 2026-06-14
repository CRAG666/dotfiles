# Stdlib Decision Tree — "I Want to Do X"

Lookup table from intent to the right stdlib module. Use this before searching PyPI.

---

## Data Structures

| Intent | Use |
|---|---|
| Frequency counts | `collections.Counter` |
| Auto-init grouped dict | `collections.defaultdict(list)` / `defaultdict(set)` |
| O(1) double-ended queue | `collections.deque` |
| Bounded ring buffer | `collections.deque(maxlen=N)` |
| Layered config / fallback dict | `collections.ChainMap` |
| Immutable record with named fields | `collections.namedtuple` / `typing.NamedTuple` |
| Mutable record with methods/defaults | `@dataclasses.dataclass(slots=True)` |
| Read-only view of a dict | `types.MappingProxyType` |
| Attribute bag | `types.SimpleNamespace` |
| Enum / closed set of constants | `enum.Enum`, `IntEnum`, `StrEnum` (3.11+), `Flag` |
| Sorted list with binary search | `bisect.insort`, `bisect_left`, `bisect_right` |
| Priority queue / top-k | `heapq.heappush`, `nsmallest`, `nlargest` |
| Weak references / caches | `weakref.WeakValueDictionary`, `WeakSet` |

---

## Iteration / Functional

| Intent | Use |
|---|---|
| Flatten one level | `itertools.chain.from_iterable` |
| Concatenate iterables | `itertools.chain` |
| Sliding pairs / windows of 2 | `itertools.pairwise` (3.10+) |
| Chunk into fixed-size pieces | `itertools.batched` (3.12+) |
| Cartesian product | `itertools.product` |
| All combinations / permutations | `itertools.combinations`, `permutations` |
| Group consecutive equal keys | `itertools.groupby` (sort first!) |
| Take/drop while predicate | `itertools.takewhile`, `dropwhile` |
| Running sums / running max | `itertools.accumulate(..., func=)` |
| First N from infinite generator | `itertools.islice` |
| Repeat / cycle / count | `itertools.repeat`, `cycle`, `count` |
| Memoization | `functools.cache`, `lru_cache` |
| Lazy attribute | `functools.cached_property` |
| Type-dispatched function | `functools.singledispatch` |
| Method on class with type dispatch | `functools.singledispatchmethod` |
| Pre-bind arguments | `functools.partial` |
| Preserve metadata in decorator | `functools.wraps` |
| Comparison ordering from `__eq__` + one | `functools.total_ordering` |
| Sort/lookup by attribute | `operator.attrgetter` |
| Sort/lookup by dict key | `operator.itemgetter` |
| Map method call across items | `operator.methodcaller` |
| Reduce | `functools.reduce` (only when builtins don't fit) |

---

## I/O, OS, Subprocess

| Intent | Use |
|---|---|
| Filesystem paths | `pathlib.Path` |
| Walk a directory tree | `Path.walk()` (3.12+) or `Path.rglob("*")` |
| Temp file/dir | `tempfile.NamedTemporaryFile`, `TemporaryDirectory` |
| Copy/move/remove tree | `shutil.copy`, `move`, `rmtree`, `make_archive` |
| Find executable on PATH | `shutil.which` |
| Run a subprocess | `subprocess.run(..., check=True, text=True, capture_output=True)` |
| Process groups | `subprocess.Popen` + `os.setsid` (POSIX) |
| Env vars | `os.environ`, `os.environ.get`, `os.getenv` |
| Pipe / fd ops | `os` low-level (`os.pipe`, `os.dup2`) |

---

## Concurrency

| Intent | Use |
|---|---|
| Thread pool | `concurrent.futures.ThreadPoolExecutor` |
| Process pool | `concurrent.futures.ProcessPoolExecutor` |
| Async I/O | `asyncio.run`, `gather`, `TaskGroup` (3.11+) |
| Offload sync work from async | `asyncio.to_thread(func, ...)` |
| Locks, events, semaphores | `threading`, `asyncio.Lock`, `multiprocessing` |
| Cross-process queue | `multiprocessing.Queue`, `Manager` |
| Subinterpreters | `concurrent.interpreters` (3.14+) |

---

## Networking / Web

| Intent | Use |
|---|---|
| Parse / build URLs | `urllib.parse` (`urlparse`, `urlencode`, `quote`) |
| Simple HTTP requests | `urllib.request.urlopen` (for stdlib-only) or `httpx`/`requests` if allowed |
| HTTP server (toy/dev) | `http.server` |
| WSGI ref impl | `wsgiref` |
| Parse IPs / networks | `ipaddress.ip_address`, `ip_network` |
| Email parsing/building | `email.message.EmailMessage`, `email.policy.default` |
| MIME types | `mimetypes.guess_type` |

---

## Serialization / Parsing

| Intent | Use |
|---|---|
| JSON | `json` (with `default=` hook for custom types) |
| TOML (read) | `tomllib` (3.11+) |
| CSV | `csv.DictReader`, `DictWriter` |
| XML (safe) | `defusedxml` if available, else `xml.etree.ElementTree` with caution |
| HTML parsing | `html.parser.HTMLParser` (limited; consider `html5lib`/`lxml`) |
| Base64 / hex | `base64`, `binascii` |
| Binary pack/unpack | `struct.pack`, `unpack` |
| Pickle (trusted only) | `pickle` (never on untrusted input) |

---

## Math / Numbers / Stats

| Intent | Use |
|---|---|
| Mean / median / stdev | `statistics.mean`, `median`, `stdev`, `fmean` |
| Mode | `statistics.mode`, `multimode` |
| Linear regression | `statistics.linear_regression`, `correlation`, `covariance` |
| GCD / LCM | `math.gcd`, `math.lcm` |
| Product of iterable | `math.prod` |
| Combinations / permutations count | `math.comb`, `math.perm` |
| Floating-point comparison | `math.isclose(a, b, rel_tol=..., abs_tol=...)` |
| Hypotenuse | `math.hypot(*coords)` |
| Exact decimals (money) | `decimal.Decimal` with explicit context |
| Exact rationals | `fractions.Fraction` |
| Modular exponentiation | `pow(base, exp, mod)` (built-in) |

---

## Strings / Text

| Intent | Use |
|---|---|
| Remove prefix/suffix | `str.removeprefix`, `removesuffix` (3.9+) |
| Wrap / indent paragraphs | `textwrap.dedent`, `indent`, `fill`, `shorten` |
| Template substitution | `string.Template` (`$name` style; safe for user templates) |
| Unicode normalize / strip accents | `unicodedata.normalize`, `category` |
| Case-fold compare | `str.casefold()` (better than `lower` for I18n) |
| Pretty-print structure | `pprint.pp` |
| Tabular output | `csv`, or align manually with `f"{x:<10}"` |

---

## Time / Dates

| Intent | Use |
|---|---|
| Now (timezone-aware) | `datetime.datetime.now(timezone.utc)` |
| Time zones | `zoneinfo.ZoneInfo("Region/City")` (3.9+) |
| Monotonic timer | `time.perf_counter()` |
| Sleep | `time.sleep`, `asyncio.sleep` |
| Duration arithmetic | `datetime.timedelta` |
| Format / parse | `datetime.strftime` / `strptime` or `fromisoformat` |
| Calendar utilities | `calendar.Month`, `calendar.Day` (3.12+) |

---

## Security

| Intent | Use |
|---|---|
| Tokens / passwords | `secrets.token_urlsafe`, `token_bytes`, `choice` |
| Compare hashes / tokens | `hmac.compare_digest` (constant-time) |
| Password hashing | `hashlib.pbkdf2_hmac`, `scrypt`; for production prefer `argon2-cffi` if allowed |
| File digest | `hashlib.file_digest` (3.11+) |
| Random non-crypto | `random.Random` instance (not module-level state) |

---

## Debugging / Introspection

| Intent | Use |
|---|---|
| Signature / parameters | `inspect.signature`, `Parameter` |
| Source code of an object | `inspect.getsource` |
| Callable check | `callable(x)` |
| Backtrace | `traceback.print_exc`, `format_exception` |
| Profiling | `cProfile`, `pstats`, `tracemalloc` |
| Timing | `timeit.timeit`, `time.perf_counter` |
| AST | `ast.parse`, `ast.unparse` (3.9+), `ast.walk` |
| Garbage collection | `gc.collect`, `gc.get_objects` |

---

## Testing

| Intent | Use |
|---|---|
| Unit tests | `unittest` (stdlib) or `pytest` (third-party) |
| Mocks | `unittest.mock.patch`, `Mock`, `MagicMock` |
| Property-based | `hypothesis` (third-party) |
| Doctests | `doctest` |

---

## CLI / App

| Intent | Use |
|---|---|
| Argument parser | `argparse` |
| Read env / config | `os.environ`, `pathlib` + `tomllib` |
| Structured logging | `logging` (`getLogger(__name__)`, `dictConfig`) |
| Color / TTY detection | `os.isatty`, `sys.stdout.isatty()` |
| Signals | `signal.signal`, `signal.SIGINT` |
| Exit codes | `sys.exit(code)` |
