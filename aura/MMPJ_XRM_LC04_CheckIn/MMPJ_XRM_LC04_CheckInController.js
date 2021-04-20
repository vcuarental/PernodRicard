({

    doInit : function(component, event, helper){
        const columns = [
            {label: $A.get("{!$Label.c.MMPJ_XRM_LC05_Screen1_Name}"), type: 'button',  fieldName: 'Name', typeAttributes: {
                label: { fieldName: 'Name' }, name: 'view_campaign', target: '_self', tooltip: ''
            }, sortable: true}
        ];

        if (!helper.detectMobile()) {
            columns.push({label: $A.get("{!$Label.c.MMPJ_XRM_LC05_Screen1_OwnerName}"), fieldName: 'OwnerName', type: 'text', sortable: true});
            columns.push({label: $A.get("{!$Label.c.MMPJ_XRM_LC05_Screen1_StartDate}"), fieldName: 'StartDate', type: 'date', sortable: true});
            columns.push({label: $A.get("{!$Label.c.MMPJ_XRM_LC05_Screen1_EndDate}"), fieldName: 'EndDate', type: 'date', sortable: true});
            columns.push({label: $A.get("{!$Label.c.MMPJ_XRM_LC05_Screen1_Target}"), fieldName: 'MMPJ_Ext_Vign_Cible__c', type: 'text', sortable: true});
        }

        component.set('v.columns', columns);
        component.set('v.listOfSearchRecords', []);

    },

    keyPressController : function(component, event, helper) {
        // get the search Input keyword
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0, or user clicked on search picto, then open the lookup result List and
        // call the helper
        // else close the lookup result List part.
        if (
            (
                getInputkeyWord
                && getInputkeyWord.length > 0
            )
            || event.getName() === 'click'
        ) {
            component.set("v.searchResVisible", true);
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        } else {
            component.set("v.searchResVisible", false);
            component.set("v.listOfSearchRecords", null );
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },

    handleRowAction: function(component,event,helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'view_campaign':
                helper.navigateToComponent(row.Id);
                break;
        }
    },



    //Method gets called by onsort action,
    handleSort : function(component,event,helper){
        //Returns the field which has to be sorted
        var sortBy = event.getParam("fieldName");
        //returns the direction of sorting like asc or desc
        var sortDirection = event.getParam("sortDirection");
        //Set the sortBy and SortDirection attributes
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        // call sortData helper function
        helper.sortData(component,sortBy,sortDirection);
    }

})