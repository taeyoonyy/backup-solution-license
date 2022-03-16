const crypto = require("crypto");

const ALGORITHM = "aes-256-gcm";

/*
  KEY: random 32bytes(Keep);
  IV: random 16bytes(one time);
  AAD: string;
  message: string;
*/
module.exports = {
  encryptMsg: ({ KEY, AAD, message }) => {
    const IV = Buffer.from(crypto.randomBytes(16));
    const cipher = crypto.createCipheriv(ALGORITHM, KEY, IV);
    cipher.setAAD(Buffer.from(AAD), { encoding: "utf8" })
    let cipherText = cipher.update(message, "utf8", "base64");
    cipherText += cipher.final("base64");

    return (IV.toString("base64") + cipher.getAuthTag().toString("base64") + cipherText);
  },
  decryptMsg: ({ KEY, AAD, licenseKey }) => {
    const IV = Buffer.from(licenseKey.slice(0, 24), "base64");
    const authTag = Buffer.from(licenseKey.slice(24, 48), "base64");
    const cipherText = licenseKey.slice(48);

    const decipher = crypto.createDecipheriv(ALGORITHM, KEY, IV);
    decipher.setAAD(Buffer.from(AAD));
    decipher.setAuthTag(authTag);
    let message = decipher.update(cipherText, "base64", "utf8");
    message += decipher.final("utf8");

    try {
      return JSON.parse(message);
    } catch (e) {
      return message;
    }
  },
}