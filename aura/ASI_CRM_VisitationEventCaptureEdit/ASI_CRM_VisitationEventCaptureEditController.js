({
    init : function(cmp, event, helper) {
        var myPage = cmp.get("v.pageReference");
        cmp.set("v.customerId",myPage.state.c__cid);
        cmp.set("v.visitId",myPage.state.c__vid);
        //cmp.set("v.isStopped",myPage.state.c__isStopped);
        cmp.set("v.mode",myPage.state.c__mode);
        helper.getSubBrandRecordType(cmp);
        if(cmp.get("v.mode") == 'Create'){
            cmp.set("v.isCreated",false);
            var newEvent = {
                'Id' : null,
                'Name' : null,
                'ASI_CRM_MY_ActivationEndDate__c' : null,
                'ASI_CRM_MY_ActivationEndTime__c' : null,
                'ASI_CRM_MY_ActivationStartDate__c' : null,
                'ASI_CRM_MY_ActivationStartTime__c' : null,
                'ASI_CRM_MY_Brand__c' : null,
                'ASI_CRM_MY_SeeSameEvent__c' : false,
                'ASI_CRM_MY_MoreActivation__c' : null,
                'ASI_CRM_MY_InitiatedOutlet__c' : false,
                'ASI_CRM_MY_PRMorCompetitor__c' : null,
                'ASI_CRM_MY_NumberBAs__c' : null,
                'ASI_CRM_MY_Outlet__c' : cmp.get("v.customerId"),
                'ASI_CRM_MY_PromotionMechanics__c' : null,
                'ASI_CRM_MY_Remarks__c' : null,
                'ASI_CRM_MY_Subbrand__c' : null,
                'ASI_CRM_MY_BrandOther__c' : null,
                'ASI_CRM_MY_TypeActivation__c' : null,
                'ASI_CRM_MY_TypeOther__c' : null,
                'ASI_CRM_MY_VisitationPlanDetail__c' : cmp.get("v.visitId"),
                'ASI_CRM_MY_WhereActivation__c' : null,
            }
            console.log(newEvent);
            cmp.set("v.event",newEvent);
            cmp.set("v.subBrand",'');
            cmp.set("v.photoList",null);
            console.log(cmp.get("v.event"));
        }
        else {
            cmp.set("v.isCreated",true);
            cmp.set("v.recordId",myPage.state.c__eid);
            helper.getCurrentEvent(cmp);
        }
    },

    createEvent : function(cmp,event, helper) {
        if(cmp.get("v.event.Name") == null || cmp.get("v.event.Name") == '')
        {
            alert("Please input Event Name");
        }
        else if(cmp.get("v.event.ASI_CRM_MY_TypeActivation__c") == 'Others' && (cmp.get("v.event.ASI_CRM_MY_TypeOther__c") == null ||cmp.get("v.event.ASI_CRM_MY_TypeOther__c") =='' )){
            alert("Please input Type of Activatin (Other)");
        }
        else
        {
            cmp.set("v.isCreated",true);
            swal.fire({
				title: 'Create Event',
				text: "Are you sure?",
				showCancelButton: true,
				confirmButtonColor: '#3085d6',
				cancelButtonColor: '#d33',
				confirmButtonText: 'Confirm'
			}).then((result) => {
				if(result.value) {
                    console.log('before checking');
                    if(cmp.get("v.event.ASI_CRM_MY_ActivationEndTime__c") 
                        && cmp.get("v.event.ASI_CRM_MY_ActivationEndTime__c") !=''
                        && cmp.get("v.event.ASI_CRM_MY_ActivationEndTime__c") !='00.000')
                    {
                        cmp.set("v.event.ASI_CRM_MY_ActivationEndTime__c",cmp.get("v.event.ASI_CRM_MY_ActivationEndTime__c") + 'Z');
                    }

                    if(cmp.get("v.event.ASI_CRM_MY_ActivationStartTime__c") 
                        && cmp.get("v.event.ASI_CRM_MY_ActivationStartTime__c") !=''
                        && cmp.get("v.event.ASI_CRM_MY_ActivationStartTime__c") !='00.000')
                    {
                        cmp.set("v.event.ASI_CRM_MY_ActivationStartTime__c",cmp.get("v.event.ASI_CRM_MY_ActivationStartTime__c") + 'Z');
                    }
                    if(cmp.get("v.subBrand").value)
                    {
                        cmp.set("v.event.ASI_CRM_MY_Subbrand__c",cmp.get("v.subBrand").value);
                    }
                    console.log('after checking');
                    $A.util.removeClass(cmp.find("customSpinner"), 'slds-hide');
                    helper.createEventCapture(cmp);
                    
                }
                else{
                    cmp.set("v.isCreated",false);
                }
			});
            
        }   
        
    },

    editEvent : function(cmp,event, helper) {
        if(cmp.get("v.event.Name") == null || cmp.get("v.event.Name") == '')
        {
            alert("Please input Event Name");
        }
        else if(cmp.get("v.event.ASI_CRM_MY_TypeActivation__c") == 'Others' && (cmp.get("v.event.ASI_CRM_MY_TypeOther__c") == null ||cmp.get("v.event.ASI_CRM_MY_TypeOther__c") =='' )){
            alert("Please input Type of Activatin (Other)");
        }
        else
        {
            swal.fire({
				title: 'Edit Event',
				text: "Are you sure?",
				showCancelButton: true,
				confirmButtonColor: '#3085d6',
				cancelButtonColor: '#d33',
				confirmButtonText: 'Confirm'
			}).then((result) => {
				if(result.value) {
					if(cmp.get("v.event.ASI_CRM_MY_ActivationEndTime__c") 
                        && cmp.get("v.event.ASI_CRM_MY_ActivationEndTime__c") !=''
                        && cmp.get("v.event.ASI_CRM_MY_ActivationEndTime__c") !='00.000')
                    {
                        cmp.set("v.event.ASI_CRM_MY_ActivationEndTime__c",cmp.get("v.event.ASI_CRM_MY_ActivationEndTime__c") + 'Z');
                    }

                    if(cmp.get("v.event.ASI_CRM_MY_ActivationStartTime__c") 
                        && cmp.get("v.event.ASI_CRM_MY_ActivationStartTime__c") !=''
                        && cmp.get("v.event.ASI_CRM_MY_ActivationStartTime__c") !='00.000')
                    {
                        cmp.set("v.event.ASI_CRM_MY_ActivationStartTime__c",cmp.get("v.event.ASI_CRM_MY_ActivationStartTime__c") + 'Z');
                    }
                    if(cmp.get("v.subBrand").value)
                    {
                        cmp.set("v.event.ASI_CRM_MY_Subbrand__c",cmp.get("v.subBrand").value);
                    }
                    $A.util.removeClass(cmp.find("customSpinner"), 'slds-hide');
                    helper.editEventCapture(cmp);
                    
                }
			});
            
        }   
        
    },

    uploadFilesHandling : function(cmp,event,helper)
    {
        var uploadedFiles = event.getParam("files");
        
        alert("Files uploaded : " + uploadedFiles.length);
        helper.getPhoto(cmp);
    },

    viewPhoto: function(cmp, event, helper) {
		$A.get('e.lightning:openFiles').fire({
		    recordIds: [event.currentTarget.id]
		});
	}
})