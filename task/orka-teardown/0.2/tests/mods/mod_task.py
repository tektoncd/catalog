import os, sys, yaml

def str_presenter(dumper, data):
  scalar_style = "|" if len(data.splitlines()) > 1 else None
  return dumper.represent_scalar('tag:yaml.org,2002:str', data, style=scalar_style)

yaml.add_representer(str, str_presenter)

if __name__ == "__main__":
    # Load YAML files
    with open(os.path.join(sys.path[0], "..", "mocks", "orka.yaml"), "r", encoding="utf-8") as f:
        mocks = f.read()

    with open(sys.argv[1], "r", encoding="utf-8") as f:
        data = yaml.load(f.read(), Loader=yaml.FullLoader)

    go_rest_api = [
        {
            "name": "go-rest-api",
            "image": "quay.io/chmouel/go-rest-api-test",
            "env": [
                {
                    "name": "CONFIG",
                    "value": mocks
                }
            ]
        }
    ]

    # Modify Task YAML
    data["spec"]["sidecars"] = go_rest_api

    # Dump YAML
    print(yaml.dump(data, default_flow_style=False))
