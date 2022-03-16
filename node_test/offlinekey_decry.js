const crypto = require("./crypto_aes256gcm");

const AAD = "OFFLINEKEY";
const KEY = Buffer.from("ID/RwsnZ3UhfScbnuZlVNW9BxjDeQne84T9fXOnEFOA=", "base64");

const licenseKey = "t7V2ZnjGYiXOj3cm7DIltw==FhMvb97KZoqeIBEBwgDOyQ==p1BxXtfKpg4P+EPcmIbZCSJe37FeUOzItnQQ35POFCVSEWQRkunx59cwVWC45f0ib64TsuorZPe5OagKQdYSsdlqJROSVUt5eRBs8Up96i7gleIZELdASeVGESMUNtZEuTxXmyFbIeDmaXzxmyhBCNuK78vG7bCqlOAqGsk0waTWkDivCEoDxlIDyFGrGGEsUE3Yxw==";

const message = crypto.decryptMsg({ KEY: KEY, AAD: AAD, licenseKey: licenseKey });

console.log(message);