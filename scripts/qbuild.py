#!/usr/bin/env python3
import os, subprocess, argparse

parser = argparse.ArgumentParser()
parser.add_argument("package")
parser.add_argument("--use", default="", help="Space-separated USE flags")
parser.add_argument("--archs", default="", help="Space-separated target architectures")
args = parser.parse_args()

package = args.package
use_flags = args.use
archs = args.archs.split() if args.archs else [os.uname().machine]

for arch in archs:
    print(f"Building {package} for {arch} with USE='{use_flags}'")
    env = os.environ.copy()
    env["USE"] = use_flags
    env["CFLAGS"] = f"-march={arch}"
    env["CXXFLAGS"] = f"-march={arch}"

    # emerge or qbuild
    if subprocess.call(["which", "emerge"], stdout=subprocess.DEVNULL) == 0:
        subprocess.run(["emerge", "--verbose", package], env=env)
    elif subprocess.call(["which", "qbuild"], stdout=subprocess.DEVNULL) == 0:
        subprocess.run(["qbuild", package], env=env)
    else:
        print("No build system found")
        exit(1)
