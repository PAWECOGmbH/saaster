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
                var weak = GenerateArgon2Hash("secret", "argon2i", 1, 8, 1);
                var check = globalObj.verifyPassword("secret", weak);

                expect(check.valid).toBeTrue();
                expect(check.needsRehash).toBeTrue();
            });

            it("rejects a broken hash instead of failing", () => {
                expect(globalObj.verifyPassword("secret", "$argon2id$garbage").valid).toBeFalse();
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
