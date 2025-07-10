#!/usr/bin/env python3
"""
PDF Image Remover Script
========================

A utility script to remove images from PDF files while preserving text content.
This script can process single files or entire directories.

Usage:
    python3 remove_pdf_images.py input.pdf [output.pdf]
    python3 remove_pdf_images.py /path/to/directory/
    python3 remove_pdf_images.py --help

Author: Snir Radomsky
Created: July 2025
"""

import PyPDF2
import os
import sys
import argparse
from pathlib import Path


def remove_images_from_pdf(input_path, output_path=None):
    """
    Remove images from a PDF file while preserving text content.
    
    Args:
        input_path (str): Path to the input PDF file
        output_path (str): Path to the output PDF file (optional)
    
    Returns:
        bool: True if successful, False otherwise
    """
    try:
        # Generate output path if not provided
        if output_path is None:
            input_file = Path(input_path)
            output_path = input_file.parent / f"{input_file.stem}_no_images{input_file.suffix}"
        
        # Open the input PDF
        with open(input_path, 'rb') as file:
            pdf_reader = PyPDF2.PdfReader(file)
            pdf_writer = PyPDF2.PdfWriter()
            
            total_pages = len(pdf_reader.pages)
            print(f"📄 Processing {total_pages} pages from: {Path(input_path).name}")
            
            # Process each page
            for page_num, page in enumerate(pdf_reader.pages):
                print(f"  ⏳ Processing page {page_num + 1}/{total_pages}...", end='\r')
                
                # Create a new page without images
                new_page = page
                
                # Remove images by removing XObject resources
                if '/Resources' in page:
                    resources = page['/Resources']
                    if '/XObject' in resources:
                        # Remove all XObjects (which typically contain images)
                        del resources['/XObject']
                
                # Add the modified page to the writer
                pdf_writer.add_page(new_page)
            
            # Write the output PDF
            with open(output_path, 'wb') as output_file:
                pdf_writer.write(output_file)
            
            print(f"  ✅ Successfully created: {Path(output_path).name}")
            return True
            
    except Exception as e:
        print(f"  ❌ Error processing {Path(input_path).name}: {e}")
        return False


def process_directory(directory_path):
    """
    Process all PDF files in a directory.
    
    Args:
        directory_path (str): Path to the directory containing PDF files
    """
    directory = Path(directory_path)
    pdf_files = list(directory.glob("*.pdf"))
    
    if not pdf_files:
        print(f"❌ No PDF files found in: {directory_path}")
        return
    
    print(f"🔍 Found {len(pdf_files)} PDF files in: {directory_path}")
    
    success_count = 0
    for pdf_file in pdf_files:
        # Skip files that already have "_no_images" in the name
        if "_no_images" in pdf_file.stem:
            print(f"  ⏭️  Skipping: {pdf_file.name} (already processed)")
            continue
            
        if remove_images_from_pdf(str(pdf_file)):
            success_count += 1
    
    print(f"\n🎉 Successfully processed {success_count}/{len(pdf_files)} files")


def main():
    parser = argparse.ArgumentParser(
        description="Remove images from PDF files while preserving text content",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s document.pdf
  %(prog)s input.pdf output.pdf
  %(prog)s /path/to/pdf/directory/
  %(prog)s --help
        """
    )
    
    parser.add_argument(
        'input',
        help='Input PDF file or directory containing PDF files'
    )
    
    parser.add_argument(
        'output',
        nargs='?',
        help='Output PDF file (optional, auto-generated if not provided)'
    )
    
    parser.add_argument(
        '--version',
        action='version',
        version='%(prog)s 1.0.0'
    )
    
    # If no arguments provided, show help
    if len(sys.argv) == 1:
        parser.print_help()
        return
    
    args = parser.parse_args()
    
    # Check if input exists
    if not os.path.exists(args.input):
        print(f"❌ Error: Input path not found: {args.input}")
        return
    
    # Process directory or single file
    if os.path.isdir(args.input):
        if args.output:
            print("⚠️  Warning: Output parameter ignored when processing directory")
        process_directory(args.input)
    else:
        # Process single file
        if not args.input.lower().endswith('.pdf'):
            print("❌ Error: Input file must be a PDF")
            return
        
        success = remove_images_from_pdf(args.input, args.output)
        if success:
            print("🎉 Done!")
        else:
            print("❌ Failed to process the PDF")


if __name__ == "__main__":
    main()