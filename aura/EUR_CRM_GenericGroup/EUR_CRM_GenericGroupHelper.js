({
    processHeaderChange: function (cmp, oldHeader, newHeader) {
        if (oldHeader == null && !$A.util.isEmpty(newHeader)) {
            if ($A.util.isEmpty(newHeader.get('v.groups'))) {
                this.initGroupList(cmp, null, null, newHeader.get('v.group.Id'));
            }
        }
    },

    initGroupList: function (cmp, criteria, criteriaLogic, initGroupId) {
        const
            APEX_METHOD = cmp.getLocalId() === 'accountGroup'
                ? 'selectAccountGroups'
                : cmp.getLocalId() === 'productGroup'
                    ? 'selectProductGroups'
                    : 'selectPlvProductGroups',
            promo = cmp.get('v.parent').get('v.promo')

        if (criteria) {
            cmp.set('v.bypassChange', ['v.criteria', 'v.criteriaLogic']);
            cmp.set('v.criteria', criteria);
            cmp.set('v.criteriaLogic', criteriaLogic);
        }
        var header = cmp.get('v.header');
        cmp.set('v.isHeaderReady', false);
        this.CalloutService.runApex(APEX_METHOD, {
            'promoId': promo.Id || null
        }).then(result => {
            header.set('v.groups', result);
            if (!$A.util.isEmpty(result)) {
                header.set('v.group', initGroupId ? result.find(item => item.Id === initGroupId) : {});
            } else {
                header.set('v.group', {});
            }
            cmp.set('v.isHeaderReady', true);
            this.setGroup(cmp, header.get('v.group.Id'));
            cmp.get('v.parent').changeGroup(cmp.getLocalId(), cmp.get('v.header').get('v.group'));
        })
            .catch(error => {
                console.error(error);
                cmp.set('v.isHeaderReady', true);
            });
    },

    updateDataTable: function (cmp, sortBy, sortDirection) {
        const table = cmp.find('dataTable');
        const groupId = cmp.get('v.header').get('v.group.Id');
        cmp.set('v.isDataTableReady', false);
        cmp.set('v.offset', 0);
        this.CalloutService.runApex('selectRecords', {
            'query': this.constructTableRecordsQuery(cmp, groupId, sortBy, sortDirection),
            'ids': cmp.get('v.ids')
        })
            .then(result => {
                if (cmp.getLocalId() == 'productGroup') {
                    this.mapQueryResult(cmp, result);
                }
                table.set('v.data', result);
                cmp.get('v.header').set('v.recordsSize', $A.util.isEmpty(result) ? 0 : result.length);
                cmp.set('v.isDataTableReady', true);
                cmp.set('v.isGroupEmpty', $A.util.isEmpty(result));
                if (sortBy && sortDirection) {
                    table.set('v.sortedBy', sortBy);
                    table.set('v.sortedDirection', sortDirection);
                }
            }).catch(error => {
            console.error(error);
            cmp.set('v.isDataTableReady', true);
        });
    },

    showMore: function (cmp) {
        const table = cmp.find('dataTable')
            , sortBy = table.get('v.sortedBy')
            , sortDirection = table.get('v.sortedDirection')
            , groupId = cmp.get('v.header').get('v.group.Id')
            , limit = cmp.get('v.limit')
            , offset = cmp.get('v.offset')
            , hasMore = cmp.get('v.header').get('v.recordsSize') < cmp.get('v.header').get('v.totalSize');
        if (hasMore) {
            cmp.set('v.offset', limit + offset);
            cmp.set('v.isDataTableReady', false);
            this.CalloutService.runApex('selectRecords', {
                'query': this.constructTableRecordsQuery(cmp, groupId, sortBy, sortDirection),
                'ids': cmp.get('v.ids')
            }).then(result => {
                if (cmp.getLocalId() === 'productGroup') {
                    this.mapQueryResult(cmp, result);
                }
                table.set('v.data', table.get('v.data').concat(result));
                cmp.get('v.header').set('v.recordsSize', table.get('v.data').length);
                cmp.set('v.isDataTableReady', true);
                cmp.set('v.isGroupEmpty', $A.util.isEmpty(table.get('v.data')));
            }).catch(error => {
                console.error(error)
                cmp.set('v.isDataTableReady', true);
            });
        }

    },

    setGroup: function (cmp, groupId) {
        const table = cmp.find('dataTable');
        if (groupId) {
            const sortBy = table.get('v.sortedBy');
            const sortDirection = table.get('v.sortedDirection');
            cmp.set('v.offset', 0);
            cmp.set('v.isDataTableReady', false);
            this.CalloutService.runApex('selectAndCountRecords', {
                'query': this.constructTableRecordsQuery(cmp, groupId, sortBy, sortDirection),
                'countQuery': this.constructTableRecordsCountQuery(cmp, groupId)
            })
                .then(result => {
                    var sequence = result.queryResult;
                    if (cmp.getLocalId() === 'productGroup') {
                        if (cmp.get('v.parent').get('v.model')) {
                            cmp.set('v.mapping', cmp.get('v.parent').get('v.model.productsMapping'));
                        }
                        this.mapQueryResult(cmp, sequence);
                        sequence = this.getRecordsSequence(result.queryResult) || result.queryResult;
                    }
                    for (let i = 0; i<sequence.length; i++){
                        let row = sequence[i];
                        if (row.Owner){
                            row.OwnerName = row.Owner.Name;
                        }
                    }

                    table.set('v.data', sequence);
                    cmp.get('v.header').set('v.recordsSize', $A.util.isEmpty(sequence) ? 0 : sequence.length);
                    cmp.get('v.header').set('v.totalSize', result.countQueryResult);
                    cmp.set('v.isDataTableReady', true);
                    cmp.set('v.isGroupEmpty', $A.util.isEmpty(sequence));
                    cmp.get('v.parent').changeGroup(cmp.getLocalId(), cmp.get('v.header').get('v.group'));
                })
                .catch(error => {
                    console.error(error);
                    cmp.set('v.isDataTableReady', true);
                });
        } else {
            table.set('v.data', []);
            cmp.get('v.header').set('v.recordsSize', 0);
            cmp.get('v.header').set('v.totalSize', 0);
            cmp.set('v.isGroupEmpty', true);
            cmp.get('v.parent').changeGroup(cmp.getLocalId(), null);
        }
    },

    setRecordsByIds: function (cmp, ids) {
        const table = cmp.find('dataTable');
        cmp.set('v.isDataTableReady', false);
        this.CalloutService.runApex('selectAndCountRecords', {
            'query': this.constructTableRecordsQuery(cmp),
            'countQuery': this.constructTableRecordsCountQuery(cmp),
            'ids': ids
        }).then(result => {
            if (cmp.getLocalId() == 'productGroup') {
                this.mapQueryResult(cmp, result.queryResult);
            }
            table.set('v.data', result.queryResult);
            cmp.get('v.header').set('v.recordsSize', $A.util.isEmpty(result.queryResult) ? 0 : result.queryResult.length);
            cmp.get('v.header').set('v.totalSize', result.countQueryResult);
            cmp.set('v.isDataTableReady', true);
            cmp.set('v.isGroupEmpty', $A.util.isEmpty(result.queryResult));
        }).catch(error => {
            console.error(error);
            cmp.set('v.isDataTableReady', true);
        })
    },

    addAllToPreview: function (cmp) {
        const
            groupId = cmp.get('v.header').get('v.group.Id')
            , table = cmp.find('dataTable')
            , sortBy = table.get('v.sortedBy')
            , sortDirection = table.get('v.sortedDirection');
        if (groupId) {
            this.CalloutService.runApex('selectRecords', {
                'query': this.constructTableRecordsQuery(cmp, groupId, sortBy, sortDirection, '', '0', '5000')
            }).then(result => {
                var sequence = result;
                if (cmp.getLocalId() === 'productGroup') {
                    if (cmp.get('v.parent').get('v.model')) {
                        cmp.set('v.mapping', cmp.get('v.parent').get('v.model.productsMapping'));
                    }
                    this.mapQueryResult(cmp, result);
                    if (!sortBy) {
                        sequence = this.getRecordsSequence(result) || result;
                    }
                }
                cmp.get('v.parent').addSelectedToPreview(sequence, cmp.getLocalId());
            })
                .catch(error => {
                    console.error(error);
                });
        }
    },

    executeQuery: function (cmp, whereConditions) {
        if (whereConditions) {
            this.CalloutService.runApex('selectRecords', {
                'query': this.constructTableRecordsQuery(cmp, '', '', '', whereConditions)
            }).then(result => {
                if (cmp.getLocalId() == 'productGroup') {
                    this.mapQueryResult(cmp, result);
                }
                if ($A.util.isEmpty(result)) {
                    var toast = $A.get("e.force:showToast");
                    toast.setParams({
                        'type': 'warning',
                        'title': 'Warning!',
                        'message': 'No records match filter criteria'
                    });
                    toast.fire();
                } else {
                    setTimeout($A.getCallback(() => {
                        cmp.get('v.parent').addSelectedToPreview(result, cmp.getLocalId());
                    }), 1);
                    cmp.get('v.parent').find(cmp.getLocalId() + 'Compound').set('v.filterResultRecords', result);
                }
            }).catch(error => {
                console.error(error);
            })
        }
    },

    constructTableRecordsQuery: function (cmp, groupId, sortBy, sortDirection, whereConditions, offset, limit) {
        var conditions = cmp.get('v.criteria').concat(
            groupId
                ? {
                    'f': 'Id', 's': 'IN', 'v': '(SELECT ' + cmp.get('v.recordLookupApiName')
                    + ' FROM ' + cmp.get('v.recordInGroupApiName')
                    + ' WHERE ' + cmp.get('v.groupApiName') + ' = \'' + groupId + '\')'
                    // + ((cmp.get('v.recordInGroupApiName') === 'AccountInGroup__c') ? ' AND Exclusion__c != true)' : ')')
                }
                : whereConditions
                ? []
                : {'f': 'Id', 's': 'IN', 'v': ':ids'}
        );
        let queryBuilderResult = this.getQueryBuilder()

            .sobjectType(cmp.get('v.recordApiName'))
            .conditions(conditions, cmp.get('v.criteriaLogic'), whereConditions)
            // .fields(['Id','Name'])
            .fields(['Id', 'Name'].concat(cmp.get('v.recordApiName') === 'EUR_CRM_Account__c'
                ? [
                    'EUR_CRM_Street__c'
                    , 'EUR_CRM_City__c'
                    , 'EUR_CRM_Channel__c'
                    , 'EUR_CRM_Account_Code__c'
                    , 'EUR_CRM_Address__c'
                    , 'Owner.Name'
                    , 'OwnerId'
                    , 'EUR_CRM_PRS_Image_Level__r.Name'
                ]
                : []))
            // .fields(['Id','Name'].concat(cmp.getLocalId() !== 'accountGroup'
            //     ? [
            //         'EAN__c'
            //         ,'ProductSAPcode__c'
            //         ,'ACL__c'
            //         ,'toLabel(Brandgl__c)'
            //         ,'(SELECT Id,Sequence__c FROM Product_in_Groups__r WHERE ProductGroup__c = \'' + groupId + '\')'
            //         ,'(SELECT Id FROM Price_Book_Items__r WHERE PriceBookID__r.IsStandard__c = true AND RecordType.DeveloperName = \'Free\' AND ProductID__r.CTCPG__IsActive__c = TRUE LIMIT 5000)'
            //     ]
            //     : ['AccountSAP100code__c']))
            .orderBy(sortBy, sortDirection)
            .limit(limit || cmp.get('v.limit'))
            .offset(offset || cmp.get('v.offset'))
            .build();
        return queryBuilderResult;
    },

    constructTableRecordsCountQuery: function (cmp, groupId) {
        var criteria = cmp.get('v.criteria');
        var searchCriteriaIndex = criteria.findIndex(item => item.isSearch);
        if (searchCriteriaIndex > -1) {
            criteria.splice(searchCriteriaIndex, 1);
        }
        return this.getQueryBuilder()
            .sobjectType(cmp.get('v.recordApiName'))
            .conditions(criteria.concat(groupId
                ? {
                    'f': 'Id', 's': 'IN', 'v': '(SELECT ' + cmp.get('v.recordLookupApiName')
                    + ' FROM ' + cmp.get('v.recordInGroupApiName')
                    + ' WHERE ' + cmp.get('v.groupApiName') + ' = \'' + groupId + '\')'
                }
                : {'f': 'Id', 's': 'IN', 'v': ':ids'}), cmp.get('v.criteriaLogic'))
            .fields(['COUNT()'])
            .build();
    },

    getQueryBuilder: function () {
        var query = 'SELECT {fields} FROM {sobjectType} WHERE {conditions}';

        class QueryBuilder {
            sobjectType(sobjectType) {
                query = query.replace('{sobjectType}', sobjectType);
                return this;
            }

            conditions(criteria, logic, whereConditions) {
                var conditions = $A.util.isEmpty(logic)
                    ? criteria.map(item => item.f + ' ' + item.s + ' ' + item.v).join(' AND ')
                    : logic.replace(/{\d}/g, function (p) {
                        var i = parseInt(p.substring(1, p.length - 1));
                        return criteria[i] || p;
                    });
                if (whereConditions) {
                    conditions += conditions ? ' AND (' + whereConditions + ')' : whereConditions
                }
                query = query.replace('{conditions}', conditions);
                return this;
            }

            fields(fields) {
                query = query.replace('{fields}', (fields || ['Id']).join(', '));
                return this;
            }

            orderBy(sortBy, sortDirection) {
                query += ' ORDER BY ' + (sortBy || 'Name') + ' ' + (sortDirection || 'asc')
                    + (sortDirection == 'desc' ? ' NULLS LAST' : ' NULLS FIRST');
                return this;
            }

            limit(limit) {
                if(Boolean(limit) && limit!='0'){
                    query += ' LIMIT ' + limit;
                }
                return this;
            }

            offset(offset) {
                if( Boolean(offset) && offset!='0'){
                    query += ' OFFSET ' + offset;
                }
                return this;
            }

            build() {
                return query;
            }
        }

        return new QueryBuilder();
    },

    doSearch: function (cmp, searchPhrase, searchField) {
        if (searchField) {
            this.updateSearchCriteria(cmp, searchPhrase, searchField);
        }
    },

    updateSearchCriteria: function (cmp, searchPhrase, searchField) {
        let criteria = cmp.get('v.criteria') || [];
        let inx = criteria.findIndex((item) => item.isSearch);
        if (inx > -1 && $A.util.isEmpty(searchPhrase)) {
            criteria.splice(inx, 1);
        } else if (inx > -1) {
            criteria[inx].v = "'%" + searchPhrase + "%'";
        } else if (!$A.util.isEmpty(searchPhrase)) {
            criteria = criteria.concat({
                'f': searchField,
                's': 'LIKE',
                'v': "'%" + searchPhrase + "%'",
                'isSearch': true
            });
        }
        cmp.set('v.criteria', criteria);
    },

    mapQueryResult: function (cmp, records) {
        const mapping = cmp.get('v.mapping');
        if (!$A.util.isEmpty(records)) {
            for (let i = 0; i < records.length; i++) {
                records[i].MultiplicationFactor = mapping && mapping[records[i]['EAN__c']] ? mapping[records[i]['EAN__c']]['MultiplicationFactor'] || '1' : '1';
                records[i].ExcludeFromDiscounts = mapping && mapping[records[i]['EAN__c']] ? mapping[records[i]['EAN__c']]['ExcludeFromDiscounts'] : '';
            }
        }
    },

    getRecordsSequence: function (records) {
        if (!$A.util.isEmpty(records)) {
            try {
                var sequence = records.map((record, index) => {
                    record['_index'] = index;
                    return record;
                });
                sequence.sort((a, b) => {
                    return parseInt(a['Product_in_Groups__r'][0]['Sequence__c'] || (100000 + a['_index'])) - parseInt(b['Product_in_Groups__r'][0]['Sequence__c'] || (100000 + b['_index']));
                });
            } catch (e) {
                console.log('exception on sequencing', e);
            }
        }
        return sequence;
    }
});