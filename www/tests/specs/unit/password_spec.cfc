component extends="testbox.system.BaseSpec" {

    /*
        global.cfc - password hashing (hashPassword, verifyPassword).

        Passwords used to be stored as a fast SHA-512 of password & salt. New and
        changed passwords are hashed with Argon2id; legacy hashes still work and are
        replaced on the next successful login (needsRehash).
    */

    function run() {

        var globalObj = application.objGlobal;

        describe("hashPassword", () => {

            it("produces an Argon2id hash with the configured cost", () => {
                var passwordHash = globalObj.hashPassword("correct horse battery staple");

                expect(passwordHash).toInclude("$argon2id$v=19$m=19456,t=2,p=1$");
            });

            it("salts every hash individually", () => {
                expect(globalObj.hashPassword("same")).notToBe(globalObj.hashPassword("same"));
            });

            it("fits into users.strPasswordHash (varchar 255)", () => {
                expect(len(globalObj.hashPassword(repeatString("x", 200)))).toBeLTE(255);
            });

        });

        describe("verifyPassword with Argon2 hashes", () => {

            it("accepts the right password without asking for a rehash", () => {
                var check = globalObj.verifyPassword("secret", globalObj.hashPassword("secret"));

                expect(check.valid).toBeTrue();
                expect(check.needsRehash).toBeFalse();
            });

            it("rejects a wrong password", () => {
                expect(globalObj.verifyPassword("wrong", globalObj.hashPassword("secret")).valid).toBeFalse();
            });

            it("asks for a rehash when the hash uses weaker settings", () => {
                var weak = globalObj.argon2Encode("secret", "argon2i", 19, 8, 1, 1, charsetDecode("weak-salt-16byte", "utf-8"));
                var check = globalObj.verifyPassword("secret", weak);

                expect(check.valid).toBeTrue();
                expect(check.needsRehash).toBeTrue();
            });

            it("rejects a broken hash instead of failing", () => {
                expect(globalObj.verifyPassword("secret", "$argon2id$garbage").valid).toBeFalse();
            });

        });

        describe("Argon2 implementation (Bouncy Castle, pure Java)", () => {

            /*
                Since Lucee 6.1 GenerateArgon2Hash() is an extension with a native library
                that is missing on ARM servers, so the hashing runs on Bouncy Castle. The
                results must be exactly those of the reference implementation - otherwise
                every stored password would stop working.
            */
            var salt = charsetDecode("somesalt", "utf-8");

            it("matches the test vectors of the reference implementation", () => {
                expect(globalObj.argon2Encode("password", "argon2id", 19, 65536, 2, 1, salt))
                    .toBe("$argon2id$v=19$m=65536,t=2,p=1$c29tZXNhbHQ$CTFhFdXPJO1aFaMaO6Mm5c8y7cJHAph8ArZWb2GRPPc");
                expect(globalObj.argon2Encode("password", "argon2i", 19, 65536, 2, 4, salt, 24))
                    .toBe("$argon2i$v=19$m=65536,t=2,p=4$c29tZXNhbHQ$RdescudvJCsgt3ub+b+dWRWJTmaaJObG");
            });

            it("verifies hashes of version 1.0 (without the v= part)", () => {
                expect(globalObj.verifyPassword("password", "$argon2i$m=65536,t=2,p=1$c29tZXNhbHQ$9sTbSlTio3Biev89thdrlKKiCaYsjjYVJxGAL3swxpQ").valid).toBeTrue();
            });

            it("verifies a hash made with GenerateArgon2Hash() on Lucee 6.0 (demo seeds)", () => {
                var stored = "$argon2id$v=19$m=19456,t=2,p=1$4cmXB3REA9udGAnL0X4Dsw$7nb6tEL7bSvnJwNr02mnCIPQ12IIy7we/iHrF4g5MQo";
                var check = globalObj.verifyPassword("Saaster-Demo-2026!", stored);

                expect(check.valid).toBeTrue();
                expect(check.needsRehash).toBeFalse();
                expect(globalObj.verifyPassword("Saaster-Demo-2026?", stored).valid).toBeFalse();
            });

            it("hashes passwords with umlauts as UTF-8", () => {
                expect(globalObj.verifyPassword("Grüezi-Zürich", globalObj.hashPassword("Grüezi-Zürich")).valid).toBeTrue();
                expect(globalObj.verifyPassword("Gruezi-Zurich", globalObj.hashPassword("Grüezi-Zürich")).valid).toBeFalse();
            });

            it("rejects unknown variants and broken cost values", () => {
                expect(globalObj.verifyPassword("x", "$argon2xx$v=19$m=8,t=1,p=1$c29tZXNhbHQ$YQ").valid).toBeFalse();
                expect(globalObj.verifyPassword("x", "$argon2id$v=19$m=abc,t=1,p=1$c29tZXNhbHQ$YQ").valid).toBeFalse();
            });

        });

        describe("verifyPassword with legacy SHA-512 hashes", () => {

            beforeEach(() => {
                variables.salt = hash(createUUID(), "SHA-512");
                variables.legacyHash = hash("secret" & variables.salt, "SHA-512");
            });

            it("accepts the right password and asks for a rehash", () => {
                var check = globalObj.verifyPassword("secret", variables.legacyHash, variables.salt);

                expect(check.valid).toBeTrue();
                expect(check.needsRehash).toBeTrue();
            });

            it("rejects a wrong password", () => {
                var check = globalObj.verifyPassword("wrong", variables.legacyHash, variables.salt);

                expect(check.valid).toBeFalse();
                expect(check.needsRehash).toBeFalse();
            });

            it("rejects a legacy hash without its salt", () => {
                expect(globalObj.verifyPassword("secret", variables.legacyHash, "").valid).toBeFalse();
            });

        });

        describe("isValidPassword (password policy)", () => {

            it("requires at least 8 characters", () => {
                expect(globalObj.passwordMinLength()).toBe(8);
                expect(globalObj.isValidPassword("1234567")).toBeFalse();
                expect(globalObj.isValidPassword("12345678")).toBeTrue();
            });

            it("rejects an empty or blank password", () => {
                expect(globalObj.isValidPassword("")).toBeFalse();
                expect(globalObj.isValidPassword("          ")).toBeFalse();
            });

            it("rejects absurdly long input", () => {
                expect(globalObj.isValidPassword(repeatString("x", 256))).toBeTrue();
                expect(globalObj.isValidPassword(repeatString("x", 257))).toBeFalse();
            });

        });

        describe("verifyPassword without a password", () => {

            // Invited users have no password yet - nobody may log in as them.
            it("rejects every password for an empty hash", () => {
                expect(globalObj.verifyPassword("", "", "").valid).toBeFalse();
                expect(globalObj.verifyPassword("anything", "", "").valid).toBeFalse();
            });

        });

    }

}
