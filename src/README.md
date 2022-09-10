# src
monero-bash source file structure:

| File/Folder      | Purpose                                       |
|------------------|-----------------------------------------------|
| `api/`           | internal file-based api used by [monero-bash] |
| `func/`          | all the functions [monero-bash] uses          |
| `txt/`           | text files to store long-term on disk         |
| `debug.sh`       | debugging functions                           |
| `libtorsocks.so` | builtin torsocks library                      |
| `source.sh`      | master source file that sources vars/funcs    |
| `var.sh`         | frequently used GLOBAL variables              |

# [monero-bash] order of operations
1. User inputs [monero-bash \<something\>]
2. [monero-bash] sources -> [source.sh]
3. [source.sh] sources -> functions, state, variables
4. `parse_Config()` parses user configs safely
5. A whole bunch of safety checks
6. Parse & execute user input (update, wallet, etc)
