component extends="tests.support.integration_spec" {

    /*
        objGlobal.uploadFile() - real multipart uploads through support/upload_probe.cfm.

        The upload first lands in a private temporary folder; only a file that
        passed the extension and size checks is moved into the target folder, under
        a new name. A rejected file must leave nothing behind - neither in the target
        nor in the temporary folder.
    */

    variables.probeUrl = "http://127.0.0.1/tests/support/upload_probe.cfm";

    function run() {

        describe("uploadFile", () => {

            beforeEach(() => {
                variables.workDir = getTempDirectory() & "saaster-upload-spec/" & createUUID();
                directoryCreate(variables.workDir, true);
            });

            afterEach(() => {
                if (directoryExists(variables.workDir)) {
                    directoryDelete(variables.workDir, true);
                }
            });

            it("accepts an allowed image and stores it in the target folder", () => {
                var answer = upload(expandPath("/assets/img/logo.png"));

                expect(answer.success).toBeTrue(answer.message);
                expect(answer.fileName).toInclude(".png");
                expect(answer.targetFiles).toBe([answer.fileName]);
            });

            it("rejects a forbidden extension and leaves nothing in the target folder", () => {
                var answer = upload(sampleFile("notes.txt", "plain text"));

                expect(answer.success).toBeFalse();
                expect(answer.message).toBe("msgFileExtForbidden");
                expect(answer.targetFiles).toBeEmpty();
            });

            it("rejects a script disguised with a second extension", () => {
                var answer = upload(sampleFile("shell.png.txt", "<" & "cfoutput>##now()##</" & "cfoutput>"));

                expect(answer.success).toBeFalse();
                expect(answer.targetFiles).toBeEmpty();
            });

            it("never stores a CFML file, even if the extension were allowed", () => {
                // Lucee itself refuses .cfm uploads; Saaster's own check would reject it too.
                var answer = upload(sampleFile("shell.cfm", "<" & "cfoutput>##now()##</" & "cfoutput>"), { allowed: "png,cfm" });

                expect(answer.success).toBeFalse();
                expect(answer.targetFiles).toBeEmpty();
            });

            it("rejects a file above the size limit and leaves nothing in the target folder", () => {
                var answer = upload(expandPath("/assets/img/logo.png"), { maxSize: "0.001" });

                expect(answer.success).toBeFalse();
                expect(answer.message).toBe("msgFileTooLarge");
                expect(answer.targetFiles).toBeEmpty();
            });

            it("removes its temporary upload folder in every case", () => {
                var before = upload(sampleFile("notes.txt", "plain text")).tempFolders;
                upload(expandPath("/assets/img/logo.png"));
                upload(expandPath("/assets/img/logo.png"), { maxSize: "0.001" });
                var after = upload(sampleFile("notes.txt", "plain text")).tempFolders;

                expect(after).toBe(before);
            });

        });

        describe("uploadFile source", () => {

            it("uploads into the temp directory first and moves the file afterwards", () => {
                var source = new tests.support.security_scanner().readSource("backend/core/com/global.cfc");
                var body = mid(source, find("function uploadFile(", source), 6000);

                expect(body).toInclude("getTempDirectory()");
                expect(reFind("fileUpload\([^)]*destination\s*=\s*local\.tempDir", body)).toBeGT(0, "fileUpload() must write into the temporary folder");
                expect(find("listFindNoCase(local.allowedFileTypesList", body)).toBeLT(find("fileMove(", body), "The extension check must run before the move");
            });

        });

    }

    private struct function upload(required string filePath, struct fields = {}) {
        cfhttp(url = variables.probeUrl, method = "post", multipart = true, timeout = 20, result = "local.response") {
            cfhttpparam(type = "file", name = "file", file = arguments.filePath);
            for (var key in arguments.fields) {
                cfhttpparam(type = "formfield", name = key, value = arguments.fields[key]);
            }
        }

        if (not isJSON(local.response.fileContent)) {
            fail("No JSON from the upload probe (" & local.response.statusCode & "): " & left(local.response.fileContent, 500));
        }

        return deserializeJSON(local.response.fileContent);
    }

    private string function sampleFile(required string name, required string content) {
        var path = variables.workDir & "/" & arguments.name;
        fileWrite(path, arguments.content);
        return path;
    }

}
