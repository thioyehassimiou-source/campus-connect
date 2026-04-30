const fs = require('fs');
const path = require('path');

function processDir(dir) {
  const files = fs.readdirSync(dir);
  for (const file of files) {
    const fullPath = path.join(dir, file);
    if (fs.statSync(fullPath).isDirectory()) {
      processDir(fullPath);
    } else if (fullPath.endsWith('.ts')) {
      let content = fs.readFileSync(fullPath, 'utf8');
      
      // Fix req.query being used in destructuring
      content = content.replace(/const {([^}]+)} = req\.query;/g, 'const {$1} = req.query as Record<string, string>;');
      
      // Fix req.params being used in destructuring
      content = content.replace(/const {([^}]+)} = req\.params;/g, 'const {$1} = req.params as Record<string, string>;');
      
      fs.writeFileSync(fullPath, content);
    }
  }
}

processDir('src/controllers');
console.log('Fixed req.params and req.query destructuring');
