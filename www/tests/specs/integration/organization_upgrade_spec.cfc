component extends="tests.support.integration_spec" {
    function run() {
        describe("V29 identity and membership upgrade", () => {
            afterEach(() => {
                execute("DROP TABLE IF EXISTS migration_roles_membership_identities, migration_roles_organization_memberships,
                    migration_roles_organization_access, migration_roles_users, migration_roles_customers");
            });
            it("preserves IDs, roles and legacy state without activating or granting access to another organization", () => {
                execute("CREATE TABLE migration_roles_customers (intCustomerID INT PRIMARY KEY, intCustParentID INT NOT NULL)");
                execute("CREATE TABLE migration_roles_users (intUserID INT PRIMARY KEY, intCustomerID INT NOT NULL, strEmail VARCHAR(100), blnAdmin TINYINT,
                    CONSTRAINT migration_roles_user_customer FOREIGN KEY (intCustomerID) REFERENCES migration_roles_customers(intCustomerID) ON DELETE CASCADE)");
                execute("CREATE TABLE migration_roles_organization_memberships (intOrgMembershipID INT PRIMARY KEY, intUserID INT NOT NULL,
                    intOrganizationID INT NOT NULL, strRoleKey VARCHAR(50), strStatus VARCHAR(20), UNIQUE KEY uq_organization_membership_user (intUserID))");
                execute("CREATE TABLE migration_roles_organization_access (intOrganizationID INT PRIMARY KEY)");
                execute("INSERT INTO migration_roles_customers VALUES (1,0),(2,0),(3,1)");
                execute("INSERT INTO migration_roles_users VALUES (11,1,'müller@example.invalid',1),(12,2,'legacy@example.invalid',0)");
                execute("INSERT INTO migration_roles_organization_memberships VALUES (21,11,1,'organization.member','suspended')");
                execute("INSERT INTO migration_roles_organization_access VALUES (1)");
                local.users = serializeJSON(execute("SELECT * FROM migration_roles_users ORDER BY intUserID"));
                local.members = serializeJSON(execute("SELECT * FROM migration_roles_organization_memberships"));
                local.source = fileRead("/var/saaster/db/core/V29__multiple-organization-memberships.sql", "utf-8");
                // Fixed identifiers only: apply the real migration to an isolated pre-upgrade schema.
                loop list="organization_memberships,organization_access,membership_identities,users,customers" index="local.table" {
                    local.source = reReplaceNoCase(local.source, "\b" & local.table & "\b", "migration_roles_" & local.table, "all");
                }
                local.source = replace(local.source, "frn_user_customer", "migration_roles_user_customer", "all");
                local.source = replace(local.source, "fk_membership_identity_user", "migration_roles_identity_user", "all");
                local.lines = listToArray(replace(local.source, chr(13), "", "all"), chr(10), true).filter((line) => not reFind("^\s*--", line));
                loop array=listToArray(arrayToList(local.lines, chr(10)), ";") item="local.statement" {
                    if (len(trim(local.statement))) { execute(local.statement); }
                }
                expect(serializeJSON(execute("SELECT * FROM migration_roles_users ORDER BY intUserID"))).toBe(local.users);
                expect(serializeJSON(execute("SELECT * FROM migration_roles_organization_memberships"))).toBe(local.members);
                expect(execute("SELECT * FROM migration_roles_organization_access").recordCount).toBe(1);
                expect(execute("SELECT intUserID FROM migration_roles_membership_identities").intUserID).toBe(11);
                execute("INSERT INTO migration_roles_organization_memberships VALUES (22,11,2,'organization.member','active')");
                expect(() => execute("INSERT INTO migration_roles_organization_memberships VALUES (23,11,2,'organization.member','active')")).toThrow();
                execute("DELETE FROM migration_roles_customers WHERE intCustomerID = 1");
                expect(execute("SELECT intUserID FROM migration_roles_users WHERE intUserID = 11").recordCount).toBe(1);
                expect(execute("SELECT intUserID FROM migration_roles_users WHERE intUserID = 11 AND intCustomerID IS NULL").recordCount).toBe(1);
            });
        });
    }
    private any function execute(required string sql) {
        return queryExecute(options={datasource:application.datasource}, sql=arguments.sql);
    }
}
