# ucam-lookup-byyear

This is a small script to fetch information about members of a college from the [University Lookup
Directory](https://help.uis.cam.ac.uk/service/collaboration/lookup).

Lookup's CSV export feature does not support sorting members by year of matriculation, which we needed
for the [Downing JCR Room Ballot](https://github.com/dowjcr/roomsurvey). This script solves that problem.

## Setup

Using `cpanminus`:

```
cpanm --installdeps .
```

## Example usage

```
$ ./ucam-lookup-byyear.pl > data.csv
Your email address: <you>@cam.ac.uk
Complete cookie field for lookup.cam.ac.uk: <enter cookies extracted from your web browser>
Institution (e.g. DOWNUG): <the institution code as it appears in the URL of the corresponding lookup page>
Year number to fetch (or 'done'): 1
Corresponding matriculation year: 2020
Year number to fetch (or 'done'): 2
Corresponding matriculation year: 2019
Year number to fetch (or 'done'): done
$ # After a few minutes, the data should be written to data.csv
```

The above example writes information about first- and second-year students to the `data.csv` file.

The cookie header can be extracted using your browser's development tools. For example, for Firefox, open
the `Network` tab, navigate to any page on the Lookup website, select the first request, right click and
choose `Copy as cURL`. Paste the output into your favourite text editor, and copy the text from the `Cookie` header (**not** including `Cookie: ` or the trailing quote).

## Output format

```
crsid,first name,last name,year
```

## Author

Lawrence Brown, JCR internet officer 2020/21

## License

This software is dedicated to the public domain. For more information, see the `LICENSE` file.
