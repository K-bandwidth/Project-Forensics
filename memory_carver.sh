#!/bin/bash

# Ensure the script is run as root
if [ "$(whoami)" != "root" ]; then
    echo "Ф This script must be run as root."
    exit 1
fi

# Allow the user to specify the filename
filename=$1
if [ -z "$filename" ]; then
    echo "Ф Usage: $0 <filename>"
    exit 1
fi

# Check if the file exists
if [ ! -f "$filename" ]; then
    echo "Ф The file '$filename' does not exist."
    exit 1
fi

# Directory to store extracted files and report
output_dir=".output"
mkdir -p "$output_dir"
imageinfo_file="$output_dir/imageinfo.txt"

# Function to check and install a tool
check_and_install() {
    tool_name=$1
    package_name=$2

    if ! command -v $tool_name &> /dev/null; then
        echo "Ф $tool_name not found. Installing..."
        sudo apt-get update > /dev/null
        sudo apt-get install -y $package_name > /dev/null
    else
        echo "Ф $tool_name is already installed."
    fi
}

# Check and install necessary tools
check_and_install "file" "file"
check_and_install "binwalk" "binwalk"
check_and_install "bulk_extractor" "bulk-extractor"
check_and_install "foremost" "foremost"
check_and_install "strings" "binutils"
check_and_install "cabextract" "cabextract"
check_and_install "python3" "python3"
check_and_install "pip" "python3-pip"

# Ask the user if they have Volatility 3
read -p "Do you have Volatility 3 installed? (y/n): " has_volatility
has_volatility=$(echo "$has_volatility" | tr '[:upper:]' '[:lower:]')

if [ "$has_volatility" == "y" ]; then
    read -p "Please specify the folder where vol.py is located: " vol_folder
    vol_path="${vol_folder%/}/vol.py"
    if [ ! -f "$vol_path" ]; then
        echo "Ф The specified file does not exist. Exiting."
        exit 1
    fi
else
    echo "Ф Volatility 3 not found. Installing..."
    git clone https://github.com/volatilityfoundation/volatility3.git
    cd volatility3
    pip install -r requirements.txt
    cd ..
    vol_path="./volatility3/vol.py"
fi

echo "Ф Volatility path is set to: $vol_path"

# Start timing
start_time=$(date +%s)
start_time_readable=$(date)

# Run Volatility 3 windows.info and hide progress output
python3 "$vol_path" -f "$filename" windows.info > "$imageinfo_file" 2>/dev/null

# Function to identify the operating system
identify_os() {
    local file_path=$1
    if grep -q "Windows" "$file_path"; then
        major=$(grep -P 'PE MajorOperatingSystemVersion' "$file_path" | awk '{print $3}')
        minor=$(grep -P 'PE MinorOperatingSystemVersion' "$file_path" | awk '{print $3}')
        if [ "$major" == "5" ] && [ "$minor" == "1" ]; then
            os="Windows XP"
        elif [ "$major" == "10" ] && [ "$minor" == "0" ]; then
            os="Windows 10"
        elif [ "$major" == "6" ] && [ "$minor" == "3" ]; then
            os="Windows 8.1"
        elif [ "$major" == "6" ] && [ "$minor" == "2" ]; then
            os="Windows 8"
        elif [ "$major" == "6" ] && [ "$minor" == "1" ]; then
            os="Windows 7"
        elif [ "$major" == "6" ] && [ "$minor" == "0" ]; then
            os="Windows Vista"
        else
            os="Unknown Windows version"
        fi
    elif grep -q "Linux" "$file_path"; then
        os="Linux"
    elif grep -q "Darwin" "$file_path"; then
        os="Mac OS"
    else
        os="Unknown OS"
    fi
    echo "$os"
}

# Check if windows.info has useful information
if grep -q "Kernel Base" "$imageinfo_file"; then
    echo "Ф Memory info identified and extracted."
    os_info=$(identify_os "$imageinfo_file")
    echo "Operating System: $os_info"
else
    echo "Ф Could not identify the memory profile. Skipping Volatility analysis."
    os_info="Unknown"
fi

# Extract running processes and hide progress output
python3 "$vol_path" -f "$filename" windows.pslist > "$output_dir/pslist.txt" 2>/dev/null
echo "Ф Running processes extracted."

# Extract network connections if OS is supported and hide progress output
if [[ "$os_info" != "Windows XP" ]]; then
    python3 "$vol_path" -f "$filename" windows.netscan > "$output_dir/netscan.txt" 2>/dev/null
    echo "Ф Network connections extracted."
else
    echo "Ф Network connections not supported for $os_info."
fi

# Extract registry information and hide progress output
python3 "$vol_path" -f "$filename" windows.registry.hivelist > "$output_dir/hivelist.txt" 2>/dev/null
echo "Ф Registry information extracted."

# Proceed with other analysis tools
echo "Ф Data extraction using Bulk Extractor..."
bulk_extractor -o "$output_dir/bulk_extractor" "$filename" > /dev/null
echo "Ф Data extracted using Bulk Extractor."

# Check for packets.pcap and count packets
packets_pcap="$output_dir/bulk_extractor/packets.pcap"
packet_count=0
if [ -f "$packets_pcap" ]; then
    packet_count=$(tcpdump -r "$packets_pcap" 2>/dev/null | wc -l)
    echo "Ф Found $packet_count packets in packets.pcap."
fi

echo "Ф Data extraction using Foremost..."
foremost -i "$filename" -o "$output_dir/foremost" > /dev/null
echo "Ф Data extracted using Foremost."

echo "Ф Data extraction using Binwalk..."
binwalk -e --run-as=root -C "$output_dir/binwalk" "$filename" > /dev/null
echo "Ф Data extracted using Binwalk."

# Run strings and save the results
echo "Ф Extracting strings..."
strings "$filename" > "$output_dir/strings.lst"
strings_count=$(wc -l < "$output_dir/strings.lst")
echo "Ф Strings extraction completed. $strings_count strings found."

# Count files for each tool
bulk_extractor_file_count=$(find "$output_dir/bulk_extractor" -type f | wc -l)
foremost_file_count=$(find "$output_dir/foremost" -type f | wc -l)
binwalk_file_count=$(find "$output_dir/binwalk" -type f | wc -l)

# Count total files
file_count=$(find "$output_dir" -type f | wc -l)

# End timing
end_time=$(date +%s)
duration=$((end_time - start_time))

# Create report and display the info
{
    echo "Analysis started at: $start_time_readable"
    echo "Operating System: $os_info"
    echo "Filename: $filename"
    echo "Duration of analysis: $duration seconds"
    echo "Number of found files: $file_count"
    echo "Number of files found by Bulk Extractor: $bulk_extractor_file_count"
    echo "Number of packets in packets.pcap: $packet_count"
    echo "Number of files found by Foremost: $foremost_file_count"
    echo "Number of files found by Binwalk: $binwalk_file_count"
    echo "Foremost summary:"
    grep -A 10 "FILES EXTRACTED" "$output_dir/foremost/audit.txt"
    echo "$strings_count strings found in the image."
} > "$output_dir/report.txt"

echo "Ф Analysis completed."
echo "Ф Duration: $duration seconds"
echo "Ф Files found: $file_count"
echo "Number of files found by Bulk Extractor: $bulk_extractor_file_count"
echo "Number of packets in packets.pcap: $packet_count"
echo "Number of files found by Foremost: $foremost_file_count"
echo "Number of files found by Binwalk: $binwalk_file_count"

# Zip everything with a progress bar
zip_name="analysis_archive_${filename##*/}.zip"
echo "Ф Archiving data to $zip_name..."
zip -r -q "$zip_name" "$output_dir" | pv -p -t -e -b > /dev/null
rm -r "$output_dir"

echo "Ф Data archived in $zip_name"
