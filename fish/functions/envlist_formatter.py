import sys
import re

def print_file_content(filepath, lines):
    if not filepath:
        return
    
    # Process lines
    max_lhs_len = 0
    parsed = []
    
    for line in lines:
        stripped = line.strip()
        if not stripped:
            parsed.append(("empty", ""))
        elif stripped.startswith("#"):
            parsed.append(("comment", line))
        elif "=" in stripped:
            parts = stripped.split("=", 1)
            key = parts[0].strip()
            val = parts[1].strip()
            prefix = ""
            if key.startswith("export "):
                prefix = "export "
                key = key[7:].strip()
            
            lhs_len = len(prefix) + len(key)
            max_lhs_len = max(max_lhs_len, lhs_len)
            parsed.append(("kv", prefix, key, val))
        else:
            parsed.append(("raw", line))
            
    # Print header
    # Bold cyan for folder icon + filepath
    print(f"\033[1;36m📂 {filepath}\033[0m")
    # An elegant dashed line in grey
    print("\033[90m" + "─" * 60 + "\033[0m")
    
    # Print body
    for item in parsed:
        if item[0] == "empty":
            print()
        elif item[0] == "comment":
            # Dimmed grey for comments
            print(f"  \033[90m{item[1]}\033[0m")
        elif item[0] == "kv":
            prefix, key, val = item[1], item[2], item[3]
            # Cyan/Magenta for prefix if it exists
            pref_color = f"\033[35m{prefix}\033[0m" if prefix else ""
            # Align the key based on prefix length
            pad_len = max_lhs_len - len(prefix)
            key_color = f"\033[1;32m{key:<{pad_len}}\033[0m"
            # Green for key, grey for =, yellow/orange for value
            print(f"  {pref_color}{key_color} \033[90m=\033[0m \033[33m{val}\033[0m")
        elif item[0] == "raw":
            # Default formatting for other lines
            print(f"  {item[1]}")
    print()

def main():
    current_file = None
    current_lines = []
    
    header_re = re.compile(r"^==>\s*(.*?)\s*<==$")
    
    for line in sys.stdin:
        line_str = line.rstrip("\r\n")
        match = header_re.match(line_str)
        if match:
            if current_file is not None:
                print_file_content(current_file, current_lines)
            current_file = match.group(1)
            current_lines = []
        else:
            current_lines.append(line_str)
            
    if current_file is not None:
        print_file_content(current_file, current_lines)

if __name__ == "__main__":
    main()
