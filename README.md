# imvenio-rdm

InvenioRDM is a turn-key research data management (RDM) repository platform based on the Invenio Framework and Zenodo. InvenioRDM is Open Source with an MIT license, more information on the [InvenioRDM product page](https://inveniosoftware.org/products/rdm/).

Under development.

## Installation
Using [Docker Compose](https://docs.docker.com/compose/):

```bash
docker compose up
```

Run this command from the root folder of the git repository and make sure [Docker](https://docs.docker.com/) is installed and running. Docker Compose uses the configuration in docker-compose.yml. The file contains sensible defaults for a development environment. If you want to customize the configuration, add a file (docker-compose.override.yml](https://docs.docker.com/compose/extends/) (make sure the file is not under git version control).

## License

**Invenio-RDM** is released under the [MIT License](https://github.com/front-matter/invenio-rdm/blob/main/LICENSE).