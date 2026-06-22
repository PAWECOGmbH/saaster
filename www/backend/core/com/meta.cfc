component displayname="meta" output="false" {

    public struct function getMeta(required string url_slug) {

        local.returnStruct = structNew();
        local.returnStruct['metaTitle'] = variables.metaTitle;
        local.returnStruct['metaDescription'] = variables.metaDescription;
        local.returnStruct['metaHTML'] = variables.metaHTML;

        local.urlSlug = replace(arguments.url_slug,'/','','one');

        if (len(trim(local.urlSlug))) {

            // First, try to find meta in frontend_mappings
            local.qMetaFM = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    mapping: {type: "varchar", value: local.urlSlug}
                },
                sql = "
                    SELECT strMetatitle, strMetadescription, strhtmlcodes
                    FROM frontend_mappings
                    WHERE strMapping = :mapping
                    LIMIT 1
                "
            );

            if (local.qMetaFM.recordCount) {

                local.returnStruct['metaTitle'] = len(trim(local.qMetaFM.strMetatitle)) ? local.qMetaFM.strMetatitle : variables.metaTitle;
                local.returnStruct['metaDescription'] = len(trim(local.qMetaFM.strMetadescription)) ? local.qMetaFM.strMetadescription : variables.metaDescription;
                local.returnStruct['metaHTML'] = len(trim(local.qMetaFM.strhtmlcodes)) ? local.qMetaFM.strhtmlcodes : variables.metaHTML;

            } else {

                // If not found, try frontend_mappings_trans
                local.qMetaFT = queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        mapping: {type: "varchar", value: local.urlSlug}
                    },
                    sql = "
                        SELECT strMetatitle, strMetadescription, strhtmlcodes
                        FROM frontend_mappings_trans
                        WHERE strMapping = :mapping
                        LIMIT 1
                    "
                );

                if (local.qMetaFT.recordCount) {
                    local.returnStruct['metaTitle'] = len(trim(local.qMetaFT.strMetatitle)) ? local.qMetaFT.strMetatitle : variables.metaTitle;
                    local.returnStruct['metaDescription'] = len(trim(local.qMetaFT.strMetadescription)) ? local.qMetaFT.strMetadescription : variables.metaDescription;
                    local.returnStruct['metaHTML'] = len(trim(local.qMetaFT.strhtmlcodes)) ? local.qMetaFT.strhtmlcodes : variables.metaHTML;
                }

            }

        }

        return local.returnStruct;

    }

}