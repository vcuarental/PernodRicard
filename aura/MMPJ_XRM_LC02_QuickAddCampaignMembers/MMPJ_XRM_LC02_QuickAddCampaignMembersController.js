({

    doInit : function(component, event, helper){
        helper.getCampaignMemberIds(component);
        helper.getIfCampIsMypj(component);
    },

    keyPressController : function(component, event, helper) {
        // get the search Input keyword
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0, or user clicked on search picto, then open the lookup result List and
        // call the helper
        // else close the lookup result List part.
        if( (getInputkeyWord && getInputkeyWord.length > 2) || (event.getName() === 'click' )){
            component.set("v.searchResVisible", true);
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{
            component.set("v.searchResVisible", false);
            component.set("v.listOfSearchRecords", null );
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },

    addCampaignMember : function(component,event,helper){
        var contactId = event.currentTarget.getAttribute("data-ContactId");
        var contactName = event.currentTarget.getAttribute("data-ContactName");
        var societeParDefaut = event.currentTarget.getAttribute("data-societeParDefaut");
        var isMypj = component.get("v.isMypj");
        
        //lorsqu'on essaie d'ajouter un campaign member sans société, on avertit l'utilisateur que c'est impossible
        if((societeParDefaut != null && societeParDefaut != undefined && societeParDefaut!= '') || isMypj){
            if(isMypj) {
                helper.AddCampaignMemberHelper(component,event,contactId, contactName, null);
            } else {
                helper.AddCampaignMemberHelper(component,event,contactId, contactName, societeParDefaut);
            }
        } else {
            alert(contactName + " n'a pu être ajouté ! veuillez choisir une société svp" ); 
        }
        helper.clear(component,event);  
    },

    // This function call when the end User Select any record from the result list.
    handleComponentEvent : function(component, event, helper) {

        // get the selected Account record from the COMPONETN event
        var selectedAccountGetFromEvent = event.getParam("accountByEvent");

        component.set("v.selectedRecord" , selectedAccountGetFromEvent);

        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');

        var forclose = component.find("searchRes"); 
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');

        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');

    },

    onCloseBtnClick : function(component, event, helper){
        helper.onCloseBtnClick(component);
    }
   

})