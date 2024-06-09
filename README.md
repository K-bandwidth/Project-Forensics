# Project-Forensics
A shell script whose goal is to automate HDD and Memory Analysis. This is accomplished by utilising various forensic tools and automating the extraction and analysis of data from memory dumps

[![Video Demonstration](https://img.youtube.com/vi/J1oS8VQSrmg/0.jpg)](https://youtu.be/J1oS8VQSrmg)

Click the image above to watch the video demonstration.

## Requirements
A Linux system with internet connectivity (Kali Linux preferred)

Volatility 3 (or the script will install it automatically if not found)

The following tools will be installed if missing:
- file
- binwalk
- bulk_extractor
- foremost
- strings
- cabextract
- python3
- pip

## Using the Code
1. Save the `memory_carver.sh` script in a directory of your choice.
2. Make the script executable:
    ```bash
    chmod +x memory_carver.sh
    ```
3. Run the script by specifying the path to your memory dump file:
    ```bash
    sudo ./memory_carver.sh /path/to/your/memory_dump.raw
    ```
4. Start your Kali machine and move `memory_carver.sh` into a folder you wish to use it from, along with your file.
5. Open a terminal window and run the code by executing (the script requires root privilege to run properly):
    ```bash
    sudo ./memory_carver.sh <filename>
    ```
*must be executed as root*

The code will create an output folder to store the results of the analysis, the folder is hidden as a default. See the “Troubleshooting” section to modify its behavior.

The script will check if the necessary tools are installed and prompt you to install missing ones, including a check to see if you have a preferred version of Volatility to carve with. The script uses Python to run Volatility 3 as a default (see resources for more information).

*Note: input is not case sensitive*

If Volatility is not on the system, it will download it into the folder the script is run in.

If Volatility is installed and specified, the script will proceed with the RAM or HDD analysis:
- RAM analysis
- HDD analysis

## Output Files
A `.zip` archive will be created, containing the carved files, along with scan reports and an overall summary of the file. 

- `strings.lst` - contains the strings captured in the file.
- `report.txt` - summary of the memory content and info, such as timestamps and number of files captured.
- `pslist.txt` - results of the running processes scan.
- `netscan.txt` - results of the Network connections scan.
- `imageinfo.txt` - results of the memory profile, if applicable.
- `hivelist.txt` - results of the registry information scan.
- The folders contain the findings of each carver.

## Troubleshoot
The code has built-in checks to ensure all necessary tools are installed and will prompt you to install missing ones. However, issues may still arise, and some common problems are addressed here:

- **No suitable address space mapping found**: Ensure the file you are analyzing is a valid memory dump.
- **Volatility Not Found**: If the script cannot find Volatility 3, ensure it is installed in the specified path or let the script install it.
- **Missing Dependencies**: The script checks for and installs necessary tools like binwalk, foremost, strings, cabextract, python3, and pip. Ensure your system can install packages from the internet.
- **Large Memory Dump Files**: Processing large memory dump files might require substantial disk space and time; not all carvers display progress. Be patient.
- **Tool installation errors**: Verify your internet connection and ensure your system has the correct repositories configured.

## Tool Sources
**IMPORTANT**: Ensure to download tools from trusted sources.

- [Kali Linux](https://www.kali.org)
- [Volatility](https://www.volatilityfoundation.org)
- [Bulk Extractor](https://github.com/simsong/bulk_extractor)
- [Foremost](https://foremost.sourceforge.net)
- [Binwalk](https://github.com/ReFirmLabs/binwalk)
- [Strings](https://linux.die.net/man/1/strings)
- [PV](https://linux.die.net/man/1/pv)
- [Cabextract](https://www.cabextract.org.uk)
