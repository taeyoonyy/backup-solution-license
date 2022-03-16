

const crypto = require("./crypto_aes256gcm");
const AAD = "BACKUPSOLUTION";
const KEY = Buffer.from("ID/RwsnZ3UhfScbnuZlVNW9BxjDeQne84T9fXOnEFOA=", "base64");


// Online Type
const licenseKey1 = "zdIOCWFe9w+lijMoaXr4bw==gWCEW0c/qRNXaUr/vjoDHA==+hGsKIfoVehWQ4+hajhe2JLUwIByjJka+n7jVNNViQWYiMZ2OxMdD+b5jJ7ToR4qTiPs9ejFWw==";
const message1 = crypto.decryptMsg({ KEY: KEY, AAD: AAD, licenseKey: licenseKey1 });
console.log(message1);
// { date: 'unlimited', tag: 100, type: 'online', user: 1 }

// Offline Type
// offline key = "t7V2ZnjGYiXOj3cm7DIltw==FhMvb97KZoqeIBEBwgDOyQ==p1BxXtfKpg4P+EPcmIbZCSJe37FeUOzItnQQ35POFCVSEWQRkunx59cwVWC45f0ib64TsuorZPe5OagKQdYSsdlqJROSVUt5eRBs8Up96i7gleIZELdASeVGESMUNtZEuTxXmyFbIeDmaXzxmyhBCNuK78vG7bCqlOAqGsk0waTWkDivCEoDxlIDyFGrGGEsUE3Yxw=="
const licenseKey2 = "rHDEctoCZMDiE22h4YPICA==JPSNm9x7QeUGYdOlqfmXqw==+S0w2S/CYC5ohKn8OZR9BYJ1OiDvZ1b7MtsTI9Ob57S86qOOvxKvisj4Rwl5piVvBZGi6KJHUCRaNF8n5nApp8gnkBfICqXd4u8/monpAfEVjXXFJPQnqV6YiveICmUNtMrfM4G6TbmsDSEz/3BtDf7nbhvy83fZHcZc1RenDlHav2h0vF3Z7aenvejK8Ke93vt2iMIFD/UGDOyYxstzsrqh8fxMacgc2JpEezxvY3AfAEeZWH27G/6Ik9nrBEkERE7mlUBd8u+1J0s=";
const message2 = crypto.decryptMsg({ KEY: KEY, AAD: AAD, licenseKey: licenseKey2 });
console.log(message2);
// {
//     date: 'unlimited',
//     host: 'DESKTOP-5A7SM9K',
//     mac: [
//       [ 0, 21, 93, 109, 200, 151 ],
//       [ 80, 235, 113, 96, 185, 45 ],
//       [ 82, 235, 113, 96, 185, 44 ],
//       [ 80, 235, 113, 96, 185, 44 ],
//       [ 80, 235, 113, 96, 185, 48 ]
//     ],
//     tag: 100,
//     type: 'offline',
//     user: 3
// }