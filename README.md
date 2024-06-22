# Project-Forensics
In this project I'd like to present to you my take on a shell script whose goal is to automate HDD and Memory Analysis. This is accomplished by utilising various forensic tools and automating the extraction and analysis of data from memory dumps. it uses different carvers and has some redundancy, to help capture info that might be missed by another tool.

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


### Script Workflow
1. **User Input:**
   - The script ensures it is run as root.
   - The script prompts the user to specify the filename of the memory dump.

2. **System Preparation:**
   - The script checks if the specified file exists.
   - Creates an output directory `.output` to store extracted files and reports.
   - Installs necessary tools (`file`, `binwalk`, `bulk_extractor`, `foremost`, `strings`, `cabextract`, `python3`, `pip`) if they are not already installed.

3. **Volatility Setup:**
   - Prompts the user to specify if they have Volatility 3 installed.
   - If Volatility 3 is not installed, it clones the Volatility 3 repository and installs it.

4. **Analysis:**
   - **Volatility Analysis:**
     - Runs `windows.info` to gather basic memory information.
     - Identifies the operating system from the memory image.
     - Extracts running processes using `windows.pslist`.
     - Extracts network connections using `windows.netscan` (if supported by the OS).
     - Extracts registry information using `windows.registry.hivelist`.
   - **Bulk Extractor Analysis:**
     - Runs Bulk Extractor to extract data.
     - Checks for packets in `packets.pcap` and counts them.
   - **Foremost Analysis:**
     - Runs Foremost to extract data.
   - **Binwalk Analysis:**
     - Runs Binwalk to extract data.
   - **Strings Extraction:**
     - Extracts strings from the memory dump.

5. **Reporting:**
   - Counts the number of files found by each tool.
   - Creates a summary report with analysis details.
   - Archives the output directory into a zip file.


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
