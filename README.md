# PDF Image Remover

A Python utility script to remove images from PDF files while preserving all text content.

## Features

- ✅ **Preserves text content** - All text remains intact
- 🖼️ **Removes all images** - Eliminates XObject resources containing images
- 📁 **Batch processing** - Process entire directories of PDF files
- 🔄 **Smart output naming** - Auto-generates output filenames with "_no_images" suffix
- 📊 **Progress tracking** - Shows processing status for each page
- 🛡️ **Error handling** - Graceful handling of corrupted or invalid PDFs

## Installation

Make sure you have the required Python packages installed:

```bash
pip3 install --break-system-packages PyPDF2 reportlab
```

## Usage

### Single File Processing

```bash
# Basic usage - output file auto-generated
python3 remove_pdf_images.py input.pdf

# Specify custom output file
python3 remove_pdf_images.py input.pdf output.pdf
```
 
### Directory Processing

```bash
# Process all PDF files in a directory
python3 remove_pdf_images.py /path/to/pdf/directory/
```

### Examples

```bash
# Remove images from a single PDF
python3 remove_pdf_images.py "466-פרשת בלק תשפה.pdf"

# Process all PDFs in Downloads folder
python3 remove_pdf_images.py ~/Downloads/

# Custom output filename
python3 remove_pdf_images.py document.pdf clean_document.pdf
```

## Output

- **Single file**: Creates `filename_no_images.pdf` in the same directory
- **Directory**: Processes all `.pdf` files, skipping those already containing "_no_images"
- **Progress**: Shows real-time processing status with emojis and progress indicators

## Error Handling

The script handles various error conditions:
- Missing input files or directories
- Corrupted PDF files
- Permission issues
- Invalid file formats

## Technical Details

- Uses PyPDF2 for PDF manipulation
- Removes XObject resources which typically contain images
- Preserves document structure and formatting
- Supports Hebrew and other Unicode text
- Memory efficient processing

## Author

Created by Snir Radomsky - July 2025