# OpenPGP Tests

This repo serves to illustrate a bug, either in [SequoiaPGP](https://crates.io/crates/sequoia-sq), [rpgp](https://crates.io/crates/pgp), or in the scripts I created here.

The error concerns password-protected secret keys with the RFC 9580 / Version 6 profile.

I use SequoiaPGP inside a docker container to generate test certificates. When I generated a password-protected RFC9580 certificate, I could neither unlock it on my host (which uses SequoiaPGP) nor in the code of [BOMnipotent](https://www.bomnipotent.de), which uses rpgp. I *could* however unlock it with SequoiaPGP *inside* the docker container that created it.

During my experiments I uninstalled and reinstalled SequoiaPGP (both via apt and via cargo). Since then I *can* use the keys from host (with versions 1.3.0, 1.3.1 and 1-3-1-2+b1), which confuses me greatly. It still does not work with rpgp now.

This repo provides Dockerfiles that (at the time of writing) run version 1.3.1-2+b1 (the debian trixie apt version) and 1.3.1 (the cargo install). The results proved to be the same, but I wanted to make sure.

They V6 keys from the [OpenPGP interoperability test suite](https://sequoia-pgp.gitlab.io/openpgp-interoperability-test-suite/results.html#Encrypted_keys) that are supposed to work *do* work. So the usage of rpgp in this repo here is probably not completely wrong.

## How to break things

The easies way to see the problem is the script "just_the_problem.sh". It prompts you for a password, generates an encrypted key file, stores it in the output folder. It then uses rsop (which is based on rpgp) to try to sign an arbitrary message, prompting you for the password again. In all my experiments, this never worked.

To gather more data you can first run "generate_pgp_key.sh". You have to provide two arguments:
- "--image", which takes the values "apt" or "cargo" and defines which Docker image is run for the generation.
- "--version", which takes the values "4" or "6" and defines whether the generated key is according to Version 4 / RFC 4880, or Version 6 / RFC 9580.

You may also provide "--passphrase" and/or "--output", if you like.

Then run "test_pgp_key.sh" with the arguments "--input-file" and "--image" (here "host" is also allowed, if you have SequoiaPGP installed on your host system). After I had reinstalled SequoiaPGP on my host, this always worked for me.

Alternatively, run "test_with_rsop.sh" with the key file as a positional argument. For Version 4 keys, this works, for Version 6 keys, it does not.

The scripts "generate_combinations.sh" and "test_combinations.sh" are convenience wrappers to, well, generate and test several combinations.
