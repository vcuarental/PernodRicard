/**
 * Created by V. Kamenskyi on 19.09.2017.
 */
({
    setRecords : function (cmp, helper) {
    	var recId = cmp.get('v.recordId');
    	var parId = cmp.get('v.parentId');
    	if(!parId && recId){
    		cmp.set('v.parentId',recId);
    		parId = recId;
    	}

    	
        if (parId) {
            ltngService.runApex(cmp, helper, 'getShareRecords', {'parentId':cmp.get('v.parentId')}, (cmp, helper, response) => {
                var result = response.getReturnValue();
                cmp.set('v.allReasons', result.allReasons);
                cmp.set('v.reasons', result.reasons);
                cmp.set('v.records', helper.mapRecords(cmp, result.records));
                cmp.set('v.accessLevels', result.accessLevels);
            });
        } else if (cmp.get('v.shareObjectType')) {
            ltngService.runApex(cmp, helper, 'getInitValues', {'shareObjectType':cmp.get('v.shareObjectType')}, (cmp, helper, response) => {
                var result = response.getReturnValue();
                cmp.set('v.allReasons', result.allReasons);
                cmp.set('v.reasons', result.reasons);
                cmp.set('v.accessLevels', result.accessLevels);
                cmp.set('v.L_User', result.userType);
                cmp.set('v.L_Public_Group', result.groupType);
                cmp.set('v.userId', result.userId);
                cmp.set('v.records', helper.mapRecords(cmp, cmp.get('v.records') || []));
            });

        }
    },

    mapRecords : function (cmp, records) {
        return records.map(record => {
        	// @edit 12.03.18 had cases when records were already set, but this method tried to reach into
        	// user or group object, which was not present for flattened object already set
            return {
                'Id' : record.Id,
                'UserOrGroupId' : record.UserOrGroupId,
                'UserOrGroupName' : record.UserOrGroupName || record.UserOrGroup.Name || '',
                'UserOrGroupType' : record.UserOrGroupType || record.UserOrGroup.Type,
                'AccessLevel' : record.AccessLevel,
                'RowCause' : record.RowCause,
                'RoleId' : record.RoleId,
                'reason' : (cmp.get('v.allReasons') || {})[record.RowCause]
            }
        })
    },

    selectUsersOrGroups : function (cmp, helper) {
        ltngService.runApex(cmp, helper, 'getSharingSubjects', {'searchTerm':cmp.get('v.searchSubject')}, (cmp, helper, response) => {
            var subjects = response.getReturnValue();
            var mapping = item => { return { 'name' : item.Id, 'label' : item.Name || item.Related.Name || '' } };
            subjects.users = (subjects.users || []).map(mapping);
            subjects.groups = (subjects.groups || []).map(mapping);
            subjects.roles = (subjects.roles || []).map(mapping);
            subjects.rolesAndSubordinates = (subjects.rolesAndSubordinates || []).map(mapping);
            cmp.set('v.subjects', subjects);
            cmp.find('addUsersDialog').set('v.visible', true);
        });
    },

    addToShare : function (cmp, helper) {
        if (!cmp.get('v.parentId')) {
            let records = cmp.get('v.records') || [];
            let dialog = cmp.find('addUsersDialog');
            let result = dialog.get('v.result');
            let accessLevel = cmp.get('v.accessLevels')[dialog.get('v.accessLevel')];
            let reason = cmp.get('v.allReasons')[dialog.get('v.reason')];
            if (!$A.util.isEmpty(result)) {
                cmp.set('v.records', records.concat(result.map((item) => {
                    return {
                        'UserOrGroupId' : item.name,
                        'UserOrGroupType' : item.name.startsWith('005') ? cmp.get('v.L_User') : cmp.get('v.L_Public_Group'),
                        'UserOrGroupName' : item.label,
                        'AccessLevel' : accessLevel,
                        'RowCause' : reason,
                        'reason' : reason
                    }
                })));
            }
            return;
        }
        var comp = cmp.find('addUsersDialog');
        var items = comp.get('v.result');
        var ids = items.map(item => item.name);
        var params = {
            'parentId' : cmp.get('v.parentId')
            , 'userOrGroupIds' : ids
            , 'accessLevel' : comp.get('v.accessLevel')
            , 'reason' : comp.get('v.reason')
        };
        ltngService.runApex(cmp, helper, 'setSharing', params,(cmp, helper, response) => console.log(response.getReturnValue()));
        helper.setRecords(cmp, helper);
    },

    showEditSharingDialog : function (cmp, helper, record) {
        var modal = cmp.find('editSharingDialog');
        modal.set('v.data', record);
        modal.set('v.visible', true);
    },

    deleteSharing : function (cmp, helper, record, pos) {
        var params = {
            'parentId' : cmp.get('v.parentId')
            , 'userOrGroupIds' : [].concat(record.UserOrGroupId)
        };
        if (params.parentId) {
            ltngService.runApex(cmp, helper, 'removeSharing', params,(cmp, helper, response) => console.log(response.getReturnValue()));
            helper.setRecords(cmp, helper);
        } else {
            let records = cmp.get('v.records') || [];
            records.splice(pos, 1);
            cmp.set('v.records', records);
        }
    },

    updateSharing : function (cmp, helper) {
        var comp = cmp.find('editSharingDialog');
        comp.set('v.visible', false);
        if (!cmp.get('v.parentId')) {
            let records = cmp.get('v.records');
            records[cmp.get('v.editRecordPos')].AccessLevel = cmp.get('v.accessLevels')[cmp.find('edit-dialog-select-access').get('v.value')];
            cmp.set('v.records', records);
            return;
        }
        var record = comp.get('v.data');
        var access = cmp.find('edit-dialog-select-access').get('v.value');
        var params = {
            'parentId' : cmp.get('v.parentId')
            , 'userOrGroupIds' : [].concat(record.UserOrGroupId)
            , 'accessLevel' : access
            , 'reason' : record.RowCause
        };
        ltngService.runApex(cmp, helper, 'setSharing', params,(cmp, helper, response) => console.log(response.getReturnValue()));
        helper.setRecords(cmp, helper);
    },
})