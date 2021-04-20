({
    /*hideCM : function(component){
        let compCM = component.find("trCM");
       
        if(compCM != undefined && compCM.length > 30){ 
            for(var i=10; i < compCM.length; i++){
                $A.util.addClass(compCM[i] , 'classHide');
            }
        }
    },
    
    showCM : function(component){
        let compCM = component.find("trCM");
        if(compCM != undefined && compCM.length > 30){       
            for(var i=30; i < compCM.length; i++){
                $A.util.removeClass(compCM[i] , 'classHide');
            }
        }
    },*/
    
    refresh : function(component){
        component.set('v.campaignMembers', null);
        component.set("v.campaignMembersFiltered",null);
        component.set('v.nbCampaignMembers', 0);
        var action = component.get('c.getCampaignMembers');
        action.setParams({
            campaignId : component.get("v.recordId")
        });
        
        action.setCallback(this, function (response){
            if(response.getState() === "SUCCESS"){
                if(response.getReturnValue() != []){
                    component.set("v.nbCampaignMembers", response.getReturnValue().length);
                    component.set("v.campaignMembers", response.getReturnValue());
                    component.set("v.campaignMembersFiltered",response.getReturnValue());
                    if(response.getReturnValue() && response.getReturnValue().length != 0){
                    	component.set("v.campaignName", response.getReturnValue()[0].Campaign.Name);
                    }
                }
                else{
                    component.set("v.nbCampaignMembers", 0);
                    component.set("v.campaignMembers", []);
                    component.set("v.campaignMembersFiltered",[]);
                }
                
                component.set("v.checkedCampaignMembers", []);
                component.find("cbSelectAll").set("v.value", false);
                var isAllRecordPage = component.get('v.isAllRecordPage');
                if(!isAllRecordPage){
                    //this.hideCM(component);
                }
            }
            else{
                alert(response.getState());
            }
        });
        $A.enqueueAction(action);
    },
    
    
})