const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');

const ENV_PATH = path.join(__dirname, '.env');

// Parse simple .env
function getEnv() {
  const env = { DB_USER: 'root', DB_PASSWORD: '', DB_NAME: 'fleetpro_db', DB_HOST: '127.0.0.1', DB_PORT: '3306' };
  if (fs.existsSync(ENV_PATH)) {
    const lines = fs.readFileSync(ENV_PATH, 'utf-8').split('\n');
    lines.forEach(line => {
      const match = line.match(/^([^=]+)=(.*)$/);
      if (match) {
        env[match[1].trim()] = match[2].trim().replace(/^"|'/, '').replace(/"|'$/, '');
      }
    });
  }
  return env;
}

function saveEnv(host, port, user, pass, db) {
const auth = pass ? `${user}:${pass}` : user;
  const content = `DB_HOST=${host}
DB_PORT=${port}
DB_USER=${user}
DB_PASSWORD=${pass}
DB_NAME=${db}
MYSQL_URL=mysql://${auth}@${host}:${port}/${db}
`;
  fs.writeFileSync(ENV_PATH, content, 'utf-8');
}

const sleep = (ms) => new Promise(r => setTimeout(r, ms));

async function checkAndCreate() {
  const env = getEnv();
  const hostsToTry = [env.DB_HOST, '127.0.0.1', 'localhost'];
  const portsToTry = [parseInt(env.DB_PORT) || 3306, 3306, 3307, 3308];
  const user = env.DB_USER || 'root';
  const password = env.DB_PASSWORD || '';
  const dbName = env.DB_NAME || 'fleetpro_db';

  console.log(`\n🔍 بدء فحص الاتصال بقاعدة البيانات...`);

  let connection = null;
  let successfulHost = null;
  let successfulPort = null;

  for (const host of [...new Set(hostsToTry)]) {
    if (!host) continue;
    for (const port of [...new Set(portsToTry)]) {
      if (!port) continue;
      for (let attempt = 1; attempt <= 3; attempt++) {
        try {
          console.log(`⏳ محاولة الاتصال (${host}:${port}) - المحاولة ${attempt}/3...`);
          connection = await mysql.createConnection({ host, port, user, password });
          console.log(`✅ تم الاتصال بنجاح على ${host}:${port}!`);
          successfulHost = host;
          successfulPort = port;
          break; // break retry loop
        } catch (err) {
          console.log(`❌ فشل الاتصال (${host}:${port}) - المحاولة ${attempt}/3 - خطأ: ${err.message}`);
          if (attempt < 3) await sleep(2000); // wait 2s before retry
        }
      }
      if (connection) break; // break ports loop
    }
    if (connection) break; // break hosts loop
  }

  if (!connection) {
    console.error(`\n🚨 فشل الاتصال بقاعدة البيانات تماماً بعد تجربة جميع الإعدادات المحتملة.`);
    console.error(`⚠️ يرجى التأكد من تشغيل خادم MySQL (مثلاً من خلال Laragon) والمحاولة مرة أخرى.`);
    // Don't kill process to not break the server
    return false; 
  }

  // Ensure DB exists
  try {
    console.log(`🛠️ جاري التحقق من وجود قاعدة البيانات '${dbName}'...`);
    await connection.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\`;`);
    console.log(`✅ قاعدة البيانات '${dbName}' جاهزة.`);
    
    // Save successful config
    saveEnv(successfulHost, successfulPort, user, password, dbName);
    console.log(`⚙️ تم تحديث ملف .env تلقائياً بالإعدادات الصحيحة.`);
    
  } catch (err) {
    console.error(`❌ حدث خطأ أثناء محاولة إنشاء قاعدة البيانات:`, err.message);
  } finally {
    await connection.end();
  }
  
  return true;
}

checkAndCreate().then(success => {
  if (success) {
    console.log(`\n🎉 النظام جاهز للعمل. يمكنك الآن تشغيل السيرفر أو Migrations.`);
  } else {
    console.log(`\n⚠️ النظام مستمر في العمل ولكن بدون قاعدة بيانات. بعض الميزات قد لا تعمل.`);
  }
});
