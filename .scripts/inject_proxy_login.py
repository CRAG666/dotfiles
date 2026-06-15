#!/usr/bin/env python3
"""Inject (or update) a proxy auth credential into a Zen/Firefox profile.

The credential is stored the same way the browser stores it: an *auth* login
(httpRealm set, formSubmitURL null) inside logins.json, with username and
password encrypted using the profile's own key4.db via NSS. Because it encrypts
with the local key4.db, the result is valid on any machine/profile -- no copying
of key4.db between machines, and no need for the "save password?" dialog.

Usage:
    PROXY_PASSWORD=secret \\
        inject_proxy_login.py <profile_dir> <host> <port> <user> <realm>

The password is read from the PROXY_PASSWORD environment variable so it never
appears in the process list (argv). The browser must be closed.
"""
import base64
import ctypes as ct
import ctypes.util
import json
import os
import sys
import time
import uuid


class SECItem(ct.Structure):
    _fields_ = [("type", ct.c_uint),
                ("data", ct.POINTER(ct.c_ubyte)),
                ("len", ct.c_uint)]


def load_nss():
    for cand in (ctypes.util.find_library("nss3"),
                 "libnss3.so",
                 "/usr/lib/libnss3.so",
                 "/usr/lib64/libnss3.so",
                 "/usr/lib/x86_64-linux-gnu/libnss3.so"):
        if not cand:
            continue
        try:
            return ct.CDLL(cand)
        except OSError:
            continue
    sys.exit("ERROR: no se encontro libnss3 (instala nss).")


def main():
    if len(sys.argv) != 6:
        sys.exit(__doc__)
    profile, host, port, user, realm = sys.argv[1:6]
    password = os.environ.get("PROXY_PASSWORD")
    if not password:
        sys.exit("ERROR: PROXY_PASSWORD no esta definida (nada que inyectar).")

    nss = load_nss()
    # Read-write init is required: SDR encryption needs to access the private key
    # store, which a read-only NSS_Init refuses (fails with SEC error 66).
    nss.NSS_InitReadWrite.argtypes = [ct.c_char_p]
    nss.NSS_InitReadWrite.restype = ct.c_int
    nss.NSS_Shutdown.restype = ct.c_int
    nss.PK11_GetInternalKeySlot.restype = ct.c_void_p
    nss.PK11_FreeSlot.argtypes = [ct.c_void_p]
    nss.PK11_CheckUserPassword.argtypes = [ct.c_void_p, ct.c_char_p]
    nss.PK11_CheckUserPassword.restype = ct.c_int
    nss.PK11SDR_Encrypt.argtypes = [ct.POINTER(SECItem), ct.POINTER(SECItem),
                                    ct.POINTER(SECItem), ct.c_void_p]
    nss.PK11SDR_Encrypt.restype = ct.c_int
    nss.SECITEM_ZfreeItem.argtypes = [ct.POINTER(SECItem), ct.c_int]

    if nss.NSS_InitReadWrite(b"sql:" + profile.encode()) != 0:
        sys.exit("ERROR: NSS_InitReadWrite fallo "
                 "(perfil invalido o navegador abierto).")

    slot = nss.PK11_GetInternalKeySlot()
    # Empty primary password is the common case; if a primary password is set,
    # provide it via PROXY_PRIMARY_PASSWORD.
    primary = os.environ.get("PROXY_PRIMARY_PASSWORD", "").encode()
    if nss.PK11_CheckUserPassword(slot, primary) != 0:
        sys.exit("ERROR: no se pudo autenticar el almacen de claves "
                 "(hay contrasena primaria? usa PROXY_PRIMARY_PASSWORD).")

    keyid = SECItem(0, None, 0)

    def encrypt(text):
        data = text.encode("utf-8")
        buf = (ct.c_ubyte * len(data)).from_buffer_copy(data)
        inp = SECItem(0, ct.cast(buf, ct.POINTER(ct.c_ubyte)), len(data))
        out = SECItem(0, None, 0)
        if nss.PK11SDR_Encrypt(ct.byref(keyid), ct.byref(inp),
                               ct.byref(out), None) != 0:
            sys.exit("ERROR: PK11SDR_Encrypt fallo.")
        raw = ct.string_at(out.data, out.len)
        nss.SECITEM_ZfreeItem(ct.byref(out), 0)
        return base64.b64encode(raw).decode("ascii")

    enc_user = encrypt(user)
    enc_pass = encrypt(password)
    nss.PK11_FreeSlot(slot)
    nss.NSS_Shutdown()

    hostname = "moz-proxy://%s:%s" % (host, port)
    path = os.path.join(profile, "logins.json")
    if os.path.exists(path):
        with open(path) as fh:
            db = json.load(fh)
    else:
        db = {"nextId": 1, "logins": [], "potentiallyVulnerablePasswords": [],
              "dismissedBreachAlertsByLoginGUID": {}, "version": 3}

    # Drop any previous entry for this proxy realm so we never duplicate.
    db["logins"] = [l for l in db.get("logins", [])
                    if not (l.get("hostname") == hostname
                            and l.get("httpRealm") == realm)]

    now = int(time.time() * 1000)
    new_id = max([l.get("id", 0) for l in db["logins"]], default=0) + 1
    db["logins"].append({
        "id": new_id,
        "hostname": hostname,
        "httpRealm": realm,
        "formSubmitURL": None,
        "usernameField": "",
        "passwordField": "",
        "encryptedUsername": enc_user,
        "encryptedPassword": enc_pass,
        "guid": "{%s}" % uuid.uuid4(),
        "encType": 1,
        "timeCreated": now,
        "timeLastUsed": now,
        "timePasswordChanged": now,
        "timesUsed": 1,
        "syncCounter": 0,
        "everSynced": False,
        "encryptedUnknownFields": None,
    })
    db["nextId"] = max(db.get("nextId", 1), new_id + 1)
    db.setdefault("version", 3)

    blob = json.dumps(db)
    for target in (path, os.path.join(profile, "logins-backup.json")):
        tmp = target + ".tmp"
        with open(tmp, "w") as fh:
            fh.write(blob)
        os.replace(tmp, target)
        os.chmod(target, 0o600)

    print("    Credencial de proxy inyectada: %s@%s (realm: %s)"
          % (user, hostname, realm))


if __name__ == "__main__":
    main()
