# Update

## Update process

GUI periodically checks github releases to find out, if new version was released. It starts form the latest release and iteratively checks for for file `versions.txt` inside each release.

<details><summary>versions.txt format</summary>

```JSON
{
    "version": "0.19.0",
    "osx": {
        "minVersion": "0.17.0"
    },
    "wind": {
        "minVersion": "0.17.0"
    },
    "ubuntu":
    {
        "minVersion": "0.17.0"
    }
}
```

</details>

- It compares `target` from `settings.json` file to OS tag found in `versions.txt` to decide, if OS is affected in that release.
- If it is affected it compares `release` from `settings.json` file to `minVersion` in `versions.txt` to decide, if current version can be updated to that `minVersion` required by new release.
- If user chooses to dismiss update, we store in DB dismissed version and do not notify about update till newer version is released.
- If user chooses to update he is redirected to new github release page.

:point_up: Notes:

- `target` is defined during the release delivery
- `target` is just a string to compare, thus can be used to describe OS platform plus particular version in single tag. (e.g. "ubuntu18")

<details><summary>settings.json update related fields</summary>

```JSON
"releasesEndpoint": "https://api.github.com/repos/Privatix/privatix/releases",
"platformsEndpoint": "https://github.com/Privatix/privatix/releases/download/${version}/versions.txt",
"updateCheckFreq": 480,
"release": "0.7.0",
"target":"osx"
```

</details>
