component displayname="meta" output="false" {

    public struct function getMeta(required string url_slug, required string lng) {

        local.returnStruct = structNew();
        local.returnStruct['metaTtile'] = variables.metaTitle;
        local.returnStruct['metaDescription'] = variables.metaDescription;
        local.returnStruct['metaHTML'] = variables.metaHTML;

        local.urlSlug = replace(arguments.url_slug,'/','','one');
        local.lngID = application.objLanguage.getAnyLanguage(arguments.lng).lngID;

        if (len(trim(local.urlSlug))) {

            local.qMetaTags = queryExecute(

                options = {datasource = application.datasource},
                params = {
                    mapping: {type: "varchar", value: local.urlSlug},
                    languageID: {type: "numeric", value: local.lngID},
                },
                sql = "

                    SELECT
                    (
                        IF
                            (
                                LENGTH(
                                    (
                                        SELECT strMetatitle
                                        FROM frontend_mappings_trans
                                        WHERE intFrontendMappingsID = frontend_mappings.intFrontendMappingsID
                                        AND intLanguageID = :languageID
                                    )
                                ),
                                (
                                    SELECT strMetatitle
                                    FROM frontend_mappings_trans
                                    WHERE intFrontendMappingsID = frontend_mappings.intFrontendMappingsID
                                    AND intLanguageID = :languageID
                                ),
                                frontend_mappings.strMetatitle
                            )
                    ) as strMetatitle,
                    (
                        IF
                            (
                                LENGTH(
                                    (
                                        SELECT strMetadescription
                                        FROM frontend_mappings_trans
                                        WHERE intFrontendMappingsID = frontend_mappings.intFrontendMappingsID
                                        AND intLanguageID = :languageID
                                    )
                                ),
                                (
                                    SELECT strMetadescription
                                    FROM frontend_mappings_trans
                                    WHERE intFrontendMappingsID = frontend_mappings.intFrontendMappingsID
                                    AND intLanguageID = :languageID
                                ),
                                frontend_mappings.strMetadescription
                            )
                    ) as strMetadescription,
                    (
                        IF
                            (
                                LENGTH(
                                    (
                                        SELECT strhtmlcodes
                                        FROM frontend_mappings_trans
                                        WHERE intFrontendMappingsID = frontend_mappings.intFrontendMappingsID
                                        AND intLanguageID = :languageID
                                    )
                                ),
                                (
                                    SELECT strhtmlcodes
                                    FROM frontend_mappings_trans
                                    WHERE intFrontendMappingsID = frontend_mappings.intFrontendMappingsID
                                    AND intLanguageID = :languageID
                                ),
                                frontend_mappings.strhtmlcodes
                            )
                    ) as strhtmlcodes
                    FROM frontend_mappings
                    WHERE strMapping = :mapping
                    LIMIT 1
                "
            )

            if (local.qMetaTags.recordCount) {

                local.returnStruct['metaTtile'] = len(trim(local.qMetaTags.strMetatitle)) ? local.qMetaTags.strMetatitle : variables.metaTitle;
                local.returnStruct['metaDescription'] = len(trim(local.qMetaTags.strMetadescription)) ? local.qMetaTags.strMetadescription : variables.metaDescription;
                local.returnStruct['metaHTML'] = len(trim(local.qMetaTags.strhtmlcodes)) ? local.qMetaTags.strhtmlcodes : variables.metaHTML;

            }

        }

        return local.returnStruct;

    }

}