seq 1 2000 | parallel magma -b d:={} magma/signatures/computesignatures.m >/dev/null
