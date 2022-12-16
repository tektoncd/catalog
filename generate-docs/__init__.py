from typing import Optional
from argparse import ArgumentParser
from os import listdir

from yaml import load, Loader
from jinja2 import Environment, PackageLoader, select_autoescape


def get_args():
    parser = ArgumentParser(
        description="Generate documentation (README.md) for the resource you specify."
    )
    parser.add_argument("kind", choices=["task", "pipeline"], help="resource kind")
    parser.add_argument("name", help="resource name")
    parser.add_argument(
        "-v",
        "--version",
        help="version of the resource you want to generate docs for, defaults to latest available",
    )
    parser.add_argument(
        "-w",
        "--write",
        action="store_true",
        help="overwrite the README file, instead of printing to stdout",
    )
    return parser.parse_args()


def guess_version(path: str) -> str:
    versions = listdir(path)
    return max(versions)


def guess_dir(kind: str, name: str, version: Optional[str]) -> str:
    if not version:
        version = guess_version(f"{kind}/{name}")
    return f"{kind}/{name}/{version}"


def get_resource(path: str):
    with open(path) as f:
        return load(f, Loader)


def main():
    env = Environment(loader=PackageLoader(__name__), autoescape=select_autoescape())
    args = get_args()
    dir_path = guess_dir(args.kind, args.name, args.version)
    resource = get_resource(f"{dir_path}/{args.name}.yaml")
    template = env.get_template("README.md")
    out = template.render(resource=resource)
    if args.write:
        with open(f"{dir_path}/README.md", "w") as f:
            f.write(out)
    else:
        print(out)
