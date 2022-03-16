const crypto = require("./crypto_aes256gcm");

const AAD = "OFFLINEKEY";
const KEY = Buffer.from("ID/RwsnZ3UhfScbnuZlVNW9BxjDeQne84T9fXOnEFOA=", "base64");

const message = JSON.stringify({
    host: "DESKTOP-5A7SM9K",
    mac: [
      [0, 21, 93, 109, 200, 151],
      [80, 235, 113, 96, 185, 45],
      [82, 235, 113, 96, 185, 44],
      [80, 235, 113, 96, 185, 44],
      [80, 235, 113, 96, 185, 48]
    ]
})

const result = crypto.encryptMsg({ KEY: KEY, AAD: AAD, message: message });

console.log(result);
// t7V2ZnjGYiXOj3cm7DIltw==FhMvb97KZoqeIBEBwgDOyQ==p1BxXtfKpg4P+EPcmIbZCSJe37FeUOzItnQQ35POFCVSEWQRkunx59cwVWC45f0ib64TsuorZPe5OagKQdYSsdlqJROSVUt5eRBs8Up96i7gleIZELdASeVGESMUNtZEuTxXmyFbIeDmaXzxmyhBCNuK78vG7bCqlOAqGsk0waTWkDivCEoDxlIDyFGrGGEsUE3Yxw==