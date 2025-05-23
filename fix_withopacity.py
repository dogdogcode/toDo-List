#!/usr/bin/env python3
import os
import re

def fix_withopacity_in_file(filepath):
    """Fix withOpacity deprecated warnings by replacing with withValues"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Replace withOpacity with withValues
        # Pattern: .withOpacity(NUMBER) -> .withValues(alpha: NUMBER)
        pattern = r'\.withOpacity\(([^)]+)\)'
        replacement = r'.withValues(alpha: \1)'
        
        new_content = re.sub(pattern, replacement, content)
        
        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Fixed {filepath}")
            return True
        return False
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return False

def main():
    # Process all dart files in lib directory
    lib_path = '/Users/kimjimin/Documents/DEV/todo/lib'
    fixed_count = 0
    
    for root, dirs, files in os.walk(lib_path):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                if fix_withopacity_in_file(filepath):
                    fixed_count += 1
    
    print(f"\nFixed {fixed_count} files")

if __name__ == "__main__":
    main()
