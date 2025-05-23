const fs = require('fs');
const path = require('path');

// Replace withOpacity with withValues
function fixWithOpacityInFile(filePath) {
  try {
    let content = fs.readFileSync(filePath, 'utf8');
    const originalContent = content;
    
    // Pattern: .withOpacity(NUMBER) -> .withValues(alpha: NUMBER)
    content = content.replace(/\.withOpacity\(([^)]+)\)/g, '.withValues(alpha: $1)');
    
    if (content !== originalContent) {
      fs.writeFileSync(filePath, content, 'utf8');
      console.log(`Fixed ${filePath}`);
      return true;
    }
    return false;
  } catch (error) {
    console.error(`Error processing ${filePath}:`, error);
    return false;
  }
}

// Walk through directory
function walkDir(dir, callback) {
  fs.readdirSync(dir).forEach(f => {
    const filePath = path.join(dir, f);
    const stat = fs.statSync(filePath);
    
    if (stat.isDirectory()) {
      walkDir(filePath, callback);
    } else if (path.extname(filePath) === '.dart') {
      callback(filePath);
    }
  });
}

// Main
const libPath = '/Users/kimjimin/Documents/DEV/todo/lib';
let fixedCount = 0;

walkDir(libPath, (filePath) => {
  if (fixWithOpacityInFile(filePath)) {
    fixedCount++;
  }
});

console.log(`\nFixed ${fixedCount} files`);
