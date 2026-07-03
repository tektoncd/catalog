import os
import yaml as y
from ruamel.yaml import YAML
import json
import sys
import argparse

# Parent Directory path
parent_dir = os.path.normpath(
    os.path.join(os.path.dirname(
        os.path.abspath(__file__)), '..'))

TEP_TEMPLATE = os.path.normpath(
    os.path.join(os.path.dirname(
        os.path.abspath(__file__)), 'tep-template.md.template'))

print(TEP_TEMPLATE)
# Type of Resource
task = {'task', 't', 'Task'}
pipeline = {'pipeline', 'p', 'Pipeline'}

# Basic Template of Manifest according to TEP
template = "template.yaml"

yaml = YAML()
with open(template) as fpi:
    data = yaml.load(fpi)

jsondata = json.dumps(data, indent=2)
json_object = json.loads(jsondata)


def createResourceTemplate(name: str, version: str, finalPath: str, file: str):
    if not os.path.exists(finalPath):
        os.makedirs(finalPath)
        print("\n" + "Directory 📁 '% s' created" % name + "\n")

        minPipelineVersion = input("Enter min pipeline version: ")
        tags = input("Enter tags related to task: ")
        displayName = input("Enter displayName of task: ")

        metadata = json_object["metadata"]

        metadata["name"] = name
        metadata["labels"]["app.kubernetes.io/version"] = version
        metadata["annotations"]["tekton.dev/tags"] = tags
        metadata["annotations"]["tekton.dev/pipelines.minVersion"] = minPipelineVersion
        metadata["annotations"]["tekton.dev/displayName"] = displayName

        # Creating a file at specified location
        with open(os.path.join(finalPath, file), 'w') as yaml_file:
            y.dump(json_object, yaml_file, default_flow_style=False)
    else:
        print(
            f"Resource with name `{name}` and version `{version}` already exists")
        sys.exit(1)


def kind(args):
    # Parent Directory path
    parent_dir = os.path.normpath(
        os.path.join(os.path.dirname(
            os.path.abspath(__file__)), '..'))

    resourcetype = args.kind[0]
    if resourcetype in task:
        parent_dir = parent_dir + "/task/"
        return resourcetype, parent_dir
    elif resourcetype in pipeline:
        parent_dir = parent_dir + "/pipeline/"
        return resourcetype, parent_dir
    else:
        sys.stdout.write("Please respond with 'task' or 'pipeline'")
        sys.exit(1)


def resName(args):
    return args.name[0]


def ver(args):
    return args.version[0]


def readmeTemplate(tep, tep_io):
    header = {
        'title': tep['title'],
    }
    tep_io.write(f'# {header["title"].capitalize()}\n\n')


def main():

    resourcetype = ""
    name = ""
    version = ""

    parser = argparse.ArgumentParser(description="Resource Template Tool!")

    parser.add_argument("-k", "--kind", type=str, nargs=1,
                        metavar=('type'),
                        help="Type of the resource.")

    parser.add_argument("-n", "--name", type=str, nargs=1,
                        metavar=('resourceName'),
                        help="Name of the resource.")

    parser.add_argument("-v", "--version", type=str, nargs=1,
                        metavar=('version'),
                        help="Version of the resource.")

    args = parser.parse_args()

    if args.kind != None:
        resourcetype, parent_dir = kind(args)
    if args.name != None:
        name = resName(args)
    if args.version != None:
        version = ver(args)

    if resourcetype == "":
        sys.stdout.write("Please enter the type of resource")
        sys.exit(1)

    if name == "":
        sys.stdout.write("Please enter the name of resource")
        sys.exit(1)

    if version == "":
        sys.stdout.write("Please enter the version of resource")
        sys.exit(1)

    # Path
    path = os.path.join(parent_dir, name.lower())

    finalPath = os.path.join(path, version)

    # Speicfy the file name
    file = name + ".yaml"

    createResourceTemplate(name, version, finalPath, file)

    resource = dict(title=name)

    with open(os.path.join(finalPath, "README.md"), 'w+') as new_resource:
        readmeTemplate(resource, new_resource)
        with open(TEP_TEMPLATE, 'r') as template:
            new_resource.write(template.read())


if __name__ == '__main__':
    main()
